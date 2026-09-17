enum ExerciseType {
  matching,
  quiz,
  fillBlank,
  writing,
  speaking,
}

abstract class Exercise {
  final ExerciseType type;
  final int vocabId;
  final String title;
  final String instructions;

  const Exercise({
    required this.type,
    required this.vocabId,
    required this.title,
    required this.instructions,
  });
}

class MatchingPair {
  final int id;
  final String serbian;
  final String turkish;

  const MatchingPair({
    required this.id,
    required this.serbian,
    required this.turkish,
  });
}

class MatchingExercise extends Exercise {
  final List<MatchingPair> pairs;

  const MatchingExercise({
    required super.vocabId,
    required this.pairs,
    super.title = 'Match the Words',
    super.instructions = 'Match the corresponding pairs.',
  }) : super(type: ExerciseType.matching);
}

class QuizExercise extends Exercise {
  final String question;
  final String correctAnswer;
  final List<String> options;
  final bool isSerbianToTurkish;
  final String serbianAudioText;

  const QuizExercise({
    required super.vocabId,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.isSerbianToTurkish,
    required this.serbianAudioText,
    super.title = 'Choose Meaning',
    super.instructions = 'Select the correct option.',
  }) : super(type: ExerciseType.quiz);
}

class FillBlankExercise extends Exercise {
  final String sentenceWithBlank;
  final String correctWord;
  final List<String> options;
  final String turkishHint;
  final String fullSerbianText;

  const FillBlankExercise({
    required super.vocabId,
    required this.sentenceWithBlank,
    required this.correctWord,
    required this.options,
    required this.turkishHint,
    required this.fullSerbianText,
    super.title = 'Fill in the Blank',
    super.instructions = 'Complete the sentence with the correct word.',
  }) : super(type: ExerciseType.fillBlank);
}

class WritingExercise extends Exercise {
  final String turkishPrompt;
  final String correctSerbian;
  final List<String> alternateAccepted;

  const WritingExercise({
    required super.vocabId,
    required this.turkishPrompt,
    required this.correctSerbian,
    this.alternateAccepted = const [],
    super.title = 'Write in Serbian',
    super.instructions = 'Type the Serbian translation.',
  }) : super(type: ExerciseType.writing);
}

class SpeakingExercise extends Exercise {
  final String targetSerbian;
  final String turkishPrompt;

  const SpeakingExercise({
    required super.vocabId,
    required this.targetSerbian,
    required this.turkishPrompt,
    super.title = 'Pronounce',
    super.instructions = 'Hold the mic and speak the phrase.',
  }) : super(type: ExerciseType.speaking);
}
