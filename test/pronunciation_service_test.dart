import 'package:flutter_test/flutter_test.dart';
import 'package:odjek/core/services/pronunciation_service.dart';

void main() {
  late PronunciationService pronunciationService;

  setUp(() {
    pronunciationService = PronunciationService();
  });

  group('PronunciationService Tests', () {
    test('cleanWord strips punctuation and casing', () {
      expect(pronunciationService.cleanWord('Zdravo!'), 'zdravo');
      expect(pronunciationService.cleanWord('kako, si?'), 'kako si');
      expect(pronunciationService.cleanWord('Čaša.'), 'čaša');
    });

    test('levenshtein distance calculates correctly', () {
      expect(pronunciationService.levenshtein('cat', 'cat'), 0);
      expect(pronunciationService.levenshtein('cat', 'bat'), 1);
      expect(pronunciationService.levenshtein('hello', 'helo'), 1);
      expect(pronunciationService.levenshtein('zoveš', 'zoves'), 1);
    });

    test('isMatch handles diacritics and slight transcription differences', () {
      expect(pronunciationService.isMatch('zoveš', 'zoves'), true);
      expect(pronunciationService.isMatch('Zdravo!', 'zdravo'), true);
      expect(pronunciationService.isMatch('kafu', 'kafa'), true); // dist = 1, len = 4, match (dist <= 1)
      expect(pronunciationService.isMatch('autobus', 'autobusi'), true); // dist = 1, len = 8, match (dist <= 2)
      expect(pronunciationService.isMatch('voda', 'hlada'), false); // dist = 4, no match
    });

    test('isMatch handles parametric name atil by matching any spoken word', () {
      expect(pronunciationService.isMatch('Atil', 'John'), true);
      expect(pronunciationService.isMatch('Atil.', 'Ahmet'), true);
      expect(pronunciationService.isMatch('Atil', ''), false);
    });

    test('isMatch handles ASR confusions for zovem se resiliently', () {
      expect(pronunciationService.isMatch('zovem', 'zoven'), true);
      expect(pronunciationService.isMatch('zovem', 'zove'), true);
      expect(pronunciationService.isMatch('se', 'sa'), true);
      expect(pronunciationService.isMatch('se', 'ce'), true);
    });

    test('analyze returns correct match highlights and accuracy', () {
      final target = 'Kako se zoveš?';
      final spoken = 'kako se zoves';
      
      final result = pronunciationService.analyze(target, spoken);
      
      expect(result.accuracy, 100.0);
      expect(result.matches.length, 3);
      expect(result.matches[0].word, 'Kako');
      expect(result.matches[0].isCorrect, true);
      expect(result.matches[1].word, 'se');
      expect(result.matches[1].isCorrect, true);
      expect(result.matches[2].word, 'zoveš?');
      expect(result.matches[2].isCorrect, true);
    });

    test('analyze handles missing words', () {
      final target = 'Karta za autobus';
      final spoken = 'karta za';
      
      final result = pronunciationService.analyze(target, spoken);
      
      // 2 out of 3 matches correct = 66.66%
      expect(result.accuracy, closeTo(66.66, 0.1));
      expect(result.matches.length, 3);
      expect(result.matches[0].word, 'Karta');
      expect(result.matches[0].isCorrect, true);
      expect(result.matches[1].word, 'za');
      expect(result.matches[1].isCorrect, true);
      expect(result.matches[2].word, 'autobus');
      expect(result.matches[2].isCorrect, false);
    });

    test('analyze handles parametric name Atil with arbitrary spoken name', () {
      final target = 'Zovem se Atil';
      final spoken = 'zovem se ahmet';
      
      final result = pronunciationService.analyze(target, spoken);
      
      expect(result.accuracy, 100.0);
      expect(result.matches.length, 3);
      expect(result.matches[0].word, 'Zovem');
      expect(result.matches[0].isCorrect, true);
      expect(result.matches[1].word, 'se');
      expect(result.matches[1].isCorrect, true);
      expect(result.matches[2].word, 'Atil');
      expect(result.matches[2].isCorrect, true);
    });

    test('analyze handles merged clitics like mije by splitting them in spoken sentence', () {
      final target = 'Drago mi je';
      final spoken = 'Brago mije.';
      
      final result = pronunciationService.analyze(target, spoken);
      
      expect(result.accuracy, 100.0);
      expect(result.matches.length, 3);
      expect(result.matches[0].word, 'Drago');
      expect(result.matches[0].isCorrect, true);
      expect(result.matches[1].word, 'mi');
      expect(result.matches[1].isCorrect, true);
      expect(result.matches[2].word, 'je');
      expect(result.matches[2].isCorrect, true);
    });
  });
}
