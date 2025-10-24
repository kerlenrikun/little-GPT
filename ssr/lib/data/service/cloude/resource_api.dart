import 'package:dio/dio.dart';
import 'package:ssr/data/config/xhxs_config.dart';
import 'package:ssr/data/service/cloude/auth_api.dart';
import 'package:ssr/dio/utils/dio_utils.dart';

class ResourceApi {
  final DioUtil dio = DioUtil();
  static const String _baseUrl = XhxsConfig.apiBaseUrl;

  /// 获取资源
  Future<Map<String, dynamic>> getResource(
    String resourceType,
    String resourceId,
  ) async {
    final headers = await AuthApi().getHeaders();
    final response = await dio.get(
      '$_baseUrl/$resourceType/get-resource/$resourceId/',
      options: Options(headers: headers),
    );
    return response.data;
  }
}
