import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/daily_progress.dart';
import 'models/lesson.dart';
import 'models/vocabulary.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('DatabaseService is not initialized yet');
});

class DatabaseService {
  final Isar isar;

  DatabaseService(this.isar);

  static const int _schemaVersion = 2;

  static Future<DatabaseService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = dir.path;

    // Check stored schema version; if mismatch, delete old DB to avoid crash
    final versionFile = File('$dbPath/isar_schema_version.txt');
    int storedVersion = 0;
    if (await versionFile.exists()) {
      try {
        storedVersion = int.parse(await versionFile.readAsString());
      } catch (_) {}
    }

    if (storedVersion < _schemaVersion) {
      // Remove old Isar database files to prevent schema mismatch crash
      for (final ext in ['isar', 'isar.lock']) {
        final oldFile = File('$dbPath/default.$ext');
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
      await versionFile.writeAsString('$_schemaVersion');
    }

    final isarInstance = await Isar.open(
      [
        LessonSchema,
        VocabularySchema,
        DailyProgressSchema,
      ],
      directory: dbPath,
    );

    final service = DatabaseService(isarInstance);
    await service.seedCurriculumIfNeeded();
    return service;
  }

  Future<void> seedCurriculumIfNeeded({bool force = false}) async {
    final count = await isar.collection<Lesson>().count();
    final firstLesson = await isar.collection<Lesson>().where().findFirst();
    final bool isOldMock = firstLesson != null && firstLesson.title == 'Selamlaşma ve Vedalaşma';

    if (count > 0 && !force && !isOldMock) {
      return; // Already seeded with valid curriculum
    }

    try {
      final jsonString = await rootBundle.loadString('assets/curriculum.json');
      final List<dynamic> data = json.decode(jsonString);

      await isar.writeTxn(() async {
        if (force || isOldMock) {
          await isar.collection<Lesson>().clear();
          await isar.collection<Vocabulary>().filter().lessonIdIsNotNull().deleteAll();
        }

        for (var lessonData in data) {
          final lesson = Lesson()
            ..title = lessonData['title']
            ..description = lessonData['description'] ?? ''
            ..isCompleted = false
            ..order = lessonData['order'] ?? 1;

          await isar.collection<Lesson>().put(lesson);

          final List<dynamic> vocabList = lessonData['vocabulary'] ?? [];
          for (var vocabData in vocabList) {
            final vocab = Vocabulary()
              ..lessonId = lesson.id
              ..serbianText = vocabData['serbianText']
              ..turkishText = vocabData['turkishText']
              ..englishText = vocabData['englishText']
              ..wordType = vocabData['wordType']
              ..successRate = 0.0;
            await isar.collection<Vocabulary>().put(vocab);
          }
        }
      });
    } catch (e) {
      print('Failed to seed curriculum: $e');
    }
  }

  /// Downloads/imports remaining lessons (courses 6-40) from the complete curriculum asset.
  Future<({int lessonsAdded, int wordsAdded})> downloadRemainingLessons() async {
    try {
      final jsonString = await rootBundle.loadString('assets/course_words_all.json');
      final List<dynamic> data = json.decode(jsonString);

      int lessonsAdded = 0;
      int wordsAdded = 0;

      final existingLessons = await isar.collection<Lesson>().where().findAll();
      final existingTitles = existingLessons.map((l) => l.title.trim().toLowerCase()).toSet();
      final existingOrders = existingLessons.map((l) => l.order).toSet();

      await isar.writeTxn(() async {
        for (var lessonData in data) {
          final int order = (lessonData['order'] as num).toInt();
          final String title = lessonData['title'] as String;

          // Skip if already present in database
          if (existingOrders.contains(order) || existingTitles.contains(title.trim().toLowerCase())) {
            continue;
          }

          final lesson = Lesson()
            ..title = title
            ..description = lessonData['description'] ?? ''
            ..isCompleted = false
            ..order = order;

          await isar.collection<Lesson>().put(lesson);
          lessonsAdded++;

          final List<dynamic> vocabList = lessonData['vocabulary'] ?? [];
          for (var vocabData in vocabList) {
            final vocab = Vocabulary()
              ..lessonId = lesson.id
              ..serbianText = vocabData['serbianText']
              ..turkishText = vocabData['turkishText']
              ..englishText = vocabData['englishText']
              ..wordType = vocabData['wordType']
              ..successRate = 0.0;
            await isar.collection<Vocabulary>().put(vocab);
            wordsAdded++;
          }
        }
      });

      return (lessonsAdded: lessonsAdded, wordsAdded: wordsAdded);
    } catch (e) {
      print('Failed to download remaining lessons: $e');
      return (lessonsAdded: 0, wordsAdded: 0);
    }
  }

