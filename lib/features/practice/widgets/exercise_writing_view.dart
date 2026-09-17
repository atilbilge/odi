import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/exercise.dart';

class _LetterTileItem {
  final int id;
  final String char;
  bool isUsed;

  _LetterTileItem({
    required this.id,
    required this.char,
  }) : isUsed = false;
}

class ExerciseWritingView extends ConsumerStatefulWidget {
  final WritingExercise exercise;
  final bool autoPlayAudio;
  final VoidCallback onToggleAutoPlay;
  final void Function(bool isSuccess) onCompleted;
  final VoidCallback onSkip;

  const ExerciseWritingView({
    super.key,
    required this.exercise,
    required this.autoPlayAudio,
    required this.onToggleAutoPlay,
    required this.onCompleted,
    required this.onSkip,
  });

  @override
  ConsumerState<ExerciseWritingView> createState() => _ExerciseWritingViewState();
}

class _ExerciseWritingViewState extends ConsumerState<ExerciseWritingView> {
  final List<_LetterTileItem> _allTiles = [];
  final List<_LetterTileItem?> _placedTokens = []; // null represents a space character
  bool _hasChecked = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _initLetterBank();
  }

  void _initLetterBank() {
    _allTiles.clear();
    _placedTokens.clear();

    // 1. Extract clean letters from the Serbian target
    final cleanTarget = widget.exercise.correctSerbian.replaceAll(RegExp(r'[!?,.:;"]'), '');
    final chars = cleanTarget.split('').where((c) => c != ' ').toList();

    int idCounter = 0;
    final List<_LetterTileItem> tiles = [];
    for (final char in chars) {
      tiles.add(_LetterTileItem(id: idCounter++, char: char));
    }

    // 2. Add 2-3 distractor letters to make it engaging
    final distractorPool = ['a', 'e', 'i', 'o', 'u', 'r', 's', 't', 'k', 'n', 'm', 'd', 'p', 'j', 'č', 'v'];
    final random = Random();
    distractorPool.shuffle(random);

    int distractorsAdded = 0;
    for (final d in distractorPool) {
      if (distractorsAdded >= 2) break;
      tiles.add(_LetterTileItem(id: idCounter++, char: d));
      distractorsAdded++;
    }

    // 3. Shuffle all tiles
    tiles.shuffle(random);
    _allTiles.addAll(tiles);
  }

  void _onTileTap(_LetterTileItem tile) {
    if (_hasChecked || tile.isUsed) return;
    setState(() {
      tile.isUsed = true;
      _placedTokens.add(tile);
    });
  }

  void _onSpaceTap() {
    if (_hasChecked) return;
    // Don't allow multiple consecutive spaces or leading space
    if (_placedTokens.isEmpty || _placedTokens.last == null) return;
    setState(() {
      _placedTokens.add(null);
    });
  }

  void _onBackspaceTap() {
    if (_hasChecked || _placedTokens.isEmpty) return;
    setState(() {
      final lastToken = _placedTokens.removeLast();
      if (lastToken != null) {
        lastToken.isUsed = false;
      }
    });
  }

  void _onPlacedTokenTap(int index) {
    if (_hasChecked) return;
    setState(() {
      final token = _placedTokens.removeAt(index);
      if (token != null) {
        token.isUsed = false;
      }
    });
  }

  String _getFormedString() {
    final buffer = StringBuffer();
    for (final token in _placedTokens) {
      if (token == null) {
        buffer.write(' ');
      } else {
        buffer.write(token.char);
      }
    }
    return buffer.toString().trim();
  }

  void _checkAnswer() {
    final formedText = _getFormedString();
    if (formedText.isEmpty) return;

    final normalizedUser = _normalize(formedText);
    final normalizedTarget = _normalize(widget.exercise.correctSerbian);

    bool correct = (normalizedUser == normalizedTarget);
    if (!correct) {
      for (final alt in widget.exercise.alternateAccepted) {
        if (normalizedUser == _normalize(alt)) {
          correct = true;
          break;
        }
      }
    }

    setState(() {
      _hasChecked = true;
      _isCorrect = correct;
    });

    if (widget.autoPlayAudio) {
      ref.read(speechServiceProvider).speak(widget.exercise.correctSerbian);
    }
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[!?,.:;"]'), '')
        .replaceAll(' ', '')
        .trim();
  }

  bool get _hasSpacesInTarget => widget.exercise.correctSerbian.trim().contains(' ');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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

          // Prompt Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: OdiDecorations.card(radius: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('TRANSLATION', style: OdiTextStyles.label),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => ref.read(speechServiceProvider).speak(widget.exercise.correctSerbian),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: OdiColors.ocean.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.volume_up_rounded, size: 18, color: OdiColors.ocean),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.exercise.turkishPrompt,
                  textAlign: TextAlign.center,
                  style: OdiTextStyles.h2.copyWith(fontSize: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Answer Slot Area (Placed Letters)
          Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: OdiColors.cardWhite,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _hasChecked
                    ? (_isCorrect ? OdiColors.success : OdiColors.error)
                    : (_placedTokens.isNotEmpty ? OdiColors.coral : OdiColors.border),
                width: 1.5,
              ),
              boxShadow: OdiDecorations.subtleShadow,
            ),
            alignment: Alignment.center,
            child: _placedTokens.isEmpty
                ? Text(
                    'Tap letters below to write...',
                    style: OdiTextStyles.body2.copyWith(color: OdiColors.midGrey),
                  )
                : Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 8,
                    children: List.generate(_placedTokens.length, (index) {
                      final token = _placedTokens[index];
                      if (token == null) {
                        // Space chip
                        return InkWell(
                          onTap: _hasChecked ? null : () => _onPlacedTokenTap(index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: OdiColors.lightGrey,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: OdiColors.border),
                            ),
                            child: const Text('␣', style: TextStyle(fontSize: 16, color: OdiColors.midGrey)),
                          ),
                        );
                      }

                      return InkWell(
                        onTap: _hasChecked ? null : () => _onPlacedTokenTap(index),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _hasChecked
                                ? (_isCorrect
                                    ? OdiColors.success.withValues(alpha: 0.12)
                                    : OdiColors.error.withValues(alpha: 0.12))
                                : OdiColors.coral.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _hasChecked
                                  ? (_isCorrect ? OdiColors.success : OdiColors.error)
                                  : OdiColors.coral,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            token.char,
                            style: OdiTextStyles.body1.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: _hasChecked
                                  ? (_isCorrect ? OdiColors.success : OdiColors.error)
                                  : OdiColors.anthracite,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
          ),
          const SizedBox(height: 20),

          // On-Screen Letter Keyboard (Letter Bank)
          if (!_hasChecked) ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 10,
              children: _allTiles.map((tile) {
                if (tile.isUsed) {
                  // Blank placeholder slot when tile is used
                  return Container(
                    width: 44,
                    height: 48,
                    decoration: BoxDecoration(
                      color: OdiColors.lightGrey.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: OdiColors.border.withValues(alpha: 0.5),
                        style: BorderStyle.solid,
                      ),
                    ),
                  );
                }

                return Material(
                  color: OdiColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  child: InkWell(
                    onTap: () => _onTileTap(tile),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: OdiColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tile.char,
                        style: OdiTextStyles.h3.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: OdiColors.anthracite,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Keyboard Control Buttons: Space and Backspace
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_hasSpacesInTarget) ...[
                  ElevatedButton.icon(
                    onPressed: _onSpaceTap,
                    icon: const Icon(Icons.space_bar_rounded, size: 18),
                    label: const Text('Space'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OdiColors.cardWhite,
                      foregroundColor: OdiColors.anthracite,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: OdiColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                ElevatedButton.icon(
                  onPressed: _placedTokens.isNotEmpty ? _onBackspaceTap : null,
                  icon: const Icon(Icons.backspace_outlined, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OdiColors.cardWhite,
                    foregroundColor: OdiColors.anthracite,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: OdiColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Feedback Box with immediate auto-speak toggle
          if (_hasChecked) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCorrect ? OdiColors.success.withValues(alpha: 0.1) : OdiColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isCorrect ? OdiColors.success : OdiColors.error,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: _isCorrect ? OdiColors.success : OdiColors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isCorrect ? 'Great! Correct answer.' : 'Incorrect!',
                          style: OdiTextStyles.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isCorrect ? OdiColors.success : OdiColors.error,
                          ),
                        ),
                      ),
                      // Instant Auto-speak toggle
                      InkWell(
                        onTap: widget.onToggleAutoPlay,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: OdiColors.cardWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: OdiColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.autoPlayAudio ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                size: 16,
                                color: widget.autoPlayAudio ? OdiColors.coral : OdiColors.midGrey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.autoPlayAudio ? 'Auto: ON' : 'Auto: OFF',
                                style: OdiTextStyles.caption.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: widget.autoPlayAudio ? OdiColors.coral : OdiColors.midGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!_isCorrect) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Correct Answer: ${widget.exercise.correctSerbian}',
                      style: OdiTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Main Action Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _hasChecked
                  ? () => widget.onCompleted(_isCorrect)
                  : (_placedTokens.isNotEmpty ? _checkAnswer : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasChecked
                    ? (_isCorrect ? OdiColors.success : OdiColors.coral)
                    : OdiColors.coral,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _hasChecked ? 'Continue' : 'Check',
                style: OdiTextStyles.button.copyWith(color: Colors.white),
              ),
            ),
          ),

          if (!_hasChecked) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onSkip,
              child: Text(
                'Skip',
                style: OdiTextStyles.body2.copyWith(color: OdiColors.midGrey),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
