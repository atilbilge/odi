import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notion_sync_service.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/database/database_service.dart';
import '../../core/theme/app_theme.dart';
import '../practice/practice_screen.dart';
import 'home_screen.dart';

class LessonPlanTab extends ConsumerStatefulWidget {
  const LessonPlanTab({super.key});

  @override
  ConsumerState<LessonPlanTab> createState() => _LessonPlanTabState();
}

class _LessonPlanTabState extends ConsumerState<LessonPlanTab> {
  bool _isSyncing = false;
  bool _isDownloadingRemaining = false;

  Future<void> _downloadRemainingLessons() async {
    if (_isDownloadingRemaining) return;
    setState(() => _isDownloadingRemaining = true);

    final db = ref.read(databaseServiceProvider);
    final result = await db.downloadRemainingLessons();

    if (mounted) {
      setState(() => _isDownloadingRemaining = false);
      ref.invalidate(lessonsProvider);
      ref.invalidate(lessonsWithStatsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.lessonsAdded > 0
                ? '${result.lessonsAdded} lessons and ${result.wordsAdded} words downloaded!'
                : 'All 40 lessons are already downloaded.',
          ),
          backgroundColor: OdiColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _resetToFirstFive() async {
    final db = ref.read(databaseServiceProvider);
    await db.seedCurriculumIfNeeded(force: true);
    ref.invalidate(lessonsProvider);
    ref.invalidate(lessonsWithStatsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reset to the first 5 core lessons (75 words).'),
          backgroundColor: OdiColors.ocean,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _syncFromNotion() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    final result = await ref.read(notionSyncServiceProvider).sync();
    if (mounted) {
      setState(() => _isSyncing = false);
      ref.invalidate(lessonsProvider);
      ref.invalidate(lessonsWithStatsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.isSuccess
                ? '${result.lessonsAdded} lessons added, ${result.wordsAdded} words added.'
                : result.error ?? 'Sync error',
          ),
          backgroundColor: result.isSuccess ? OdiColors.success : OdiColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showDownloadSheet(BuildContext context, int currentLessonCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: OdiColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: OdiColors.midGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Curriculum & Sync', style: OdiTextStyles.h2),
                const SizedBox(height: 4),
                Text('Download remaining lessons or sync with Notion', style: OdiTextStyles.body2),
                const SizedBox(height: 20),

                if (currentLessonCount < 40) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: OdiColors.ocean.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.download_rounded, color: OdiColors.ocean),
                    ),
                    title: Text('Download Remaining Lessons',
                        style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text('Download lessons ${currentLessonCount + 1} to 40 (${40 - currentLessonCount} lessons)',
                        style: OdiTextStyles.caption),
                    trailing: const Icon(Icons.chevron_right_rounded, color: OdiColors.midGrey),
                    onTap: () {
                      Navigator.pop(ctx);
                      _downloadRemainingLessons();
                    },
                  ),
                  const Divider(height: 16),
                ],

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: OdiColors.coral.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.refresh_rounded, color: OdiColors.coral),
                  ),
                  title: Text('Reset to First 5 Lessons',
                      style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Keep only the first 5 core topics (75 words)',
                      style: TextStyle(color: OdiColors.midGrey, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: OdiColors.midGrey),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _resetToFirstFive();
                  },
                ),
                const Divider(height: 16),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: OdiColors.deepSea.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cloud_sync_rounded, color: OdiColors.deepSea),
                  ),
                  title: Text('Sync from Notion Workspace',
                      style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Sync database courses directly using your Notion token',
                      style: TextStyle(color: OdiColors.midGrey, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: OdiColors.midGrey),
                  onTap: () {
                    Navigator.pop(ctx);
                    _syncFromNotion();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDownloadBanner(int remainingCount) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: OdiColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OdiColors.ocean.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: OdiColors.ocean.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: OdiColors.ocean.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.download_rounded, color: OdiColors.ocean, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'More Lessons Available',
                      style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$remainingCount more lessons (525 words) ready to download',
                      style: OdiTextStyles.caption.copyWith(color: OdiColors.midGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _isDownloadingRemaining ? null : _downloadRemainingLessons,
              icon: _isDownloadingRemaining
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_download_rounded, size: 20),
              label: Text(
                _isDownloadingRemaining
                    ? 'Downloading Lessons...'
                    : 'Download Remaining Lessons ($remainingCount)',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: OdiColors.ocean,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessonsAsync = ref.watch(lessonsWithStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
          color: OdiColors.cardWhite,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lesson Plan', style: OdiTextStyles.h2),
                    const SizedBox(height: 4),
                    Text('Your Serbian learning journey', style: OdiTextStyles.body2),
                  ],
                ),
              ),
              (_isSyncing || _isDownloadingRemaining)
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: OdiColors.ocean,
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Download & Sync',
                      icon: const Icon(Icons.cloud_download_rounded, color: OdiColors.ocean, size: 26),
                      onPressed: () {
                        final currentCount = lessonsAsync.valueOrNull?.length ?? 0;
                        _showDownloadSheet(context, currentCount);
                      },
                    ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ── Lesson List ──────────────────────────────────────────────────
        Expanded(
          child: lessonsAsync.when(
            data: (lessonsWithStats) {
              if (lessonsWithStats.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: OdiColors.ocean.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_download_rounded, color: OdiColors.ocean, size: 48),
                        ),
                        const SizedBox(height: 20),
                        Text('No lessons loaded yet', style: OdiTextStyles.h3.copyWith(color: OdiColors.midGrey)),
                        const SizedBox(height: 8),
                        Text(
                          'Tap below to load the core lessons.',
                          style: OdiTextStyles.body2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _resetToFirstFive,
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Load First 5 Lessons'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OdiColors.ocean,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final hasRemaining = lessonsWithStats.length < 40;
              final itemCount = lessonsWithStats.length + (hasRemaining ? 1 : 0);

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == lessonsWithStats.length) {
                    return _buildDownloadBanner(40 - lessonsWithStats.length);
                  }

                  final stat = lessonsWithStats[index];
                  final lesson = stat.lesson;

                  return GestureDetector(
                    onTap: () => _startPractice(context, lesson.id),
                    onLongPress: () => _showDeleteDialog(context, lesson.id, lesson.title),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: OdiDecorations.card(radius: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lesson.title,
                                      style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    if (lesson.description.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        lesson.description,
                                        style: OdiTextStyles.body2.copyWith(height: 1.3),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.play_circle_outline_rounded,
                                color: lesson.isCompleted ? OdiColors.success : OdiColors.coral,
                                size: 28,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(height: 1, thickness: 0.5, color: OdiColors.midGrey.withValues(alpha: 0.15)),
                          const SizedBox(height: 10),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              if (lesson.isCompleted) ...[
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: OdiColors.success,
                                ),
                                Text(
                                  'Completed',
                                  style: OdiTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: OdiColors.success,
                                  ),
                                ),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: OdiColors.midGrey.withValues(alpha: 0.4),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              Icon(
                                Icons.bookmark_added_outlined,
                                size: 14,
                                color: stat.learnedWords > 0 ? OdiColors.success : OdiColors.midGrey,
                              ),
                              Text(
                                '${stat.learnedWords} Learned',
                                style: OdiTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: stat.learnedWords > 0 ? OdiColors.success : OdiColors.midGrey,
                                ),
                              ),
                              const Icon(
                                Icons.list_alt_rounded,
                                size: 14,
                                color: OdiColors.midGrey,
                              ),
                              Text(
                                '${stat.totalWords} Total',
                                style: OdiTextStyles.caption,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: OdiColors.coral)),
            error: (err, _) => Center(
              child: Text('Error: $err', style: OdiTextStyles.body2.copyWith(color: OdiColors.error)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startPractice(BuildContext context, int lessonId) async {
    final db = ref.read(databaseServiceProvider);
    
    final pendingCount = await db.getPendingReviewCount();
    if (pendingCount >= 15) {
      if (!context.mounted) return;
      _showSoftLockBottomSheet(context);
      return;
    }

    final settingsNotifier = ref.read(settingsProvider.notifier);
    await settingsNotifier.loadSettings();
    
    await ref.read(speechServiceProvider).initialize(selectedVoice: 'native');
    
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PracticeScreen(selectedLessonId: lessonId),
      ),
    );

    if (context.mounted) {
      ref.invalidate(lessonsWithStatsProvider);
      ref.read(progressNotifierProvider.notifier).refresh();
    }
  }

  Future<void> _startSmartReview(BuildContext context) async {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    await settingsNotifier.loadSettings();
    
    await ref.read(speechServiceProvider).initialize(selectedVoice: 'native');
    
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PracticeScreen(selectedLessonId: null),
      ),
    );

    if (context.mounted) {
      ref.invalidate(lessonsWithStatsProvider);
      ref.read(progressNotifierProvider.notifier).refresh();
    }
  }

  void _showSoftLockBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: OdiColors.ocean.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: OdiColors.ocean,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Review Time!',
                      style: OdiTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Let\'s review pending words before moving on to new lessons.',
                  style: OdiTextStyles.body1.copyWith(
                    color: OdiColors.anthracite,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete Smart Review to strengthen your memory.',
                  style: OdiTextStyles.body2.copyWith(
                    color: OdiColors.midGrey,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _startSmartReview(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OdiColors.ocean,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Start Smart Review',
                      style: OdiTextStyles.button.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, int lessonId, String lessonTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OdiColors.cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Lesson', style: OdiTextStyles.h3),
        content: Text(
          'Are you sure you want to delete "$lessonTitle"? All vocabulary and progress for this lesson will be permanently removed.',
          style: OdiTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: OdiTextStyles.body2.copyWith(color: OdiColors.midGrey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = ref.read(databaseServiceProvider);
              await db.deleteLesson(lessonId);
              
              ref.invalidate(lessonsProvider);
              ref.invalidate(lessonsWithStatsProvider);
              
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Lesson deleted successfully.'),
                    backgroundColor: OdiColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: OdiColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete', style: OdiTextStyles.button),
          ),
        ],
      ),
    );
  }
}
