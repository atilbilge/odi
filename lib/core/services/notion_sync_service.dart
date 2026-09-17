import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database_service.dart';
import '../database/models/lesson.dart';

// ─── Constants ─────────────────────────────────────────────────────────────
const _kNotionVersion = '2022-06-28';
const _kBaseUrl = 'https://api.notion.com/v1';

const _kCoursesDatabaseId = '3936b75276f980e798def638bce36faf';
const _kWordsDatabaseId = '3936b75276f9804aa973f8bccebd15a3';

// Secure storage keys
const _kTokenKey = 'notion_token';

// ─── Provider ──────────────────────────────────────────────────────────────
final notionSyncServiceProvider = Provider<NotionSyncService>((ref) {
  final db = ref.read(databaseServiceProvider);
  return NotionSyncService(db);
});

// ─── Sync Result ──────────────────────────────────────────────────────────
class NotionSyncResult {
  final int lessonsAdded;
  final int lessonsUpdated;
  final int wordsAdded;
  final String? error;

  bool get isSuccess => error == null;

  const NotionSyncResult({
    this.lessonsAdded = 0,
    this.lessonsUpdated = 0,
    this.wordsAdded = 0,
    this.error,
  });

  NotionSyncResult.failure(String message)
      : lessonsAdded = 0,
        lessonsUpdated = 0,
        wordsAdded = 0,
        error = message;
}

// ─── Service ──────────────────────────────────────────────────────────────
class NotionSyncService {
  final DatabaseService _db;
  final _storage = const FlutterSecureStorage();

  NotionSyncService(this._db);

  // ── Token Management ────────────────────────────────────────────────────

