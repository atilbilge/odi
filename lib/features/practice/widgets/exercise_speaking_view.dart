import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/services/pronunciation_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/exercise.dart';

class ExerciseSpeakingView extends ConsumerStatefulWidget {
  final SpeakingExercise exercise;
  final void Function(bool isSuccess) onCompleted;
  final VoidCallback onSkip;

  const ExerciseSpeakingView({
    super.key,
    required this.exercise,
    required this.onCompleted,
    required this.onSkip,
  });

  @override
  ConsumerState<ExerciseSpeakingView> createState() => _ExerciseSpeakingViewState();
}

class _ExerciseSpeakingViewState extends ConsumerState<ExerciseSpeakingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _isRecording = false;
  String _transcribedText = '';
  PronunciationResult? _pronunciationResult;
  bool _canAdvance = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final speechService = ref.read(speechServiceProvider);
    final hasPerm = await speechService.hasPermission();
    if (!hasPerm) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone and speech recognition permission required.')),
        );
      }
      return;
    }

    setState(() {
      _isRecording = true;
      _transcribedText = 'Listening...';
      _pronunciationResult = null;
      _canAdvance = false;
    });

    await speechService.startListening(
      onResult: (text) {
        if (mounted) {
          setState(() {
            _transcribedText = text;
            final result = ref.read(pronunciationServiceProvider).analyze(
              widget.exercise.targetSerbian,
              text,
            );
            _pronunciationResult = result;
            _canAdvance = result.accuracy >= 75.0;
          });
        }
      },
    );
  }

  Future<void> _stopRecording() async {
    final speechService = ref.read(speechServiceProvider);
    await speechService.stopListening();
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      final cleanText = _transcribedText.trim();
      if (cleanText == 'Listening...' || cleanText.isEmpty) {
        setState(() {
          _isRecording = false;
          _transcribedText = '';
          _pronunciationResult = null;
          _canAdvance = false;
        });
      } else {
        final result = ref.read(pronunciationServiceProvider).analyze(
          widget.exercise.targetSerbian,
          cleanText,
        );
        setState(() {
          _isRecording = false;
          _transcribedText = cleanText;
          _pronunciationResult = result;
          _canAdvance = result.accuracy >= 75.0;
        });
      }
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

          // Target Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: OdiDecorations.card(radius: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('TARGET PHRASE', style: OdiTextStyles.label),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => ref.read(speechServiceProvider).speak(widget.exercise.targetSerbian),
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
                  widget.exercise.targetSerbian,
                  textAlign: TextAlign.center,
                  style: OdiTextStyles.h2.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.exercise.turkishPrompt,
                  textAlign: TextAlign.center,
                  style: OdiTextStyles.body2.copyWith(color: OdiColors.midGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Transcribed Text & Accuracy Chips
          if (_transcribedText.isNotEmpty) ...[
            Text('SPOKEN', style: OdiTextStyles.label, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              _transcribedText,
              textAlign: TextAlign.center,
              style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
          ],

          if (_pronunciationResult != null) ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _pronunciationResult!.matches.map((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: m.isCorrect ? OdiColors.success.withValues(alpha: 0.12) : OdiColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: m.isCorrect ? OdiColors.success : OdiColors.error,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    m.word,
                    style: OdiTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: m.isCorrect ? OdiColors.success : OdiColors.error,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Text(
              'Accuracy: %${_pronunciationResult!.accuracy.toInt()}',
              textAlign: TextAlign.center,
              style: OdiTextStyles.body1.copyWith(
                fontWeight: FontWeight.w700,
                color: _canAdvance ? OdiColors.success : OdiColors.error,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Mic Button
          Center(
            child: _buildMicButton(),
          ),
          const SizedBox(height: 8),
          Text(
            _isRecording ? 'Listening... Speak now' : 'Hold to pronounce in Serbian',
            style: OdiTextStyles.caption.copyWith(color: OdiColors.midGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Buttons
          if (_canAdvance)
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => widget.onCompleted(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OdiColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Continue', style: OdiTextStyles.button.copyWith(color: Colors.white)),
              ),
            )
          else
            TextButton(
              onPressed: widget.onSkip,
              child: Text(
                'Can\'t speak right now / Skip',
                style: OdiTextStyles.body2.copyWith(color: OdiColors.midGrey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopRecording(),
      onTapCancel: () => _stopRecording(),
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isRecording) ...[
                  for (int i = 0; i < 2; i++)
                    _buildPulseRing(i),
                ],
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isRecording ? 76 : 64,
                  height: _isRecording ? 76 : 64,
                  decoration: BoxDecoration(
                    gradient: _isRecording
                        ? const LinearGradient(colors: [OdiColors.error, Color(0xFFDC2626)])
                        : const LinearGradient(colors: [OdiColors.coral, OdiColors.sunset]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? OdiColors.error : OdiColors.coral).withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic_rounded, color: Colors.white, size: 30),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulseRing(int index) {
    final delay = index * 0.5;
    final t = (_waveController.value + delay) % 1.0;
    final size = 64 + t * 40.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: OdiColors.coral.withValues(alpha: (1 - t) * 0.4),
          width: 1.5,
        ),
      ),
    );
  }
}
