import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ssr/data/config/feishu_config.dart';
/// 云端数据到db的基本api
/// 云端数据到前端的基本api

class CloudApiService {
  // 使用配置中的基础API URL
  static const String _baseUrl = FeishuConfig.baseApiUrl;
  static const String _bitableBaseUrl = '$_baseUrl/bitable/v1';
  static const String _authBaseUrl = '$_baseUrl/auth/v3';
  
  // 当前使用的数据表标识
  final String tableKey;
  
  // 飞书访问令牌
  String? _accessToken;
  DateTime? _tokenExpiry;
  
  // 构造函数
  CloudApiService({this.tableKey = 'users'});
  
  // 从表标识获取appToken
  String get _appToken {
    return FeishuConfig.getAppToken(tableKey);
  }

  // 从表标识获取tableId
  String get _tableId {
    return FeishuConfig.getTableId(tableKey);
  }
  
  // 获取访问令牌
  Future<String> _getAccessToken() async {
    // 如果token有效且未过期，直接返回
    if (_accessToken != null && 
        _tokenExpiry != null && 
        _tokenExpiry!.isAfter(DateTime.now())) {
      return _accessToken!;
    }
    
    final url = '$_authBaseUrl/app_access_token/internal/';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: json.encode({
          'app_id':  FeishuConfig.appId,
          'app_secret':  FeishuConfig.appSecret,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['code'] == 0) {
          _accessToken = responseData['app_access_token'];
          // 飞书token有效期为2小时，这里设置为1小时50分钟以防万一
          _tokenExpiry = DateTime.now().add(const Duration(minutes: 110));
          return _accessToken!;
        } else {
          throw Exception('获取访问令牌失败: ${responseData['msg']}');
        }
      } else {
        throw Exception('HTTP错误: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('获取访问令牌失败: $e');
    }
  }
  
  // 获取请求头
  Future<Map<String, String>> _getHeaders() async {
    final accessToken = await _getAccessToken();
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json; charset=utf-8',
    };
  }
  
  // 添加记录到多维表格
  Future<Map<String, dynamic>> addRecord(Map<String, dynamic> recordData) async {
    // 验证配置是否有效
    if (!FeishuConfig.isTableConfigValid(tableKey)) {
      return {
        'success': false,
        'error': '表格配置无效',
        'message': '请检查飞书配置'
      };
    }
    
    final url = '$_bitableBaseUrl/apps/$_appToken/tables/$_tableId/records';
    
    try {
      final headers = await _getHeaders();
      
      // 飞书API要求特定的请求格式
      final requestBody = {
        'fields': recordData['fields'],
      };
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // 检查飞书API的返回码
        if (responseData['code'] == 0) {
          return {
            'success': true,
            'data': responseData,
            'message': '记录添加成功',
          };
        } else {
          return {
            'success': false,
            'error': '飞书API错误: ${responseData['msg']}',
            'message': responseData['msg'] ?? '添加记录失败',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP错误: ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': '网络请求失败',
      };
    }
  }
  
  // 查询记录
  Future<Map<String, dynamic>> queryRecords({
    String? filter,
    String? sort,
    int pageSize = 100,
    String? pageToken,
  }) async {
    // 验证配置是否有效
    if (!FeishuConfig.isTableConfigValid(tableKey)) {
      return {
        'success': false,
        'error': '表格配置无效',
        'message': '请检查飞书配置'
      };
    }
    
    final url = '$_bitableBaseUrl/apps/$_appToken/tables/$_tableId/records';
    final params = {
      if (filter != null) 'filter': filter,
      if (sort != null) 'sort': sort,
      'page_size': pageSize.toString(),
      if (pageToken != null) 'page_token': pageToken,
    };
    
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(url).replace(queryParameters: params),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // 检查飞书API的返回码
        if (responseData['code'] == 0) {
          return {
            'success': true,
            'data': responseData,
            'message': '查询成功',
          };
        } else {
          return {
            'success': false,
            'error': '飞书API错误: ${responseData['msg']}',
            'message': responseData['msg'] ?? '查询失败',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP错误: ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': '网络请求失败',
      };
    }
  }

  // 根据record_id获取单条记录
  Future<Map<String, dynamic>> getRecordById(String recordId) async {
    // 验证配置是否有效
    if (!FeishuConfig.isTableConfigValid(tableKey)) {
      return {
        'success': false,
        'error': '表格配置无效',
        'message': '请检查飞书配置'
      };
    }
    
    final url = '$_bitableBaseUrl/apps/$_appToken/tables/$_tableId/records/$recordId';
    
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // 检查飞书API的返回码
        if (responseData['code'] == 0) {
          return {
            'success': true,
            'data': responseData,
            'message': '查询成功',
          };
        } else {
          return {
            'success': false,
            'error': '飞书API错误: ${responseData['msg']}',
            'message': responseData['msg'] ?? '查询失败',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP错误: ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': '网络请求失败',
      };
    }
  }

  // 更新记录
  Future<Map<String, dynamic>> updateRecord(String recordId, Map<String, dynamic> recordData) async {
    // 验证配置是否有效
    if (!FeishuConfig.isTableConfigValid(tableKey)) {
      return {
        'success': false,
        'error': '表格配置无效',
        'message': '请检查飞书配置'
      };
    }
    
    final url = '$_bitableBaseUrl/apps/$_appToken/tables/$_tableId/records/$recordId';
    
    try {
      final headers = await _getHeaders();
      
      // 飞书API要求特定的请求格式
      final requestBody = {
        'fields': recordData['fields'],
      };
      
      //print('更新记录 - URL: $url');
      //print('更新记录 - Headers: $headers');
      //print('更新记录 - Request Body: ${json.encode(requestBody)}');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );
      
      //print('更新记录 - Response Status: ${response.statusCode}');
      //print('更新记录 - Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // 检查飞书API的返回码
        if (responseData['code'] == 0) {
          return {
            'success': true,
            'data': responseData,
            'message': '记录更新成功',
          };
        } else {
          print('飞书API返回错误 - Code: ${responseData['code']}, Msg: ${responseData['msg']}');
          return {
            'success': false,
            'error': '飞书API错误: ${responseData['msg']}',
            'message': responseData['msg'] ?? '更新记录失败',
          };
        }
      } else {
        print('HTTP错误 - Status: ${response.statusCode}, Body: ${response.body}');
        return {
          'success': false,
          'error': 'HTTP错误: ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e, stackTrace) {
      print('更新记录时发生异常: $e');
      print('异常堆栈: $stackTrace');
      return {
        'success': false,
        'error': e.toString(),
        'message': '网络请求失败',
      };
    }
  }

  // 删除记录
  Future<Map<String, dynamic>> deleteRecord(String recordId) async {
    // 验证配置是否有效
    if (!FeishuConfig.isTableConfigValid(tableKey)) {
      return {
        'success': false,
        'error': '表格配置无效',
        'message': '请检查飞书配置'
      };
    }
    
    final url = '$_bitableBaseUrl/apps/$_appToken/tables/$_tableId/records/$recordId';
    
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // 检查飞书API的返回码
        if (responseData['code'] == 0) {
          return {
            'success': true,
            'data': responseData,
            'message': '记录删除成功',
          };
        } else {
          return {
            'success': false,
            'error': '飞书API错误: ${responseData['msg']}',
            'message': responseData['msg'] ?? '删除记录失败',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP错误: ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': '网络请求失败',
      };
    }
  }
}