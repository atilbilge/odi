import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:odjek/core/database/database_service.dart';
import 'package:odjek/core/database/models/vocabulary.dart';
import 'package:odjek/core/database/models/lesson.dart';
import 'package:odjek/core/database/models/daily_progress.dart';

void main() {
  late Isar isar;
  late DatabaseService dbService;
  late Directory tempDir;

  setUpAll(() async {
    // Initialize Isar for local unit tests
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('isar_test');
    isar = await Isar.open(
      [VocabularySchema, LessonSchema, DailyProgressSchema],
      directory: tempDir.path,
    );
    dbService = DatabaseService(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Spaced Repetition Algorithm Tests', () {
    test('Successful matching increments repetitionCount, interval and nextPracticeDate correctly', () async {
      // 1. Arrange: Create a vocabulary word
      final vocab = Vocabulary()
        ..serbianText = 'hvala'
        ..turkishText = 'teşekkürler'
        ..successRate = 0.0;

      await isar.writeTxn(() async {
        await isar.collection<Vocabulary>().put(vocab);
      });

      // 2. Act: 1st correct matching (repetitionCount = 1, interval = 1)
      await dbService.updateVocabularyPractice(vocab.id, 90.0);
      
      // 3. Assert
      var updated = await isar.collection<Vocabulary>().get(vocab.id);
      expect(updated!.isLearned, isTrue);
      expect(updated.repetitionCount, 1);
      expect(updated.interval, 1);
      expect(updated.successRate, 90.0);
      
      final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      expect(updated.nextPracticeDate, todayStart.add(const Duration(days: 1)));

      // 4. Act: 2nd correct matching (repetitionCount = 2, interval = 3)
      await dbService.updateVocabularyPractice(vocab.id, 85.0);
      
      // 5. Assert
      updated = await isar.collection<Vocabulary>().get(vocab.id);
      expect(updated!.repetitionCount, 2);
      expect(updated.interval, 3);
      expect(updated.nextPracticeDate, todayStart.add(const Duration(days: 3)));

      // 6. Act: 3rd correct matching (repetitionCount = 3, interval = 7)
      await dbService.updateVocabularyPractice(vocab.id, 100.0);
      
      // 7. Assert
      updated = await isar.collection<Vocabulary>().get(vocab.id);
      expect(updated!.repetitionCount, 3);
      expect(updated.interval, 7);
      expect(updated.nextPracticeDate, todayStart.add(const Duration(days: 7)));

      // 8. Act: 4th correct matching (repetitionCount = 4, interval = 21)
      await dbService.updateVocabularyPractice(vocab.id, 80.0);
      
      // 9. Assert
      updated = await isar.collection<Vocabulary>().get(vocab.id);
      expect(updated!.repetitionCount, 4);
      expect(updated.interval, 21);
      expect(updated.nextPracticeDate, todayStart.add(const Duration(days: 21)));
    });

    test('Unsuccessful matching resets repetitionCount, interval and schedules nextPracticeDate for tomorrow', () async {
      // 1. Arrange: Create a vocabulary word that has repetitionCount = 3
      final vocab = Vocabulary()
        ..serbianText = 'molim'
        ..turkishText = 'lütfen'
        ..successRate = 85.0
        ..isLearned = true
        ..repetitionCount = 3
        ..interval = 7
        ..nextPracticeDate = DateTime.now().add(const Duration(days: 7));

      await isar.writeTxn(() async {
        await isar.collection<Vocabulary>().put(vocab);
      });

      // 2. Act: Failed match (accuracy = 50.0)
      await dbService.updateVocabularyPractice(vocab.id, 50.0);

      // 3. Assert
      final updated = await isar.collection<Vocabulary>().get(vocab.id);
      expect(updated!.repetitionCount, 0);
      expect(updated.interval, 0);
      expect(updated.successRate, 50.0);
      
      final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      expect(updated.nextPracticeDate, todayStart.add(const Duration(days: 1)));
    });

    test('getPendingReviewCount and getPendingReviewWords query correct entries', () async {
      final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      
      final v1 = Vocabulary()
        ..serbianText = 'da'
        ..turkishText = 'evet'
        ..isLearned = true
        ..nextPracticeDate = todayStart.subtract(const Duration(days: 1)); // pending

      final v2 = Vocabulary()
        ..serbianText = 'ne'
        ..turkishText = 'hayır'
        ..isLearned = true
        ..nextPracticeDate = todayStart.add(const Duration(days: 2)); // not pending (future)

      final v3 = Vocabulary()
        ..serbianText = 'hvala'
        ..turkishText = 'teşekkür'
        ..isLearned = false // not pending (never learned)
        ..nextPracticeDate = todayStart.subtract(const Duration(days: 1));

      await isar.writeTxn(() async {
        await isar.collection<Vocabulary>().putAll([v1, v2, v3]);
      });

      final pendingCount = await dbService.getPendingReviewCount();
      final pendingWords = await dbService.getPendingReviewWords();

      expect(pendingCount, 1);
      expect(pendingWords.length, 1);
      expect(pendingWords.first.serbianText, 'da');
    });
  });
}