  // Helper Methods for Lessons
  Future<List<Lesson>> getAllLessons() async {
    final list = await isar.collection<Lesson>().where().findAll();
    list.sort((a, b) {
      final aOrd = a.order ?? a.id;
      final bOrd = b.order ?? b.id;
      return aOrd.compareTo(bOrd);
    });
    return list;
  }

  Future<List<LessonWithStats>> getLessonsWithStats() async {
    final lessons = await getAllLessons();
    final list = <LessonWithStats>[];
    for (final l in lessons) {
      final vocab = await getVocabularyForLesson(l.id);
      final total = vocab.length;
      final learned = vocab.where((v) => v.successRate >= 80.0).length;
      final unlearned = total - learned;
      list.add(LessonWithStats(
        lesson: l,
        totalWords: total,
        learnedWords: learned,
        unlearnedWords: unlearned,
      ));
    }
    return list;
  }

  Future<void> markLessonCompleted(int id) async {
    await isar.writeTxn(() async {
      final lesson = await isar.collection<Lesson>().get(id);
      if (lesson != null) {
        lesson.isCompleted = true;
        await isar.collection<Lesson>().put(lesson);
      }
    });
  }

  // Helper Methods for Vocabulary
  Future<List<Vocabulary>> getVocabularyForLesson(int lessonId) async {
    return await isar.collection<Vocabulary>().filter().lessonIdEqualTo(lessonId).findAll();
  }

  Future<List<Vocabulary>> getCustomVocabulary() async {
    return await isar.collection<Vocabulary>().filter().lessonIdIsNull().findAll();
  }

  Future<void> addCustomVocabulary(String serbian, String turkish) async {
    await isar.writeTxn(() async {
      final vocab = Vocabulary()
        ..serbianText = serbian
        ..turkishText = turkish
        ..successRate = 0.0;
      await isar.collection<Vocabulary>().put(vocab);
    });
  }

  Future<void> updateVocabularyPractice(int id, double successRate) async {
    await isar.writeTxn(() async {
      final vocab = await isar.collection<Vocabulary>().get(id);
      if (vocab != null) {
        vocab.lastPracticedDate = DateTime.now();
        vocab.successRate = successRate;
        vocab.isLearned = true;

        if (successRate >= 80.0) {
          vocab.repetitionCount += 1;
          if (vocab.repetitionCount == 1) {
            vocab.interval = 1;
          } else if (vocab.repetitionCount == 2) {
            vocab.interval = 3;
          } else if (vocab.repetitionCount == 3) {
            vocab.interval = 7;
          } else {
            vocab.interval = 21;
          }
          final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          vocab.nextPracticeDate = todayStart.add(Duration(days: vocab.interval));
        } else {
          vocab.repetitionCount = 0;
          vocab.interval = 0;
          final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          vocab.nextPracticeDate = todayStart.add(const Duration(days: 1));
        }

        await isar.collection<Vocabulary>().put(vocab);
      }
    });
  }

  Future<int> getPendingReviewCount() async {
    final now = DateTime.now();
    return await isar.collection<Vocabulary>()
        .filter()
        .isLearnedEqualTo(true)
        .nextPracticeDateLessThan(now, include: true)
        .count();
  }

  Future<List<Vocabulary>> getPendingReviewWords() async {
    final now = DateTime.now();
    final results = await isar.collection<Vocabulary>()
        .filter()
        .isLearnedEqualTo(true)
        .nextPracticeDateLessThan(now, include: true)
        .findAll();
    // Sort by successRate ascending (lowest first, meaning Bilemedim/Failed words first)
    results.sort((a, b) => a.successRate.compareTo(b.successRate));
    return results;
  }

  // Helper Methods for Daily Progress
  Future<DailyProgress> getOrCreateDailyProgress(DateTime date) async {
    final midnight = DateTime(date.year, date.month, date.day);
    var progress = await isar.collection<DailyProgress>().filter().dateEqualTo(midnight).findFirst();

    if (progress == null) {
      progress = DailyProgress()
        ..date = midnight
        ..minutesSpent = 0
        ..wordsLearned = 0;
      
      await isar.writeTxn(() async {
        await isar.collection<DailyProgress>().put(progress!);
      });
    }

    return progress;
  }

