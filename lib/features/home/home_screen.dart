import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/lesson.dart';
import '../../core/theme/app_theme.dart';
import '../vocabulary/wordbook_screen.dart';
import 'dashboard_tab.dart';
import 'lesson_plan_tab.dart';

class ProgressState {
  final int minutesSpent;
  final int wordsLearned;
  final int lessonsCompleted;
  ProgressState({
    required this.minutesSpent,
    required this.wordsLearned,
    required this.lessonsCompleted,
  });
}

class ProgressNotifier extends StateNotifier<ProgressState> {
  final DatabaseService _db;
  ProgressNotifier(this._db) : super(ProgressState(minutesSpent: 0, wordsLearned: 0, lessonsCompleted: 0)) {
    refresh();
  }

  Future<void> refresh() async {
    final prog = await _db.getOrCreateDailyProgress(DateTime.now());
    state = ProgressState(
      minutesSpent: prog.minutesSpent,
      wordsLearned: prog.wordsLearned,
      lessonsCompleted: prog.lessonsCompleted,
    );
  }

  Future<void> addMinutes(int mins) async {
    await _db.incrementDailyMinutes(mins);
    await refresh();
  }

  Future<void> addWords(int count) async {
    await _db.incrementDailyWordsLearned(count);
    await refresh();
  }

  Future<void> addLessonCompleted() async {
    await _db.incrementDailyLessonsCompleted();
    await refresh();
  }
}

final progressNotifierProvider = StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return ProgressNotifier(db);
});

final lessonsProvider = FutureProvider<List<Lesson>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getAllLessons();
});

final lessonsWithStatsProvider = FutureProvider<List<LessonWithStats>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getLessonsWithStats();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const LessonPlanTab(),
    const WordbookScreen(isTab: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OdiColors.lightGrey,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: OdiColors.cardWhite,
          border: Border(
            top: BorderSide(color: OdiColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A2A2D34),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: Colors.transparent,
            selectedItemColor: OdiColors.coral,
            unselectedItemColor: OdiColors.midGrey,
            selectedLabelStyle: OdiTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: OdiColors.coral,
            ),
            unselectedLabelStyle: OdiTextStyles.caption,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book_rounded),
                label: 'Lessons',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.collections_bookmark_outlined),
                activeIcon: Icon(Icons.collections_bookmark_rounded),
                label: 'Wordbook',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
