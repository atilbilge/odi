import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isNativeSttAvailable = false;
  bool _isInitialized = false;

  SpeechService();

  bool get isInitialized => _isInitialized;
  bool get isNative => true;

  Future<bool> hasPermission() async {
    if (!_speechToText.isAvailable) {
      final available = await _speechToText.initialize(
        onError: (val) => print('Native STT Error: $val'),
        onStatus: (val) => print('Native STT Status: $val'),
      );
      _isNativeSttAvailable = available;
      return available;
    }
    return _speechToText.hasPermission;
  }

  String? _bestSttLocaleId;

  Future<void> initialize({required String selectedVoice}) async {
    if (_isInitialized) return;

    // Configure iOS TTS Audio Category so it plays through loudspeaker and ignores silent switch
    try {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
        IosTextToSpeechAudioMode.defaultMode,
      );
    } catch (e) {
      // Platform doesn't support or non-iOS
    }

    // Initialize Native STT (Speech to Text)
    _isNativeSttAvailable = await _speechToText.initialize(
      onError: (val) => print('Native STT Error: $val'),
      onStatus: (val) => print('Native STT Status: $val'),
    );

    if (_isNativeSttAvailable) {
      try {
        final locales = await _speechToText.locales();
        if (locales.isNotEmpty) {
          // Check for Serbian first, then Croatian (native to Apple iOS dictation), then Bosnian
          final serbian = locales.where((l) => l.localeId.toLowerCase().startsWith('sr')).toList();
          final croatian = locales.where((l) => l.localeId.toLowerCase().startsWith('hr')).toList();
          final bosnian = locales.where((l) => l.localeId.toLowerCase().startsWith('bs')).toList();

          if (serbian.isNotEmpty) {
            _bestSttLocaleId = serbian.first.localeId;
          } else if (croatian.isNotEmpty) {
            _bestSttLocaleId = croatian.first.localeId;
          } else if (bosnian.isNotEmpty) {
            _bestSttLocaleId = bosnian.first.localeId;
          } else {
            final systemLocale = await _speechToText.systemLocale();
            _bestSttLocaleId = systemLocale?.localeId;
          }
        }
      } catch (_) {
        _bestSttLocaleId = Platform.isIOS ? 'hr-HR' : 'sr-RS';
      }
    }
    
    // Initialize TTS settings
    await _flutterTts.setLanguage('hr-HR');
    await _flutterTts.setSpeechRate(0.45); // Natural slow speed for learning
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
    
    try {
      final voices = await _flutterTts.getVoices;
      if (voices != null) {
        final matchedVoices = voices.where((v) {
          final String name = (v['name'] ?? '').toString().toLowerCase();
          final String locale = (v['locale'] ?? '').toString().toLowerCase();
          return name.contains('hr') || locale.contains('hr');
        }).toList();

        if (matchedVoices.isNotEmpty) {
          final selectedVoiceMap = matchedVoices.first;
          await _flutterTts.setVoice(Map<String, String>.from(selectedVoiceMap.cast<String, String>()));
        }
      }
    } catch (_) {
      // Fallback silently if system voice querying is not supported
    }

    _isInitialized = true;
  }

  Future<void> startListening({required Function(String) onResult}) async {
    if (!_isInitialized) {
      await initialize(selectedVoice: 'default');
    }
    if (!_isNativeSttAvailable) {
      _isNativeSttAvailable = await _speechToText.initialize();
      if (!_isNativeSttAvailable) return;
    }

    final effectiveLocale = _bestSttLocaleId ?? (Platform.isIOS ? 'hr-HR' : 'sr-RS');

    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: effectiveLocale,
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        autoPunctuation: false,
      ),
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      throw Exception('SpeechService is not initialized.');
    }
    await _flutterTts.speak(text);
  }

  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
  }

  void reset() {
    dispose();
    _isInitialized = false;
  }
}

final speechServiceProvider = Provider<SpeechService>((ref) {
  final service = SpeechService();
  ref.onDispose(() => service.dispose());
  return service;
});