  Future<void> incrementDailyMinutes(int minutes) async {
    final today = DateTime.now();
    final progress = await getOrCreateDailyProgress(today);
    await isar.writeTxn(() async {
      progress.minutesSpent += minutes;
      await isar.collection<DailyProgress>().put(progress);
    });
  }

  Future<void> incrementDailyWordsLearned(int count) async {
    final today = DateTime.now();
    final progress = await getOrCreateDailyProgress(today);
    await isar.writeTxn(() async {
      progress.wordsLearned += count;
      await isar.collection<DailyProgress>().put(progress);
    });
  }

  Future<void> incrementDailyLessonsCompleted() async {
    final today = DateTime.now();
    final progress = await getOrCreateDailyProgress(today);
    await isar.writeTxn(() async {
      progress.lessonsCompleted += 1;
      await isar.collection<DailyProgress>().put(progress);
    });
  }

  Future<List<DailyProgress>> getWeeklyProgress() async {
    final today = DateTime.now();
    final startOfWeek = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 7));
    return await isar.collection<DailyProgress>().filter().dateGreaterThan(startOfWeek).findAll();
  }

  Future<int> calculateActiveStreak() async {
    final allProgress = await isar.collection<DailyProgress>().where().findAll();
    if (allProgress.isEmpty) return 0;

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    // Create a Set of midnight dates (in local timezone) that have activity
    final activeDates = allProgress
        .where((p) => p.minutesSpent > 0 || p.wordsLearned > 0 || p.lessonsCompleted > 0)
        .map((p) {
          final localDate = p.date.toLocal();
          return DateTime(localDate.year, localDate.month, localDate.day);
        })
        .toSet();

    int streak = 0;
    int daysOffset = 0;

    while (true) {
      final targetDate = todayMidnight.subtract(Duration(days: daysOffset));
      
      if (activeDates.contains(targetDate)) {
        streak++;
      } else {
        // If today has no activity yet, we don't break the streak immediately; 
        // we check yesterday to see if the streak from yesterday is still active.
        if (daysOffset == 0) {
          // Keep going to check yesterday
        } else {
          break;
        }
      }
      daysOffset++;
      if (daysOffset > 365) break; // safety break
    }

    return streak;
  }

  // ── Notion Sync Helpers ──────────────────────────────────────────────────

  /// Inserts a new Lesson and returns its Isar ID.
  Future<int> insertLesson(Lesson lesson) async {
    return await isar.writeTxn(() async {
      return await isar.collection<Lesson>().put(lesson);
    });
  }

  /// Updates an existing Lesson in place.
  Future<void> updateLesson(Lesson lesson) async {
    await isar.writeTxn(() async {
      await isar.collection<Lesson>().put(lesson);
    });
  }

  /// Adds a vocabulary word linked to a specific lesson.
  Future<void> addVocabularyToLesson({
    required int lessonId,
    required String serbian,
    required String turkish,
    String? english,
    String? wordType,
  }) async {
    await isar.writeTxn(() async {
      final vocab = Vocabulary()
        ..lessonId = lessonId
        ..serbianText = serbian
        ..turkishText = turkish
        ..englishText = english
        ..wordType = wordType
        ..successRate = 0.0;
      await isar.collection<Vocabulary>().put(vocab);
    });
  }

  /// Returns true if a vocabulary entry already exists for this lesson and Serbian text.
  Future<bool> vocabularyExists({required int lessonId, required String serbianText}) async {
    final match = await isar
        .collection<Vocabulary>()
        .filter()
        .lessonIdEqualTo(lessonId)
        .serbianTextEqualTo(serbianText)
        .findFirst();
    return match != null;
  }

  /// Deletes a lesson and all of its associated vocabulary words.
  Future<void> deleteLesson(int lessonId) async {
    await isar.writeTxn(() async {
      // 1. Delete associated vocabulary
      await isar.collection<Vocabulary>().filter().lessonIdEqualTo(lessonId).deleteAll();
      // 2. Delete the lesson itself
      await isar.collection<Lesson>().delete(lessonId);
    });
  }
}

class LessonWithStats {
  final Lesson lesson;
  final int totalWords;
  final int learnedWords;
  final int unlearnedWords;

  LessonWithStats({
    required this.lesson,
    required this.totalWords,
    required this.learnedWords,
    required this.unlearnedWords,
  });
}

