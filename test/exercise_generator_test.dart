import 'package:flutter_test/flutter_test.dart';
import 'package:odjek/core/database/models/vocabulary.dart';
import 'package:odjek/features/practice/models/exercise.dart';
import 'package:odjek/features/practice/services/exercise_generator.dart';

void main() {
  late ExerciseGenerator generator;

  setUp(() {
    generator = ExerciseGenerator();
  });

  group('ExerciseGenerator Tests', () {
    test('generate returns empty list for empty vocab', () {
      final exercises = generator.generate(lessonVocab: []);
      expect(exercises, isEmpty);
    });

    test('generate creates matching, quiz, fillBlank/writing, and speaking exercises', () {
      final vocab1 = Vocabulary()
        ..id = 1
        ..serbianText = 'Dobar dan'
        ..turkishText = 'İyi günler';

      final vocab2 = Vocabulary()
        ..id = 2
        ..serbianText = 'Kako se zoveš?'
        ..turkishText = 'Adın ne?';

      final vocab3 = Vocabulary()
        ..id = 3
        ..serbianText = 'Hvala'
        ..turkishText = 'Teşekkürler';

      final vocab4 = Vocabulary()
        ..id = 4
        ..serbianText = 'Molim vas'
        ..turkishText = 'Lütfen';

      final vocab5 = Vocabulary()
        ..id = 5
        ..serbianText = 'Doviđenja'
        ..turkishText = 'Hoşça kal';

      final lessonVocab = [vocab1, vocab2, vocab3, vocab4, vocab5];

      final exercises = generator.generate(lessonVocab: lessonVocab);

      expect(exercises, isNotEmpty);

      // Check matching exists
      final matchingExercises = exercises.whereType<MatchingExercise>().toList();
      expect(matchingExercises, isNotEmpty);
      expect(matchingExercises.first.pairs.length, inInclusiveRange(3, 4));

      // Check quiz exists
      final quizExercises = exercises.whereType<QuizExercise>().toList();
      expect(quizExercises, isNotEmpty);
      for (final q in quizExercises) {
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.options.contains(q.correctAnswer), isTrue);
      }

      // Check fill blank exists for multi-word phrases
      final fillBlankExercises = exercises.whereType<FillBlankExercise>().toList();
      expect(fillBlankExercises, isNotEmpty);
      for (final fb in fillBlankExercises) {
        expect(fb.sentenceWithBlank.contains('______'), isTrue);
        expect(fb.options.contains(fb.correctWord), isTrue);
      }

      // Check writing exists
      final writingExercises = exercises.whereType<WritingExercise>().toList();
      expect(writingExercises, isNotEmpty);

      // Check speaking exists
      final speakingExercises = exercises.whereType<SpeakingExercise>().toList();
      expect(speakingExercises, isNotEmpty);
    });
  });
}
