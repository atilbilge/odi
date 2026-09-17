import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Curriculum & Course Words Tests', () {
    test('curriculum.json contains exactly the first 5 courses and 75 words', () {
      final file = File('assets/curriculum.json');
      expect(file.existsSync(), isTrue);

      final List<dynamic> data = json.decode(file.readAsStringSync());
      expect(data.length, equals(5));

      int totalWords = 0;
      for (final course in data) {
        expect(course['title'], isNotEmpty);
        expect(course['description'], isNotEmpty);
        final List<dynamic> vocab = course['vocabulary'];
        expect(vocab.length, equals(15));
        totalWords += vocab.length;

        for (final item in vocab) {
          expect(item['serbianText'], isNotEmpty);
          expect(item['turkishText'], isNotEmpty);
          expect(item['englishText'], isNotEmpty);
          expect(item['wordType'], isNotEmpty);
        }
      }

      expect(totalWords, equals(75));
      expect(data[0]['title'], equals('Pozdravljanje i osnovna komunikacija'));
      expect(data[1]['title'], equals('Lične zamenice i glagol biti'));
      expect(data[2]['title'], equals('Odrični oblici i gramatika'));
      expect(data[3]['title'], equals('Porodica i rodbina 1'));
      expect(data[4]['title'], equals('Porodica i rodbina 2'));
    });

    test('course_words_all.json contains all 40 courses and 600 words', () {
      final file = File('assets/course_words_all.json');
      expect(file.existsSync(), isTrue);

      final List<dynamic> data = json.decode(file.readAsStringSync());
      expect(data.length, equals(40));

      int totalWords = 0;
      for (int i = 0; i < data.length; i++) {
        final course = data[i];
        expect(course['order'], equals(i + 1));
        expect(course['title'], isNotEmpty);
        final List<dynamic> vocab = course['vocabulary'];
        expect(vocab.length, equals(15));
        totalWords += vocab.length;
      }

      expect(totalWords, equals(600));
    });
  });
}
