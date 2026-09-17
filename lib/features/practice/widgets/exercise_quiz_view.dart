import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/exercise.dart';

class ExerciseQuizView extends ConsumerStatefulWidget {
  final QuizExercise exercise;
  final bool autoPlayAudio;
  final VoidCallback onToggleAutoPlay;
  final void Function(bool isSuccess) onCompleted;
  final VoidCallback onSkip;

  const ExerciseQuizView({
    super.key,
    required this.exercise,
    required this.autoPlayAudio,
    required this.onToggleAutoPlay,
    required this.onCompleted,
    required this.onSkip,
  });

  @override
  ConsumerState<ExerciseQuizView> createState() => _ExerciseQuizViewState();
}

class _ExerciseQuizViewState extends ConsumerState<ExerciseQuizView> {
  String? _selectedOption;
  bool _hasChecked = false;
  bool _isCorrect = false;

  void _onOptionTap(String option) {
    if (_hasChecked) return;

    final isCorrect = option.trim().toLowerCase() == widget.exercise.correctAnswer.trim().toLowerCase();

    setState(() {
      _selectedOption = option;
      _hasChecked = true;
      _isCorrect = isCorrect;
    });

    // Play Serbian audio only if autoPlayAudio is enabled
    if (widget.autoPlayAudio) {
      ref.read(speechServiceProvider).speak(widget.exercise.serbianAudioText);
    }
  }

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
          const SizedBox(height: 24),

          // Question Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: OdiDecorations.card(radius: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.exercise.isSerbianToTurkish ? 'SERBIAN PHRASE' : 'TRANSLATION',
                      style: OdiTextStyles.label,
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => ref.read(speechServiceProvider).speak(widget.exercise.serbianAudioText),
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
                const SizedBox(height: 12),
                Text(
                  widget.exercise.question,
                  textAlign: TextAlign.center,
                  style: OdiTextStyles.h2.copyWith(fontSize: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4 Options List
          ...widget.exercise.options.map((option) {
            final isSelected = _selectedOption == option;
            final isThisCorrect = option.trim().toLowerCase() == widget.exercise.correctAnswer.trim().toLowerCase();

            Color bgColor = OdiColors.cardWhite;
            Color borderColor = OdiColors.border;
            Color textColor = OdiColors.anthracite;
            Widget? trailingIcon;

            if (_hasChecked) {
              if (isThisCorrect) {
                bgColor = OdiColors.success.withValues(alpha: 0.1);
                borderColor = OdiColors.success;
                textColor = OdiColors.success;
                trailingIcon = const Icon(Icons.check_circle_rounded, color: OdiColors.success);
              } else if (isSelected && !isThisCorrect) {
                bgColor = OdiColors.error.withValues(alpha: 0.1);
                borderColor = OdiColors.error;
                textColor = OdiColors.error;
                trailingIcon = const Icon(Icons.cancel_rounded, color: OdiColors.error);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: _hasChecked ? null : () => _onOptionTap(option),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor, width: (isSelected || isThisCorrect && _hasChecked) ? 2 : 1),
                      boxShadow: OdiDecorations.subtleShadow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: OdiTextStyles.body1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Instant Auto-speak toggle button when checked
          if (_hasChecked) ...[
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: widget.onToggleAutoPlay,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        widget.autoPlayAudio ? 'Auto-speak: ON' : 'Auto-speak: OFF',
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
            ),
            const SizedBox(height: 16),
          ],

          // Action Button
          if (_hasChecked)
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => widget.onCompleted(_isCorrect),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCorrect ? OdiColors.success : OdiColors.coral,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Continue',
                  style: OdiTextStyles.button.copyWith(color: Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: widget.onSkip,
              child: Text(
                'Skip',
                style: OdiTextStyles.body2.copyWith(color: OdiColors.midGrey),
              ),
            ),
        ],
      ),
    );
  }
}
