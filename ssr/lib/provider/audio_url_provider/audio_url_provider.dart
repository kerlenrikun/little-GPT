import 'package:flutter/foundation.dart';

class AudioUrlProvider extends ChangeNotifier {
  String _audioUrl = '';

  String get audioUrl => _audioUrl;

  void updateAudioUrl(String url) {
    _audioUrl = url;
    notifyListeners();
  }
}
