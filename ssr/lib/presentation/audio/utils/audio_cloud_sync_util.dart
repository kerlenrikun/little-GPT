import 'package:ssr/dio/utils/dio_utils.dart';
import 'package:ssr/domain/entity/audio.dart';
import 'package:ssr/domain/entity/series/series.dart';
import 'package:ssr/domain/provider/audio_url_provider.dart';
import 'package:ssr/presentation/audio/utils/audio_db_manager.dart';

final audioBasePath = 'http://116.62.64.88/xhxsapi/';

class AudioCloudSync {
  final AudioUrlProvider? audioUrlProvider;

  // 构造函数，允许传入AudioUrlProvider实例
  AudioCloudSync({this.audioUrlProvider});

  /// 使用Dio发送GET请求获取音频信息
  Future<dynamic> getAudioInfoById(String audioId) async {
    try {
      // 构建完整的API路径
      final thisActionPath = audioBasePath + 'audio/get-resource/' + audioId;
      print('正在请求音频信息API: $thisActionPath');

      // 使用Dio工具类发送GET请求
      final response = await DioUtil().get(
        thisActionPath,
        // 可以在这里添加查询参数、选项或取消令牌
        // params: {'key': 'value'},
        // options: Options(headers: {'Authorization': 'Bearer token'}),
      );

      print('音频信息获取成功，状态码: ${response.statusCode}');

      // 获取响应数据
      final resourceData = response.data["resource"];

      AudioEntity audioEntity = AudioEntity.fromClMap(resourceData);
      AudioDbManager().insertAudioRecord(audioEntity.toLoMap());

      // 返回响应数据
      return response.data["resource"];
      //   "resource": {
      //   "audioId": "",
      //   "audioName": ""
      //   "interaction": {
      //     "collection": "",
      //     "thump": ""
      //   },
      //   "listAudioId": [
      //     ""
      //   ],
      //   "listId": "",
      //   "listName": "",
      //   "rootCommentId": [
      //     ""
      //   ]
      // },
    } catch (e) {
      print('获取音频信息失败: $e');
      // 针对404错误的特殊处理
      if (e.toString().contains('status code of 404')) {
        print('警告: 请求的音频资源不存在或路径错误');
        // 返回null或空对象，而不是抛出异常
        return null;
      }
      // 其他类型的错误仍然抛出，让调用者处理
      rethrow;
    }
  }

  Future<dynamic> getListInfoById(String listId) async {
    try {
      // 构建完整的API路径
      final thisActionPath = audioBasePath + 'series/get-resource/' + listId;
      print('正在请求播单信息API: $thisActionPath');

      // 使用Dio工具类发送GET请求
      final response = await DioUtil().get(
        thisActionPath,
        // 可以在这里添加查询参数、选项或取消令牌
        // params: {'key': 'value'},
        // options: Options(headers: {'Authorization': 'Bearer token'}),
      );

      print('播单信息获取成功，状态码: ${response.statusCode}');

      // 获取响应数据
      final resourceData = response.data["resource"];

      SeriesEntity seriesEntity = SeriesEntity.fromClMap(resourceData);
      AudioDbManager().insertSeriesRecord(seriesEntity.toLoMap());

      // 返回响应数据
      return response.data["resource"];
      // "resource": {
      //   "listContent": {
      //     "": {
      //       "name": "",
      //       "sort": ""
      //     },
      //     "": {
      //       "name": "",
      //       "sort": ""
      //     }
      //   },
      //   "listId": "",
      //   "listName": "",
      //   "listType": ""
      // },
    } catch (e) {
      print('获取播单信息失败: $e');
      // 针对404错误的特殊处理
      if (e.toString().contains('status code of 404')) {
        print('警告: 请求的播单资源不存在或路径错误');
        // 返回null或空对象，而不是抛出异常
        return null;
      }
      // 其他类型的错误仍然抛出，让调用者处理
      rethrow;
    }
  }
}
