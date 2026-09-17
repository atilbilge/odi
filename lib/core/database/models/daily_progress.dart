import 'package:isar/isar.dart';

part 'daily_progress.g.dart';

@collection
class DailyProgress {
  Id id = Isar.autoIncrement;
  late DateTime date; // Store midnight of the day for easy grouping
  int minutesSpent = 0;
  int wordsLearned = 0;
  int lessonsCompleted = 0;
}
