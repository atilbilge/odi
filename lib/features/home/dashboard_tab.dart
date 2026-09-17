import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/daily_progress.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/speech_service.dart';
import '../../core/theme/app_theme.dart';
import '../practice/practice_screen.dart';
import '../progress/progress_screen.dart';
import 'settings_screen.dart';
import 'home_screen.dart';

class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
  List<DailyProgress> _weeklyProgress = [];
  bool _isLoadingWeekly = true;

  @override
  void initState() {
    super.initState();
    _loadWeeklyProgress();
  }

  Future<void> _loadWeeklyProgress() async {
    try {
      final db = ref.read(databaseServiceProvider);
      final weekly = await db.getWeeklyProgress();
      if (mounted) {
        setState(() {
          _weeklyProgress = weekly;
          _isLoadingWeekly = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingWeekly = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(progressNotifierProvider);
    final settings = ref.watch(settingsProvider);
    final lessonsAsync = ref.watch(lessonsWithStatsProvider);

    final int dailyGoalMinutes = settings.dailyGoalMinutes;
    final double progressPercent = (progressState.minutesSpent / dailyGoalMinutes).clamp(0.0, 1.0);

    final completedCount = lessonsAsync.value?.where((l) => l.lesson.isCompleted).length ?? 0;
    final bool isSmartReviewEnabled = completedCount >= 1;
    final bool isDayGoalMet = progressState.minutesSpent >= dailyGoalMinutes || progressState.lessonsCompleted >= 1;

    ref.listen(progressNotifierProvider, (prev, next) => _loadWeeklyProgress());

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with brand gradient ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 28),
            decoration: const BoxDecoration(
              gradient: OdiColors.brandGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Odi', style: OdiTextStyles.h1.copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        'Serbian Practice with Echo',
                        style: OdiTextStyles.body2.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const SettingsScreen()))
                      .then((_) => setState(() {})),
                  icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 26),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Daily Goal Card ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: OdiDecorations.card(radius: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Daily Goal', style: OdiTextStyles.h3),
                                const SizedBox(height: 6),
                                Text(
                                  isDayGoalMet
                                      ? 'Awesome! You reached today\'s goal 🎯'
                                      : 'Complete either time or lesson goal.',
                                  style: OdiTextStyles.body2.copyWith(
                                    color: isDayGoalMet ? OdiColors.success : OdiColors.midGrey,
                                    fontWeight: isDayGoalMet ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Time progress title
                                Text(
                                  'Time Goal: ${progressState.minutesSpent} / $dailyGoalMinutes min',
                                  style: OdiTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                // Time Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: progressPercent,
                                    minHeight: 8,
                                    backgroundColor: OdiColors.lightGrey,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      progressState.minutesSpent >= dailyGoalMinutes ? OdiColors.success : OdiColors.coral,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Circular progress (Day Goal - Unified)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 88,
                                height: 88,
                                child: CircularProgressIndicator(
                                  value: isDayGoalMet ? 1.0 : progressPercent,
                                  strokeWidth: 8,
                                  backgroundColor: OdiColors.lightGrey,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDayGoalMet ? OdiColors.success : OdiColors.coral,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isDayGoalMet ? 'Done' : '%${(progressPercent * 100).toInt()}',
                                    style: OdiTextStyles.h3.copyWith(
                                      color: isDayGoalMet ? OdiColors.success : OdiColors.coral,
                                      fontSize: isDayGoalMet ? 13 : 16,
                                    ),
                                  ),
                                  Text(
                                    isDayGoalMet ? '🎯' : 'done',
                                    style: OdiTextStyles.caption.copyWith(
                                      fontSize: isDayGoalMet ? 12 : 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildMiniStat(
                            icon: Icons.school_rounded,
                            label: 'Lesson Goal',
                            value: progressState.lessonsCompleted >= 1
                                ? '${progressState.lessonsCompleted} lessons ✓'
                                : '0 / 1 lesson',
                            achieved: progressState.lessonsCompleted >= 1,
                          ),
                          const SizedBox(width: 12),
                          _buildMiniStat(
                            icon: Icons.local_fire_department_rounded,
                            label: 'Day Goal',
                            value: isDayGoalMet ? 'Achieved ✓' : 'In progress',
                            achieved: isDayGoalMet,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // ── CTA Row: Next Lesson & Smart Review ────────────────────
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _buildCtaCard(
                          title: isDayGoalMet ? 'Next Lesson' : 'Daily Lesson',
                          subtitle: 'Continue curriculum',
                          icon: Icons.school_rounded,
                          colors: [OdiColors.coral, OdiColors.sunset],
                          onTap: () => _startPractice(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildCtaCard(
                          title: 'Smart Review',
                          subtitle: 'Active word review',
                          icon: Icons.auto_awesome_rounded,
                          colors: isSmartReviewEnabled
                              ? [OdiColors.ocean, OdiColors.deepSea]
                              : [OdiColors.midGrey.withValues(alpha: 0.4), OdiColors.midGrey.withValues(alpha: 0.5)],
                          onTap: isSmartReviewEnabled
                              ? () => _startSmartReview(context)
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Complete at least one lesson to unlock Smart Review.'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                          isEnabled: isSmartReviewEnabled,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Weekly Summary ───────────────────────────────────────────
                Text('Weekly Activity', style: OdiTextStyles.h3),
                const SizedBox(height: 12),
                _isLoadingWeekly
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: OdiColors.coral),
                        ),
                      )
                    : _buildWeeklyStatusRow(dailyGoalMinutes),
                const SizedBox(height: 24),

                // ── Progress Report Link ─────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: OdiDecorations.card(radius: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [OdiColors.ocean, OdiColors.deepSea],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Detailed Progress Report', style: OdiTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text('View learned words and statistics', style: OdiTextStyles.body2),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: OdiColors.midGrey),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatusRow(int dailyGoalMinutes) {
    const englishDayAbbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) =>
        DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: OdiDecorations.card(radius: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: last7Days.map((day) {
          final progress = _weeklyProgress.firstWhere(
            (p) => p.date.year == day.year && p.date.month == day.month && p.date.day == day.day,
            orElse: () => DailyProgress()
              ..date = day
              ..minutesSpent = 0
              ..wordsLearned = 0,
          );
          final isGoalMet = progress.minutesSpent >= dailyGoalMinutes;
          final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
          final hasPartial = progress.minutesSpent > 0 && !isGoalMet;
          final dayName = englishDayAbbr[day.weekday - 1];

          return Column(
            children: [
              Text(
                dayName,
                style: OdiTextStyles.caption.copyWith(
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  color: isToday ? OdiColors.coral : OdiColors.midGrey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isGoalMet
                      ? OdiColors.success.withValues(alpha: 0.12)
                      : (hasPartial
                          ? OdiColors.warning.withValues(alpha: 0.10)
                          : OdiColors.lightGrey),
                  shape: BoxShape.circle,
                  border: isToday
                      ? Border.all(color: OdiColors.coral, width: 2)
                      : null,
                ),
                child: Center(
                  child: Icon(
                    isGoalMet
                        ? Icons.check_rounded
                        : (hasPartial ? Icons.timelapse_rounded : Icons.circle_outlined),
                    size: 16,
                    color: isGoalMet
                        ? OdiColors.success
                        : (hasPartial ? OdiColors.warning : OdiColors.border),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _startPractice(BuildContext context) async {
    final db = ref.read(databaseServiceProvider);
    
    // Threshold Check: Block lesson entry if pending reviews >= 15
    final pendingCount = await db.getPendingReviewCount();
    if (pendingCount >= 15) {
      if (!context.mounted) return;
      _showSoftLockBottomSheet(context);
      return;
    }

    final settingsNotifier = ref.read(settingsProvider.notifier);
    await settingsNotifier.loadSettings();
    
    await ref.read(speechServiceProvider).initialize(selectedVoice: 'native');
    
    final lessons = await db.getAllLessons();
    
    int? targetLessonId;
    if (lessons.isNotEmpty) {
      try {
        final firstUncompleted = lessons.firstWhere((l) => !l.isCompleted);
        targetLessonId = firstUncompleted.id;
      } catch (_) {
        targetLessonId = null;
      }
    }

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PracticeScreen(selectedLessonId: targetLessonId),
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

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required bool achieved,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: achieved ? OdiColors.coral.withValues(alpha: 0.08) : OdiColors.lightGrey,
          borderRadius: BorderRadius.circular(12),
          border: achieved
              ? Border.all(color: OdiColors.coral.withValues(alpha: 0.25), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: achieved ? OdiColors.coral : OdiColors.midGrey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: OdiTextStyles.caption.copyWith(
                      color: OdiColors.midGrey,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: OdiTextStyles.caption.copyWith(
                      color: achieved ? OdiColors.coral : OdiColors.anthracite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: OdiTextStyles.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: OdiTextStyles.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isEnabled ? icon : Icons.lock_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
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
}
