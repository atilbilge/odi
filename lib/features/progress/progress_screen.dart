import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/daily_progress.dart';
import '../../core/theme/app_theme.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  List<DailyProgress> _weeklyProgress = [];
  int _totalWordsLearned = 0;
  int _totalMinutesSpent = 0;
  int _totalLessonsCompleted = 0;
  int _activeStreak = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final db = ref.read(databaseServiceProvider);
    final weekly = await db.getWeeklyProgress();
    final customVocab = await db.getCustomVocabulary();
    final lessons = await db.getAllLessons();
    final streak = await db.calculateActiveStreak();
    int totalWords = customVocab.length;
    for (final l in lessons) {
      final v = await db.getVocabularyForLesson(l.id);
      totalWords += v.where((item) => item.successRate >= 80.0).length;
    }
    int totalMins = 0;
    int totalLessons = 0;
    final allProgress = await db.isar.collection<DailyProgress>().where().findAll();
    for (final p in allProgress) {
      totalMins += p.minutesSpent;
      totalLessons += p.lessonsCompleted;
    }
    if (mounted) {
      setState(() {
        _weeklyProgress = weekly;
        _totalWordsLearned = totalWords;
        _totalMinutesSpent = totalMins;
        _totalLessonsCompleted = totalLessons;
        _activeStreak = streak;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: OdiColors.lightGrey,
        body: Center(child: CircularProgressIndicator(color: OdiColors.coral)),
      );
    }

    return Scaffold(
      backgroundColor: OdiColors.lightGrey,
      appBar: AppBar(
        title: Text('Progress Report', style: OdiTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats Row 1 ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _OdiStatCard(
                    title: 'Words Learned',
                    value: '$_totalWordsLearned',
                    icon: Icons.bookmark_added_rounded,
                    gradient: const LinearGradient(colors: [OdiColors.success, Color(0xFF25A869)]),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _OdiStatCard(
                    title: 'Total Time',
                    value: '$_totalMinutesSpent min',
                    icon: Icons.timer_rounded,
                    gradient: const LinearGradient(colors: [OdiColors.coral, OdiColors.sunset]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // ── Stats Row 2 ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _OdiStatCard(
                    title: 'Completed Lessons',
                    value: '$_totalLessonsCompleted lessons',
                    icon: Icons.school_rounded,
                    gradient: const LinearGradient(colors: [OdiColors.ocean, OdiColors.deepSea]),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _OdiStatCard(
                    title: 'Day Streak',
                    value: '$_activeStreak days 🔥',
                    icon: Icons.local_fire_department_rounded,
                    gradient: const LinearGradient(colors: [Color(0xFFFF9E00), Color(0xFFFF5200)]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Weekly Chart ───────────────────────────────────────────────
            Text('Weekly Practice Time', style: OdiTextStyles.h3),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: OdiDecorations.card(radius: 20),
              child: Column(
                children: [
                  _buildWeeklyBarChart(),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: OdiColors.ocean, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text('Lesson completed', style: OdiTextStyles.caption.copyWith(color: OdiColors.ocean)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: OdiColors.midGrey, size: 13),
                          const SizedBox(width: 4),
                          Text('Goal: 20 min practice + 1 lesson/day', style: OdiTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Motivational Banner ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [OdiColors.coral, OdiColors.ocean],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: OdiColors.coral.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Keep Going! 🎯', style: OdiTextStyles.h3.copyWith(color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(
                          'Practice speaking 20 minutes daily to master your Serbian pronunciation.',
                          style: OdiTextStyles.body2.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.insights_rounded, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart() {
    final today = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final d = today.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    const maxMins = 20.0;
    const maxBarHeight = 100.0;

    return SizedBox(
      height: 160,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: last7Days.map((date) {
          final progress = _weeklyProgress.firstWhere(
            (p) => DateTime(p.date.year, p.date.month, p.date.day) == date,
            orElse: () => DailyProgress()..date = date..minutesSpent = 0,
          );
          final mins = progress.minutesSpent;
          final ratio = (mins / maxMins).clamp(0.0, 1.2);
          final barHeight = (maxBarHeight * ratio).clamp(4.0, maxBarHeight + 20);
          final isGoalMet = mins >= 20;
          final isToday = date == DateTime(today.year, today.month, today.day);

          final hasLesson = progress.lessonsCompleted >= 1;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mins > 0 ? '$mins' : '',
                style: OdiTextStyles.caption.copyWith(
                  color: isGoalMet ? OdiColors.success : OdiColors.midGrey,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 18,
                height: barHeight,
                decoration: BoxDecoration(
                  gradient: isGoalMet
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [OdiColors.success, Color(0xFF25A869)],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: mins > 0
                              ? [OdiColors.coral.withValues(alpha: 0.7), OdiColors.coral.withValues(alpha: 0.4)]
                              : [OdiColors.border, OdiColors.border],
                        ),
                  borderRadius: BorderRadius.circular(6),
                  border: isToday ? Border.all(color: OdiColors.coral, width: 1.5) : null,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: hasLesson ? OdiColors.ocean : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getDayLabel(date),
                style: OdiTextStyles.caption.copyWith(
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  color: isToday ? OdiColors.coral : OdiColors.midGrey,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getDayLabel(DateTime date) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }
}

class _OdiStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const _OdiStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: OdiDecorations.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 16),
          Text(value, style: OdiTextStyles.h2.copyWith(color: OdiColors.anthracite)),
          const SizedBox(height: 4),
          Text(title, style: OdiTextStyles.body2),
        ],
      ),
    );
  }
}
