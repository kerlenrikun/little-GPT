import 'dart:convert';
import 'package:ssr/data/config/xhxs_config.dart';
import 'package:ssr/dio/utils/dio_utils.dart';
import 'package:ssr/domain/entity/user.dart';
import 'package:ssr/domain/provider/user_provider.dart';

class AuthApi {
  final DioUtil dio = DioUtil();
  static const String _baseUrl = XhxsConfig.apiBaseUrl;
  DateTime? _tokenExpiry;

  // 用户登录+获取访问令牌
  Future<void> login(String user_id, String password, bool remember_me) async {
    final url = '$_baseUrl/login';

    try {
      final response = await dio.post(
        url,
        data: {
          'user_id': user_id,
          'password': password,
          'remember_me': remember_me,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.data);
        UserEntity userEntity = UserEntity.fromClMap(responseData);
        UserProvider().setUserInfoBatch(userEntity.toLoMap());
        final userToken = responseData['token'];
        // 飞书token有效期为2小时，这里设置为1小时50分钟以防万一
        _tokenExpiry = DateTime.now().add(const Duration(minutes: 50));
        return userToken;
      } else {
        throw Exception('获取访问令牌失败: ${response.data['msg']}');
      }
    } catch (e) {
      throw Exception('获取访问令牌失败: $e');
    }
  }

  // 获取请求头
  Future<Map<String, String>> getHeaders() async {
    final accessToken = UserProvider().token;
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json; charset=utf-8',
    };
  }
}
