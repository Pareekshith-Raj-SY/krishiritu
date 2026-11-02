import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        return false;
      }

      _isInitialized = await _speech.initialize(
        onError: (err) => debugPrint('Speech error: $err'),
        onStatus: (status) => debugPrint('Speech status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      debugPrint('Speech init failed: $e');
      return false;
    }
  }

  /// Map app language code to speech recognition locale tag
  String getLocaleForLanguage(String langCode) {
    switch (langCode) {
      case 'kn':
        return 'kn_IN';
      case 'hi':
        return 'hi_IN';
      default:
        return 'en_IN';
    }
  }

  Future<bool> startListening({
    required Function(String words) onResult,
    required VoidCallback onDone,
    String languageCode = 'en',
  }) async {
    final available = await initialize();
    if (!available) {
      return false;
    }

    final localeId = getLocaleForLanguage(languageCode);

    try {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
          if (result.finalResult) {
            onDone();
          }
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: localeId,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
          cancelOnError: false,
          partialResults: true,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Speech listen failed: $e');
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}
  }
}
