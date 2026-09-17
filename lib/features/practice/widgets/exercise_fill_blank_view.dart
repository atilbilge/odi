import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/exercise.dart';

class ExerciseFillBlankView extends ConsumerStatefulWidget {
  final FillBlankExercise exercise;
  final bool autoPlayAudio;
  final VoidCallback onToggleAutoPlay;
  final void Function(bool isSuccess) onCompleted;
  final VoidCallback onSkip;

  const ExerciseFillBlankView({
    super.key,
    required this.exercise,
    required this.autoPlayAudio,
    required this.onToggleAutoPlay,
    required this.onCompleted,
    required this.onSkip,
  });

  @override
  ConsumerState<ExerciseFillBlankView> createState() => _ExerciseFillBlankViewState();
}

class _ExerciseFillBlankViewState extends ConsumerState<ExerciseFillBlankView> {
  String? _selectedOption;
  bool _hasChecked = false;
  bool _isCorrect = false;

  void _onSelectOption(String option) {
    if (_hasChecked) return;
    setState(() {
      _selectedOption = option;
    });
  }

  void _checkAnswer() {
    if (_selectedOption == null) return;

    final isCorrect = _selectedOption!.trim().toLowerCase() ==
        widget.exercise.correctWord.trim().toLowerCase();

    setState(() {
      _hasChecked = true;
      _isCorrect = isCorrect;
    });

    // Speak the full correct sentence only if autoPlayAudio is enabled
    if (widget.autoPlayAudio) {
      ref.read(speechServiceProvider).speak(widget.exercise.fullSerbianText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _selectedOption != null
        ? widget.exercise.sentenceWithBlank.replaceAll('______', '[ ${_selectedOption!} ]')
        : widget.exercise.sentenceWithBlank;

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
          const SizedBox(height: 24),

          // Main Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: OdiDecorations.card(radius: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('TRANSLATION', style: OdiTextStyles.label),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => ref.read(speechServiceProvider).speak(widget.exercise.fullSerbianText),
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
                  widget.exercise.turkishHint,
                  textAlign: TextAlign.center,
                  style: OdiTextStyles.body1.copyWith(color: OdiColors.midGrey),
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),
                Text(
                  displayText,
                  textAlign: TextAlign.center,
                  style: OdiTextStyles.h2.copyWith(fontSize: 22, color: OdiColors.coral),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Options (Chips / Buttons)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: widget.exercise.options.map((option) {
              final isSelected = _selectedOption == option;
              final isThisCorrect = option.trim().toLowerCase() == widget.exercise.correctWord.trim().toLowerCase();

              Color bgColor = OdiColors.cardWhite;
              Color borderColor = OdiColors.border;
              Color textColor = OdiColors.anthracite;

              if (_hasChecked) {
                if (isThisCorrect) {
                  bgColor = OdiColors.success.withValues(alpha: 0.12);
                  borderColor = OdiColors.success;
                  textColor = OdiColors.success;
                } else if (isSelected && !isThisCorrect) {
                  bgColor = OdiColors.error.withValues(alpha: 0.12);
                  borderColor = OdiColors.error;
                  textColor = OdiColors.error;
                }
              } else if (isSelected) {
                bgColor = OdiColors.ocean.withValues(alpha: 0.12);
                borderColor = OdiColors.ocean;
                textColor = OdiColors.deepSea;
              }

              return InkWell(
                onTap: _hasChecked ? null : () => _onSelectOption(option),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
                    boxShadow: OdiDecorations.subtleShadow,
                  ),
                  child: Text(
                    option,
                    style: OdiTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

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
                    Text('Correct Sentence: ${widget.exercise.fullSerbianText}',
                        style: OdiTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Main Button
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _hasChecked
                  ? () => widget.onCompleted(_isCorrect)
                  : (_selectedOption != null ? _checkAnswer : null),
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
