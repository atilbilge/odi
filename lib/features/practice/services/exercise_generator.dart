import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/models/vocabulary.dart';
import '../models/exercise.dart';

final exerciseGeneratorProvider = Provider<ExerciseGenerator>((ref) {
  return ExerciseGenerator();
});

class ExerciseGenerator {
  final Random _random;

  ExerciseGenerator({Random? random}) : _random = random ?? Random();

  /// Generates a rich, balanced sequence of interactive exercises
  /// from the provided vocabulary list.
  List<Exercise> generate({
    required List<Vocabulary> lessonVocab,
    List<Vocabulary> poolVocab = const [],
  }) {
    if (lessonVocab.isEmpty) return [];

    final List<Exercise> exercises = [];
    final allVocabPool = [...lessonVocab, ...poolVocab];

    // 1. MATCHING: If we have at least 3 words, create 1 or 2 matching sets first
    if (lessonVocab.length >= 3) {
      final chunkSize = lessonVocab.length >= 5 ? 4 : lessonVocab.length;
      final shuffled = List<Vocabulary>.from(lessonVocab)..shuffle(_random);
      final matchingChunk = shuffled.take(chunkSize).toList();

      exercises.add(
        MatchingExercise(
          vocabId: matchingChunk.first.id,
          pairs: matchingChunk.map((v) {
            return MatchingPair(
              id: v.id,
              serbian: v.serbianText,
              turkish: v.displayMeaning,
            );
          }).toList(),
        ),
      );
    }

    // 2. QUIZ, FILL-BLANK, WRITING, SPEAKING for each word
    final shuffledVocab = List<Vocabulary>.from(lessonVocab)..shuffle(_random);

    for (int i = 0; i < shuffledVocab.length; i++) {
      final v = shuffledVocab[i];

      // A: Quiz (Multiple Choice)
      final isSerbianToTurkish = _random.nextBool();
      final quiz = _generateQuiz(v, allVocabPool, isSerbianToTurkish: isSerbianToTurkish);
      exercises.add(quiz);

      // B: Fill Blank (if phrase has >= 2 words) or Writing
      final words = v.serbianText.trim().split(RegExp(r'\s+'));
      if (words.length >= 2) {
        final fillBlank = _generateFillBlank(v, allVocabPool);
        if (fillBlank != null) {
          exercises.add(fillBlank);
        } else {
          exercises.add(_generateWriting(v));
        }
      } else {
        // Single word -> Writing
        exercises.add(_generateWriting(v));
      }

      // C: Speaking challenge for selected words (e.g. alternate or every 2nd word)
      if (i % 2 == 0) {
        exercises.add(
          SpeakingExercise(
            vocabId: v.id,
            targetSerbian: v.serbianText,
            turkishPrompt: v.displayMeaning,
          ),
        );
      }
    }

    // Final second Matching exercise if lesson has 5 or more words
    if (lessonVocab.length >= 5) {
      final shuffled = List<Vocabulary>.from(lessonVocab)..shuffle(_random);
      final matchingChunk = shuffled.take(4).toList();
      exercises.add(
        MatchingExercise(
          vocabId: matchingChunk.first.id,
          pairs: matchingChunk.map((v) {
            return MatchingPair(
              id: v.id,
              serbian: v.serbianText,
              turkish: v.displayMeaning,
            );
          }).toList(),
          title: 'Quick Match',
          instructions: 'Review learned words in your memory.',
        ),
      );
    }

    return exercises;
  }

