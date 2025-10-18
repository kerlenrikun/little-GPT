import 'package:flutter/foundation.dart';

class AudioUrlProvider extends ChangeNotifier {
  String _baseAudioUrl = 'http://116.62.64.88/resources/audio/';
  String _audioUrl = '';

  String get audioUrl => _audioUrl;

  void updateAudioUrl(String url) {
    _audioUrl = _baseAudioUrl + url + '/audio.mp3';
    // _audioUrl = url;
    notifyListeners();
  }
}
