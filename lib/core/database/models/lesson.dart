import 'package:isar_community/isar.dart';

part 'lesson.g.dart';

@collection
class Lesson {
  Id id = Isar.autoIncrement;
  late String title;
  late String description;
  bool isCompleted = false;
  String? notionPageId; // Notion page ID used for sync matching
  int? order; // Notion or seed curriculum display order
  String? orderType; // Random, Ascending, or Descending
}