  Future<String?> getToken() async {
    return await _storage.read(key: _kTokenKey);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _kTokenKey, value: token.trim());
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _kTokenKey);
  }

  // ── Sync Logic ──────────────────────────────────────────────────────────

  /// Syncs courses and words from Notion into Isar.
  /// Completed lessons are never overwritten.
  Future<NotionSyncResult> sync() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return NotionSyncResult.failure('Notion token bulunamadı. Ayarlar\'dan token giriniz.');
    }

    final dio = Dio(BaseOptions(
      baseUrl: _kBaseUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Notion-Version': _kNotionVersion,
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));

    try {
      // ── 1. Fetch all courses from Notion ──
      final coursePages = await _queryAll(dio, _kCoursesDatabaseId, sorts: [
        {'property': 'Order', 'direction': 'ascending'},
      ]);

      int lessonsAdded = 0;
      int lessonsUpdated = 0;

      // Build a map: notionPageId → Lesson (existing in Isar)
      final existingLessons = await _db.getAllLessons();
      final existingByNotionId = <String, Lesson>{
        for (final l in existingLessons)
          if (l.notionPageId != null) l.notionPageId!: l,
      };

      // Also track existing non-Notion lessons by title (for legacy seeded data)
      final existingByTitle = <String, Lesson>{
        for (final l in existingLessons) l.title: l,
      };

      // ── 2. Upsert each course into Isar ──
      // Map: Notion Page ID → Isar Lesson ID (for vocabulary association)
      final notionIdToIsarId = <String, int>{};

      for (final page in coursePages) {
        final notionPageId = page['id'] as String;
        final props = page['properties'] as Map<String, dynamic>;

        // 1. Filter by Status == 'Published'
        final status = _extractSelect(props, 'Status') ?? _extractStatus(props, 'Status') ?? '';
        if (status != 'Published') continue;

        final title = _extractTitle(props, 'Title');
        final description = _extractRichText(props, 'Description');
        final orderNum = _extractNumber(props, 'Order') ?? 0;
        final orderType = _extractSelect(props, 'Order Type') ?? 'Random';

        if (title.isEmpty) continue;

        // Check if lesson already exists (by notionPageId first, then title fallback)
        Lesson? existing = existingByNotionId[notionPageId] ?? existingByTitle[title];

        if (existing != null) {
          // Never update a completed lesson's content
          if (!existing.isCompleted) {
            // Update title/description only if not completed
            existing.title = title;
            existing.description = description;
            existing.notionPageId = notionPageId;
            existing.order = orderNum;
            existing.orderType = orderType;
            await _db.updateLesson(existing);
            lessonsUpdated++;
          }
          notionIdToIsarId[notionPageId] = existing.id;
        } else {
          // New lesson — insert
          final newLesson = Lesson()
            ..title = title
            ..description = description
            ..isCompleted = false
            ..notionPageId = notionPageId
            ..order = orderNum
            ..orderType = orderType;
          final isarId = await _db.insertLesson(newLesson);
          notionIdToIsarId[notionPageId] = isarId;
          lessonsAdded++;
        }
      }

      // ── 3. Fetch all words from Notion ──
      final wordPages = await _queryAll(dio, _kWordsDatabaseId, sorts: [
        {'property': 'Order', 'direction': 'ascending'},
      ]);

      int wordsAdded = 0;

      for (final page in wordPages) {
        final props = page['properties'] as Map<String, dynamic>;

        final serbianText = _extractTitle(props, 'Word');
        final turkishText = _extractRichText(props, 'Meaning');

        if (serbianText.isEmpty || turkishText.isEmpty) continue;

        // Get related course Notion page IDs
        final courseRelations = _extractRelations(props, 'Courses');
        if (courseRelations.isEmpty) continue;

        for (final relatedNotionId in courseRelations) {
          final lessonIsarId = notionIdToIsarId[relatedNotionId];
          if (lessonIsarId == null) continue;

          // Check if this word already exists for this lesson
          final exists = await _db.vocabularyExists(
            lessonId: lessonIsarId,
            serbianText: serbianText,
          );
          if (!exists) {
            await _db.addVocabularyToLesson(
              lessonId: lessonIsarId,
              serbian: serbianText,
              turkish: turkishText,
            );
            wordsAdded++;
          }
        }
      }

      return NotionSyncResult(
        lessonsAdded: lessonsAdded,
        lessonsUpdated: lessonsUpdated,
        wordsAdded: wordsAdded,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return NotionSyncResult.failure('Notion token geçersiz. Lütfen ayarlardan güncelleyin.');
      } else if (statusCode == 404) {
        return NotionSyncResult.failure('Notion veritabanı bulunamadı. Database ID\'leri kontrol edin.');
      }
      return NotionSyncResult.failure('Ağ hatası: ${e.message}');
    } catch (e) {
      return NotionSyncResult.failure('Beklenmeyen hata: $e');
    }
  }

  // ── Notion API Helpers ──────────────────────────────────────────────────

  /// Queries all pages from a Notion database (handles pagination).
  Future<List<Map<String, dynamic>>> _queryAll(
    Dio dio,
    String databaseId, {
    List<Map<String, dynamic>>? sorts,
  }) async {
    final all = <Map<String, dynamic>>[];
    String? cursor;

    do {
      final body = <String, dynamic>{'page_size': 100};
      if (sorts != null) body['sorts'] = sorts;
      if (cursor != null) body['start_cursor'] = cursor;

      final response = await dio.post(
        '/databases/$databaseId/query',
        data: jsonEncode(body),
      );

      final data = response.data as Map<String, dynamic>;
      final results = (data['results'] as List).cast<Map<String, dynamic>>();
      all.addAll(results);

      final hasMore = data['has_more'] as bool? ?? false;
      cursor = hasMore ? data['next_cursor'] as String? : null;
    } while (cursor != null);

    return all;
  }

  String _extractTitle(Map<String, dynamic> props, String key) {
    try {
      final titleList = props[key]['title'] as List;
      return titleList.map((t) => t['plain_text'] as String).join('');
    } catch (_) {
      return '';
    }
  }

  String _extractRichText(Map<String, dynamic> props, String key) {
    try {
      final rtList = props[key]['rich_text'] as List;
      return rtList.map((t) => t['plain_text'] as String).join('');
    } catch (_) {
      return '';
    }
  }

  int? _extractNumber(Map<String, dynamic> props, String key) {
    try {
      return (props[key]['number'] as num?)?.toInt();
    } catch (_) {
      return null;
    }
  }

  List<String> _extractRelations(Map<String, dynamic> props, String key) {
    try {
      final relations = props[key]['relation'] as List;
      return relations.map((r) => r['id'] as String).toList();
    } catch (_) {
      return [];
    }
  }

  String? _extractSelect(Map<String, dynamic> props, String key) {
    try {
      return props[key]['select']['name'] as String?;
    } catch (_) {
      return null;
    }
  }

  String? _extractStatus(Map<String, dynamic> props, String key) {
    try {
      return props[key]['status']['name'] as String?;
    } catch (_) {
      return null;
    }
  }
}
