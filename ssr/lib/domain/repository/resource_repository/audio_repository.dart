import 'package:ssr/data/config/xhxs_config.dart';
import 'package:ssr/dio/utils/dio_utils.dart';
import 'package:ssr/domain/entity/audio.dart';
import 'package:ssr/domain/repository/repository.dart';

class AudioRepository extends Repository<AudioEntity> {
  AudioRepository() : super('audio', 'audio');

  @override
  Map<String, dynamic> toClMap(AudioEntity entity) {
    return entity.toClMap();
  }

  @override
  AudioEntity fromClMap(Map<String, dynamic> map) {
    return AudioEntity.fromClMap(map);
  }

  @override
  AudioEntity fromLoMap(Map<String, dynamic> map) {
    return AudioEntity.fromLoMap(map);
  }

  @override
  Map<String, dynamic> toLoMap(AudioEntity entity) {
    return entity.toLoMap();
  }

  Future<List<AudioEntity>> getResourceById(String audioId) async {
    return await super.getResource('audio', audioId);
  }
}
