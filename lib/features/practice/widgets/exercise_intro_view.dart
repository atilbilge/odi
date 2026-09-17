import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/models/vocabulary.dart';
import '../../../core/services/speech_service.dart';
import '../../../core/theme/app_theme.dart';

class ExerciseIntroView extends ConsumerStatefulWidget {
  final List<Vocabulary> vocabList;
  final Set<int> smartReviewWordIds;
  final VoidCallback onStartExercises;

  const ExerciseIntroView({
    super.key,
    required this.vocabList,
    required this.smartReviewWordIds,
    required this.onStartExercises,
  });

  @override
  ConsumerState<ExerciseIntroView> createState() => _ExerciseIntroViewState();
}

class _ExerciseIntroViewState extends ConsumerState<ExerciseIntroView> {
  int? _playingIndex;

  Future<void> _speak(String text, int index) async {
    setState(() => _playingIndex = index);
    try {
      await ref.read(speechServiceProvider).speak(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio playback error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _playingIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: OdiColors.ocean.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: OdiColors.ocean.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: OdiColors.ocean.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_outline_rounded, color: OdiColors.deepSea, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Word Discovery',
                      style: OdiTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: OdiColors.deepSea,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Review the words and meanings, tap the speaker icon to listen.',
                      style: OdiTextStyles.caption.copyWith(color: OdiColors.anthracite),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Vocabulary Cards List
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: widget.vocabList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final vocab = widget.vocabList[index];
              final isPlaying = _playingIndex == index;
              final isSmartReview = widget.smartReviewWordIds.contains(vocab.id);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isPlaying ? OdiColors.coral.withValues(alpha: 0.06) : OdiColors.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPlaying ? OdiColors.coral.withValues(alpha: 0.4) : OdiColors.border,
                    width: isPlaying ? 1.5 : 1,
                  ),
                  boxShadow: OdiDecorations.subtleShadow,
                ),
                child: Row(
                  children: [
                    // Audio Button
                    InkWell(
                      onTap: () => _speak(vocab.serbianText, index),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: isPlaying
                              ? const LinearGradient(colors: [OdiColors.coral, OdiColors.sunset])
                              : null,
                          color: isPlaying ? null : OdiColors.lightGrey,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPlaying ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                          color: isPlaying ? Colors.white : OdiColors.ocean,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Serbian & Meaning Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vocab.serbianText,
                                  style: OdiTextStyles.body1.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isPlaying ? OdiColors.coral : OdiColors.anthracite,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              if (vocab.wordType != null && vocab.wordType!.isNotEmpty) ...[
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: OdiColors.deepSea.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    vocab.wordType!,
                                    style: OdiTextStyles.caption.copyWith(
                                      color: OdiColors.deepSea,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                              if (isSmartReview)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: OdiColors.ocean.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.auto_awesome_rounded, color: OdiColors.deepSea, size: 10),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Review',
                                        style: OdiTextStyles.caption.copyWith(
                                          color: OdiColors.deepSea,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vocab.displayMeaning,
                            style: OdiTextStyles.body2.copyWith(
                              color: OdiColors.anthracite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Action Button: Start Practice
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: widget.onStartExercises,
            style: ElevatedButton.styleFrom(
              backgroundColor: OdiColors.coral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Start Practice',
                  style: OdiTextStyles.button.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
