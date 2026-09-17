import 'package:isar/isar.dart';

part 'vocabulary.g.dart';

@collection
class Vocabulary {
  Id id = Isar.autoIncrement;
  int? lessonId; // Null if it's a custom vocabulary word
  late String serbianText;
  late String turkishText;
  String? englishText;
  String? wordType;
  DateTime? lastPracticedDate;
  double successRate = 0.0;

  bool isLearned = false;
  DateTime? nextPracticeDate;
  int interval = 0;
  int repetitionCount = 0;

  @ignore
  String get displayMeaning {
    if (englishText != null && englishText!.trim().isNotEmpty) {
      return englishText!;
    }
    return turkishText;
  }
}
