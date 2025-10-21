import 'package:flutter/foundation.dart';
import 'package:ssr/domain/entity/audio.dart';

class SeriesIdProvider extends ChangeNotifier {
  String _seriesId = '';

  String get seriesId => _seriesId;

  void updateSeriesId(List id) {
    if (id.isEmpty) {
      return;
    }
    _seriesId = id[0];
    print('更新播单ID为: seriesId:${seriesId}');
    notifyListeners();
  }
}

// 读取数据方法： context.read<AudioUrlProvider>().audioId
