import 'package:ssr/dio/utils/dio_utils.dart';

final audioBasePath = 'http://116.62.64.88/api/';

class AudioCloudSync {
  // 使用DioUtil单例时直接调用构造函数，无需提前初始化
  // 单例模式由DioUtil内部保证

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
      // 重新抛出异常让调用者处理，或返回特定的错误对象
      rethrow;
    }
  }

  Future<dynamic> getListInfoById(String listId) async {
    try {
      // 构建完整的API路径
      final thisActionPath = audioBasePath + 'list/get-resource/' + listId;
      print('正在请求播单信息API: $thisActionPath');

      // 使用Dio工具类发送GET请求
      final response = await DioUtil().get(
        thisActionPath,
        // 可以在这里添加查询参数、选项或取消令牌
        // params: {'key': 'value'},
        // options: Options(headers: {'Authorization': 'Bearer token'}),
      );

      print('音频信息获取成功，状态码: ${response.statusCode}');

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
      print('获取音频信息失败: $e');
      // 重新抛出异常让调用者处理，或返回特定的错误对象
      rethrow;
    }
  }
}
