import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database_service.dart';
import '../../core/database/models/vocabulary.dart';
import '../../core/database/models/lesson.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/settings_service.dart';
import '../home/home_screen.dart';
import 'models/exercise.dart';
import 'services/exercise_generator.dart';
import 'widgets/exercise_intro_view.dart';
import 'widgets/exercise_matching_view.dart';
import 'widgets/exercise_writing_view.dart';
import 'widgets/exercise_fill_blank_view.dart';
import 'widgets/exercise_quiz_view.dart';
import 'widgets/exercise_speaking_view.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final int? selectedLessonId;
  const PracticeScreen({super.key, this.selectedLessonId});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  // Stages: 1 = Discovery / Flashcard, 2 = Interactive Exercises
  int _currentStage = 1;
  bool _isLoading = true;
  String _lessonTitle = '';

  List<Vocabulary> _vocabList = [];
  List<Vocabulary> _poolVocab = [];
  final Set<int> _smartReviewWordIds = {};

  List<Exercise> _exercises = [];
  int _currentExerciseIndex = 0;
  int _correctCount = 0;

  bool _autoPlayAudio = true;

  late final DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _autoPlayAudio = ref.read(settingsProvider).autoPlayAudio;
    _loadVocabulary();
  }

  void _toggleAutoPlay() {
    final updated = !_autoPlayAudio;
    setState(() {
      _autoPlayAudio = updated;
    });
    ref.read(settingsProvider.notifier).updateAutoPlayAudio(updated);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated ? 'Auto-play audio is now ON' : 'Auto-play audio is now OFF',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<Vocabulary> _processVocabularyDynamics(List<Vocabulary> originalList, UserSettings settings) {
    return originalList.map((v) {
      final copy = Vocabulary()
        ..id = v.id
        ..lessonId = v.lessonId
        ..serbianText = v.serbianText
        ..turkishText = v.turkishText
        ..englishText = v.englishText
        ..wordType = v.wordType
        ..successRate = v.successRate
        ..lastPracticedDate = v.lastPracticedDate;

      // 1. Name dynamics: Replace "Atil" (case insensitive) with settings.userName
      final nameReg = RegExp(r'\bAtil\b', caseSensitive: false);
      copy.serbianText = copy.serbianText.replaceAll(nameReg, settings.userName);
      copy.turkishText = copy.turkishText.replaceAll(nameReg, settings.userName);
      if (copy.englishText != null) {
        copy.englishText = copy.englishText!.replaceAll(nameReg, settings.userName);
      }

      // 2. Gender dynamics: If gender is Kadın / Female, translate masculine adjectives/verbs to feminine
      if (settings.userGender == 'Kadın' || settings.userGender == 'Female') {
        final replacements = {
          'bio sam': 'bila sam',
          'umoran sam': 'umorna sam',
          'srećan sam': 'srećna sam',
          'sretan sam': 'sretna sam',
          'rođen sam': 'rođena sam',
          'zaposlen sam': 'zaposlena sam',
          r'\bbio\b': 'bila',
          r'\bumoran\b': 'umorna',
          r'\bsrećan\b': 'srećna',
          r'\bsretan\b': 'sretna',
          r'\brođen\b': 'rođena',
        };

        replacements.forEach((key, val) {
          if (key.startsWith(r'\b')) {
            copy.serbianText = copy.serbianText.replaceAll(RegExp(key, caseSensitive: false), val);
          } else {
            copy.serbianText = copy.serbianText.replaceAll(RegExp(r'\b' + key + r'\b', caseSensitive: false), val);
          }
        });
      }

      return copy;
    }).toList();
  }

  Future<void> _loadVocabulary() async {
    final db = ref.read(databaseServiceProvider);
    List<Vocabulary> vocab = [];
    String title = 'Smart Review';
    final Set<int> smartReviewWordIds = {};

    if (widget.selectedLessonId != null) {
      final lesson = await db.isar.collection<Lesson>().get(widget.selectedLessonId!);
      if (lesson != null) {
        title = lesson.title;
      }

      // 1. Fetch current lesson vocabulary
      var lessonVocab = await db.getVocabularyForLesson(widget.selectedLessonId!);

      final orderType = lesson?.orderType ?? 'Random';
      if (orderType == 'Ascending') {
        lessonVocab.sort((a, b) => a.id.compareTo(b.id));
      } else if (orderType == 'Descending') {
        lessonVocab.sort((a, b) => b.id.compareTo(a.id));
      } else {
        lessonVocab.shuffle();
      }

      // 2. Fetch pending review words (warm-up)
      final pending = await db.getPendingReviewWords();
      final allCustom = await db.getCustomVocabulary();
      final unlearnedCustom = allCustom.where((v) => !v.isLearned).toList();

      final List<Vocabulary> combinedPending = [...pending, ...unlearnedCustom];
      combinedPending.sort((a, b) => a.successRate.compareTo(b.successRate));

      var pendingUnique = combinedPending.where((p) => !lessonVocab.any((lv) => lv.id == p.id)).toList();
      if (pendingUnique.length > 1) {
        pendingUnique = pendingUnique.sublist(0, 1);
      }

      for (final p in pendingUnique) {
        smartReviewWordIds.add(p.id);
      }

      vocab = [...pendingUnique, ...lessonVocab];
    } else {
      // Smart Review
      final pending = await db.getPendingReviewWords();
      final allCustom = await db.getCustomVocabulary();
      final unlearnedCustom = allCustom.where((v) => !v.isLearned).toList();

      final List<Vocabulary> combined = [...pending, ...unlearnedCustom];

      if (combined.isNotEmpty) {
        vocab = List.from(combined);
        for (final p in vocab) {
          smartReviewWordIds.add(p.id);
        }
        vocab.sort((a, b) => a.successRate.compareTo(b.successRate));
        if (vocab.length > 5) vocab = vocab.sublist(0, 5);
      } else {
        final lessons = await db.getAllLessons();
        final List<Vocabulary> allVocab = [];
        for (final l in lessons) {
          allVocab.addAll(await db.getVocabularyForLesson(l.id));
        }
        allVocab.addAll(await db.getCustomVocabulary());

        final allLearned = allVocab.where((v) => v.successRate >= 80.0).toList();
        vocab = List.from(allLearned);
        vocab.shuffle();
        if (vocab.length > 5) vocab = vocab.sublist(0, 5);
      }
    }

    final allLessons = await db.getAllLessons();
    final List<Vocabulary> pool = [];
    for (final l in allLessons) {
      pool.addAll(await db.getVocabularyForLesson(l.id));
    }

    final settings = ref.read(settingsProvider);
    final processedVocab = _processVocabularyDynamics(vocab, settings);
    final processedPool = _processVocabularyDynamics(pool, settings);

    if (mounted) {
      setState(() {
        _vocabList = processedVocab;
        _poolVocab = processedPool;
        _lessonTitle = title;
        _smartReviewWordIds.clear();
        _smartReviewWordIds.addAll(smartReviewWordIds);
        _isLoading = false;
      });
    }
  }

  void _startExercises() {
    final generator = ref.read(exerciseGeneratorProvider);
    final exercises = generator.generate(
      lessonVocab: _vocabList,
      poolVocab: _poolVocab,
    );

    setState(() {
      _exercises = exercises;
      _currentExerciseIndex = 0;
      _correctCount = 0;
      _currentStage = 2;
    });
  }

  Future<void> _onExerciseCompleted(Exercise exercise, {required bool isSuccess}) async {
    final score = isSuccess ? 100.0 : 40.0;
    await ref.read(databaseServiceProvider).updateVocabularyPractice(exercise.vocabId, score);

    if (isSuccess) {
      _correctCount++;
    }

    _advanceNextExercise();
  }

  Future<void> _onExerciseSkipped(Exercise exercise) async {
    await ref.read(databaseServiceProvider).updateVocabularyPractice(exercise.vocabId, 0.0);
    _advanceNextExercise();
  }

  void _advanceNextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    } else {
      _completeSession();
    }
  }

  Future<void> _completeSession() async {
    final progressNotifier = ref.read(progressNotifierProvider.notifier);
    final durationSeconds = DateTime.now().difference(_startTime).inSeconds;
    final durationMinutes = (durationSeconds / 60).ceil();

    await progressNotifier.addMinutes(durationMinutes);
    await progressNotifier.addWords(_vocabList.length);

    if (widget.selectedLessonId != null) {
      await ref.read(databaseServiceProvider).markLessonCompleted(widget.selectedLessonId!);
      await progressNotifier.addLessonCompleted();
      ref.invalidate(lessonsProvider);
    }

    if (mounted) {
      final settings = ref.read(settingsProvider);
      final currentProgress = ref.read(progressNotifierProvider);
      final bool isGoalMet =
          currentProgress.minutesSpent >= settings.dailyGoalMinutes || currentProgress.lessonsCompleted >= 1;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: OdiColors.cardWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Text(isGoalMet ? '🎯' : '💪', style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              Text(isGoalMet ? 'Congratulations!' : 'Awesome!', style: OdiTextStyles.h3),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGoalMet
                    ? 'You\'ve reached your daily practice goal! Outstanding job.'
                    : 'Session completed! Keep practicing to reach your daily goal.',
                style: OdiTextStyles.body1,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: OdiColors.ocean.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: OdiColors.coral, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Score: $_correctCount / ${_exercises.length} Correct',
                      style: OdiTextStyles.body2.copyWith(fontWeight: FontWeight.bold, color: OdiColors.deepSea),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OdiColors.coral,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Back to Home', style: OdiTextStyles.button.copyWith(color: Colors.white)),
            ),
          ],
        ),
      );
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
        backgroundColor: OdiColors.cardWhite,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentStage == 1 ? 'Stage 1: Word Discovery' : 'Stage 2: Exercises',
              style: OdiTextStyles.h3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              _lessonTitle,
              style: OdiTextStyles.caption.copyWith(
                color: OdiColors.midGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: OdiColors.anthracite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Instant Auto-speak toggle button in top AppBar
          IconButton(
            icon: Icon(
              _autoPlayAudio ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: _autoPlayAudio ? OdiColors.coral : OdiColors.midGrey,
            ),
            tooltip: _autoPlayAudio ? 'Auto-play audio is ON' : 'Auto-play audio is OFF',
            onPressed: _toggleAutoPlay,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _currentStage == 1
                    ? '${_vocabList.length} Words'
                    : '${_currentExerciseIndex + 1}/${_exercises.length}',
                style: OdiTextStyles.label.copyWith(color: OdiColors.coral, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProgressBar(),
              const SizedBox(height: 20),
              Expanded(
                child: _currentStage == 1
                    ? ExerciseIntroView(
                        vocabList: _vocabList,
                        smartReviewWordIds: _smartReviewWordIds,
                        onStartExercises: _startExercises,
                      )
                    : _buildCurrentExercise(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = 0.0;
    if (_currentStage == 1) {
      progress = 0.05;
    } else if (_exercises.isNotEmpty) {
      progress = (_currentExerciseIndex + 1) / _exercises.length;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: OdiColors.border,
        valueColor: const AlwaysStoppedAnimation<Color>(OdiColors.coral),
      ),
    );
  }

  Widget _buildCurrentExercise() {
    if (_exercises.isEmpty || _currentExerciseIndex >= _exercises.length) {
      return const SizedBox();
    }

    final exercise = _exercises[_currentExerciseIndex];
    final key = ValueKey('ex_$_currentExerciseIndex');

    switch (exercise.type) {
      case ExerciseType.matching:
        return ExerciseMatchingView(
          key: key,
          exercise: exercise as MatchingExercise,
          autoPlayAudio: _autoPlayAudio,
          onToggleAutoPlay: _toggleAutoPlay,
          onCompleted: (isSuccess) => _onExerciseCompleted(exercise, isSuccess: isSuccess),
          onSkip: () => _onExerciseSkipped(exercise),
        );
      case ExerciseType.quiz:
        return ExerciseQuizView(
          key: key,
          exercise: exercise as QuizExercise,
          autoPlayAudio: _autoPlayAudio,
          onToggleAutoPlay: _toggleAutoPlay,
          onCompleted: (isSuccess) => _onExerciseCompleted(exercise, isSuccess: isSuccess),
          onSkip: () => _onExerciseSkipped(exercise),
        );
      case ExerciseType.fillBlank:
        return ExerciseFillBlankView(
          key: key,
          exercise: exercise as FillBlankExercise,
          autoPlayAudio: _autoPlayAudio,
          onToggleAutoPlay: _toggleAutoPlay,
          onCompleted: (isSuccess) => _onExerciseCompleted(exercise, isSuccess: isSuccess),
          onSkip: () => _onExerciseSkipped(exercise),
        );
      case ExerciseType.writing:
        return ExerciseWritingView(
          key: key,
          exercise: exercise as WritingExercise,
          autoPlayAudio: _autoPlayAudio,
          onToggleAutoPlay: _toggleAutoPlay,
          onCompleted: (isSuccess) => _onExerciseCompleted(exercise, isSuccess: isSuccess),
          onSkip: () => _onExerciseSkipped(exercise),
        );
      case ExerciseType.speaking:
        return ExerciseSpeakingView(
          key: key,
          exercise: exercise as SpeakingExercise,
          onCompleted: (isSuccess) => _onExerciseCompleted(exercise, isSuccess: isSuccess),
          onSkip: () => _onExerciseSkipped(exercise),
        );
    }
  }
}
