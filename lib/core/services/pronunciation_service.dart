import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WordMatch {
  final String word;
  final bool isCorrect;

  WordMatch({required this.word, required this.isCorrect});
}

class PronunciationResult {
  final List<WordMatch> matches;
  final double accuracy; // 0.0 to 100.0

  PronunciationResult({required this.matches, required this.accuracy});
}

class PronunciationService {
  String cleanWord(String w) {
    // Remove punctuation
    return w.replaceAll(RegExp(r'[.,\/#!$%\^&\*;:{}=\-_`~()?¿¡"“]'), '').trim().toLowerCase();
  }

  int levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.generate(t.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[t.length];
  }

  String normalizeAccents(String w) {
    return w
        .replaceAll('č', 'c')
        .replaceAll('ć', 'c')
        .replaceAll('š', 's')
        .replaceAll('ž', 'z')
        .replaceAll('đ', 'd')
        .replaceAll('dž', 'dz');
  }

  static const _serbianNumbers = {
    'nula': '0',
    'jedan': '1',
    'dva': '2',
    'tri': '3',
    'cetiri': '4',
    'četiri': '4',
    'pet': '5',
    'sest': '6',
    'šest': '6',
    'sedam': '7',
    'osam': '8',
    'devet': '9',
    'deset': '10',
  };

  bool isMatch(String target, String spoken) {
    var tClean = cleanWord(target);
    var sClean = cleanWord(spoken);

    if (tClean.isEmpty || sClean.isEmpty) return false;
    
    // Special rule: if target is "atil" (the parametric name), it matches any spoken word
    if (tClean == 'atil') return true;

    // Check if one is a Serbian number word and the other is its corresponding digit
    if (_serbianNumbers[tClean] == sClean || _serbianNumbers[sClean] == tClean) {
      return true;
    }

    // Also check after accent normalization for cases like "šest" -> "sest" -> "6"
    final tNorm = normalizeAccents(tClean);
    final sNorm = normalizeAccents(sClean);
    if (_serbianNumbers[tNorm] == sClean || _serbianNumbers[sClean] == tNorm ||
        _serbianNumbers[tClean] == sNorm || _serbianNumbers[sNorm] == tClean ||
        _serbianNumbers[tNorm] == sNorm || _serbianNumbers[sNorm] == tNorm) {
      return true;
    }

    // Resiliency rules for common Whisper ASR errors for "zovem se"
    if (tClean == 'zovem' && (sClean == 'zoven' || sClean == 'zove' || sClean == 'sovem' || sClean == 'soven' || sClean == 'zovemse' || sClean == 'zoveme')) return true;
    if (tClean == 'se' && (sClean == 'sa' || sClean == 'si' || sClean == 's' || sClean == 'ce' || sClean == 'ze' || sClean == 'de')) return true;

    if (tClean == sClean) return true;

    // Normalize Slavic diacritics/accents to standard Latin characters for resilient comparison
    tClean = normalizeAccents(tClean);
    sClean = normalizeAccents(sClean);

    if (tClean == sClean) return true;

    // Allow minor distance for pronunciation / Whisper transcription errors
    final distance = levenshtein(tClean, sClean);
    final maxLength = max(tClean.length, sClean.length);
    
    if (maxLength <= 4) {
      return distance <= 1;
    } else if (maxLength <= 8) {
      return distance <= 2;
    } else {
      return distance <= 3;
    }
  }

  String preprocessASRSentence(String s) {
    var processed = s.toLowerCase();
    processed = processed.replaceAll('-', ' ');
    processed = processed.replaceAll('mije', 'mi je');
    processed = processed.replaceAll('zovemse', 'zovem se');
    processed = processed.replaceAll('molimvas', 'molim vas');
    processed = processed.replaceAll('dali', 'da li');
    processed = processed.replaceAll('kakoce', 'kako ce');
    return processed;
  }

  PronunciationResult analyze(String targetSentence, String spokenSentence) {
    final targetWords = targetSentence.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty).toList();
    final cleanSpoken = preprocessASRSentence(spokenSentence);
    final spokenWords = cleanSpoken.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty).toList();

    if (targetWords.isEmpty) {
      return PronunciationResult(matches: [], accuracy: 0.0);
    }

    final List<WordMatch> matches = [];
    int spokenIdx = 0;
    int correctCount = 0;

    for (final tWord in targetWords) {
      bool found = false;
      
      // Search for matching word in the spoken sentence starting from spokenIdx
      for (int i = spokenIdx; i < spokenWords.length; i++) {
        if (isMatch(tWord, spokenWords[i])) {
          found = true;
          correctCount++;
          spokenIdx = i + 1; // Advance pointer to prevent matching the same spoken word multiple times
          break;
        }
      }

      matches.add(WordMatch(word: tWord, isCorrect: found));
    }

    final accuracy = (correctCount / targetWords.length) * 100.0;
    return PronunciationResult(matches: matches, accuracy: accuracy);
  }
}

final pronunciationServiceProvider = Provider<PronunciationService>((ref) {
  return PronunciationService();
});