  QuizExercise _generateQuiz(Vocabulary target, List<Vocabulary> pool, {required bool isSerbianToTurkish}) {
    final String question = isSerbianToTurkish ? target.serbianText : target.displayMeaning;
    final String correctAnswer = isSerbianToTurkish ? target.displayMeaning : target.serbianText;

    // Distractors from other words in pool
    final otherOptions = pool
        .where((v) => v.id != target.id)
        .map((v) => isSerbianToTurkish ? v.displayMeaning : v.serbianText)
        .toSet()
        .toList()
      ..shuffle(_random);

    final distractors = otherOptions.take(3).toList();

    // Fallback options if not enough in pool
    final fallbackDistractors = isSerbianToTurkish
        ? ['Hello', 'Goodbye', 'Please', 'Yes', 'No', 'Thank you']
        : ['Zdravo', 'Doviđenja', 'Molim', 'Da', 'Ne', 'Hvala'];

    for (final fallback in fallbackDistractors) {
      if (distractors.length >= 3) break;
      if (fallback != correctAnswer && !distractors.contains(fallback)) {
        distractors.add(fallback);
      }
    }

    final options = [correctAnswer, ...distractors]..shuffle(_random);

    return QuizExercise(
      vocabId: target.id,
      question: question,
      correctAnswer: correctAnswer,
      options: options,
      isSerbianToTurkish: isSerbianToTurkish,
      serbianAudioText: target.serbianText,
    );
  }

  FillBlankExercise? _generateFillBlank(Vocabulary target, List<Vocabulary> pool) {
    final cleanSentence = target.serbianText.replaceAll(RegExp(r'[!?,.]'), '');
    final words = cleanSentence.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length < 2) return null;

    int blankIndex = _random.nextInt(words.length);
    for (int i = 0; i < words.length; i++) {
      if (words[i].length >= 3) {
        blankIndex = i;
        break;
      }
    }

    final targetWord = words[blankIndex];

    // Reconstruct sentence with blank
    final rawTokens = target.serbianText.split(' ');
    final sentenceTokens = <String>[];
    for (int i = 0; i < rawTokens.length; i++) {
      final token = rawTokens[i];
      if (token.contains(targetWord)) {
        sentenceTokens.add(token.replaceFirst(targetWord, '______'));
      } else {
        sentenceTokens.add(token);
      }
    }
    final sentenceWithBlank = sentenceTokens.join(' ');

    // Collect distractors
    final Set<String> distractorWords = {};
    for (final v in pool) {
      final poolWords = v.serbianText
          .replaceAll(RegExp(r'[!?,.]'), '')
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty && w.toLowerCase() != targetWord.toLowerCase());
      distractorWords.addAll(poolWords);
      if (distractorWords.length >= 6) break;
    }

    final genericDistractors = ['dan', 'jutro', 'veče', 'kako', 'sam', 'ste', 'si', 'hvala', 'dobar', 'lepo'];
    for (final g in genericDistractors) {
      if (g.toLowerCase() != targetWord.toLowerCase()) {
        distractorWords.add(g);
      }
    }

    final distractorList = distractorWords.toList()..shuffle(_random);
    final chosenDistractors = distractorList.take(3).toList();
    final options = [targetWord, ...chosenDistractors]..shuffle(_random);

    return FillBlankExercise(
      vocabId: target.id,
      sentenceWithBlank: sentenceWithBlank,
      correctWord: targetWord,
      options: options,
      turkishHint: target.displayMeaning,
      fullSerbianText: target.serbianText,
    );
  }

  WritingExercise _generateWriting(Vocabulary target) {
    final cleanTarget = target.serbianText.trim();
    final alternates = <String>[
      cleanTarget.replaceAll(RegExp(r'[!?,.]'), '').trim(),
      _stripDiacritics(cleanTarget),
    ];

    return WritingExercise(
      vocabId: target.id,
      turkishPrompt: target.displayMeaning,
      correctSerbian: cleanTarget,
      alternateAccepted: alternates,
    );
  }

  String _stripDiacritics(String text) {
    return text
        .replaceAll('č', 'c')
        .replaceAll('ć', 'c')
        .replaceAll('Č', 'C')
        .replaceAll('Ć', 'C')
        .replaceAll('ž', 'z')
        .replaceAll('Ž', 'Z')
        .replaceAll('š', 's')
        .replaceAll('Š', 'S')
        .replaceAll('đ', 'dj')
        .replaceAll('Đ', 'Dj');
  }
}
