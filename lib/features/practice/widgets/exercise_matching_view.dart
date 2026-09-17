import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/exercise.dart';

class ExerciseMatchingView extends ConsumerStatefulWidget {
  final MatchingExercise exercise;
  final bool autoPlayAudio;
  final VoidCallback onToggleAutoPlay;
  final void Function(bool isSuccess) onCompleted;
  final VoidCallback onSkip;

  const ExerciseMatchingView({
    super.key,
    required this.exercise,
    required this.autoPlayAudio,
    required this.onToggleAutoPlay,
    required this.onCompleted,
    required this.onSkip,
  });

  @override
  ConsumerState<ExerciseMatchingView> createState() => _ExerciseMatchingViewState();
}

class _ExerciseMatchingViewState extends ConsumerState<ExerciseMatchingView> {
  late List<MatchingPair> _serbianCards;
  late List<MatchingPair> _turkishCards;
  final Set<int> _matchedIds = {};

  MatchingPair? _selectedSerbian;
  MatchingPair? _selectedTurkish;
  bool _isChecking = false;
  int _mistakeCount = 0;

  @override
  void initState() {
    super.initState();
    _serbianCards = List.from(widget.exercise.pairs)..shuffle();
    _turkishCards = List.from(widget.exercise.pairs)..shuffle();
  }

  void _onSerbianTap(MatchingPair pair) {
    if (_isChecking || _matchedIds.contains(pair.id)) return;

    if (widget.autoPlayAudio) {
      ref.read(speechServiceProvider).speak(pair.serbian);
    }

    setState(() {
      _selectedSerbian = pair;
    });

    if (_selectedTurkish != null) {
      _evaluateSelection();
    }
  }

  void _onTurkishTap(MatchingPair pair) {
    if (_isChecking || _matchedIds.contains(pair.id)) return;

    setState(() {
      _selectedTurkish = pair;
    });

    if (_selectedSerbian != null) {
      _evaluateSelection();
    }
  }

  Future<void> _evaluateSelection() async {
    final serbian = _selectedSerbian!;
    final turkish = _selectedTurkish!;
    _isChecking = true;

    if (serbian.id == turkish.id) {
      // Correct Match
      setState(() {
        _matchedIds.add(serbian.id);
        _selectedSerbian = null;
        _selectedTurkish = null;
        _isChecking = false;
      });

      if (_matchedIds.length == widget.exercise.pairs.length) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) {
          widget.onCompleted(_mistakeCount == 0);
        }
      }
    } else {
      // Wrong Match
      _mistakeCount++;
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _selectedSerbian = null;
          _selectedTurkish = null;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title & Instruction
        Text(
          widget.exercise.title,
          style: OdiTextStyles.h3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          widget.exercise.instructions,
          style: OdiTextStyles.body2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Two-column layout
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Serbian column
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _serbianCards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final pair = _serbianCards[index];
                    final isMatched = _matchedIds.contains(pair.id);
                    final isSelected = _selectedSerbian?.id == pair.id;
                    final isWrong = _isChecking && isSelected && _selectedTurkish?.id != pair.id;

                    return _buildCard(
                      text: pair.serbian,
                      isMatched: isMatched,
                      isSelected: isSelected,
                      isWrong: isWrong,
                      onTap: () => _onSerbianTap(pair),
                      hasAudioIcon: true,
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              // Meaning column
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _turkishCards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final pair = _turkishCards[index];
                    final isMatched = _matchedIds.contains(pair.id);
                    final isSelected = _selectedTurkish?.id == pair.id;
                    final isWrong = _isChecking && isSelected && _selectedSerbian?.id != pair.id;

                    return _buildCard(
                      text: pair.turkish,
                      isMatched: isMatched,
                      isSelected: isSelected,
                      isWrong: isWrong,
                      onTap: () => _onTurkishTap(pair),
                      hasAudioIcon: false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Skip Button
        TextButton(
          onPressed: widget.onSkip,
          child: Text(
            'Skip',
            style: OdiTextStyles.body2.copyWith(color: OdiColors.midGrey),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String text,
    required bool isMatched,
    required bool isSelected,
    required bool isWrong,
    required VoidCallback onTap,
    required bool hasAudioIcon,
  }) {
    Color bgColor = OdiColors.cardWhite;
    Color borderColor = OdiColors.border;
    Color textColor = OdiColors.anthracite;

    if (isMatched) {
      bgColor = OdiColors.success.withValues(alpha: 0.08);
      borderColor = OdiColors.success.withValues(alpha: 0.4);
      textColor = OdiColors.success;
    } else if (isWrong) {
      bgColor = OdiColors.error.withValues(alpha: 0.12);
      borderColor = OdiColors.error;
      textColor = OdiColors.error;
    } else if (isSelected) {
      bgColor = OdiColors.coral.withValues(alpha: 0.08);
      borderColor = OdiColors.coral;
      textColor = OdiColors.coral;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(minHeight: 64, maxHeight: 96),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isMatched ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
              boxShadow: isMatched ? [] : OdiDecorations.subtleShadow,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasAudioIcon && !isMatched) ...[
                  Icon(Icons.volume_down_rounded, size: 16, color: isSelected ? OdiColors.coral : OdiColors.ocean),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: OdiTextStyles.body2.copyWith(
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                if (isMatched) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle_rounded, size: 16, color: OdiColors.success),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
