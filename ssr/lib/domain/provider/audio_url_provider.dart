import 'package:flutter/foundation.dart';
import 'package:ssr/domain/entity/audio.dart';

class AudioUrlProvider extends ChangeNotifier {
  String _baseAudioUrl = 'http://116.62.64.88/resources/audio/';
  String _audioId = '';
  String _audioUrl = '';
  String _listId = '';

  String get audioId => _audioId;
  String get audioUrl => _audioUrl;
  String get listId => _listId;

  void updateAudioUrl(String id) {
    // 保留此方法以兼容现有代码，但内部调用updateAudioId确保两个字段都更新
    updateAudioId(id);
  }

  void updateAudioId(String id) {
    if (id.isEmpty || id == _audioId) {
      return;
    }
    _audioId = id;
    _audioUrl = _baseAudioUrl + id + '/audio.mp3';
    notifyListeners();
  }

  void updateListId(String id) {
    if (id.isEmpty || id == _listId) {
      return;
    }
    _listId = id;
    notifyListeners();
  }
}

// 读取数据方法： context.read<AudioUrlProvider>().audioId
