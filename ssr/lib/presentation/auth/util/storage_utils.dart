import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储工具类，用于管理用户登录信息和其他持久化数据
class StorageUtils {
  // 存储键名常量
  static const String _lastLoginPhoneKey = 'last_login_phone';
  static const String _lastLoginPasswordKey = 'last_login_password';
  static const String _shouldRememberCredentialsKey = 'should_remember_credentials';
  static const String _loginHistoryKey = 'login_history';
  static const int _maxHistoryCount = 3;

  /// 保存上次登录的用户凭证（手机号和密码）
  static Future<void> saveLastLoginCredentials({
    required String phoneNumber,
    required String password,
    required bool shouldRemember,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (shouldRemember) {
      // 更新主要的登录凭证
      await prefs.setString(_lastLoginPhoneKey, phoneNumber);
      await prefs.setString(_lastLoginPasswordKey, password);
      await prefs.setBool(_shouldRememberCredentialsKey, true);
      
      // 更新登录历史记录
      await _updateLoginHistory(phoneNumber, password);
    } else {
      // 如果用户选择不记住凭证，清除已保存的信息
      await clearLastLoginCredentials();
    }
  }

  /// 更新登录历史记录，最多保存三组不同的登录信息
  static Future<void> _updateLoginHistory(String phoneNumber, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 获取现有的登录历史
    final historyString = prefs.getString(_loginHistoryKey);
    List<Map<String, dynamic>> history = [];
    
    if (historyString != null) {
      // 解析历史记录
      try {
        final List<dynamic> list = json.decode(historyString);
        history = list.map((item) => item as Map<String, dynamic>).toList();
      } catch (e) {
        // 如果解析失败，创建空的历史记录
        history = [];
      }
    }
    
    // 创建新的登录记录
    final newRecord = {
      'phoneNumber': phoneNumber,
      'password': password,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    // 检查是否已存在相同的手机号登录记录，如果有则移除
    history.removeWhere((record) => record['phoneNumber'] == phoneNumber);
    
    // 添加新记录到开头
    history.insert(0, newRecord);
    
    // 如果历史记录超过最大数量，移除最旧的记录
    if (history.length > _maxHistoryCount) {
      history = history.sublist(0, _maxHistoryCount);
    }
    
    // 保存更新后的历史记录
    await prefs.setString(_loginHistoryKey, json.encode(history));
  }

  /// 获取上次登录的用户凭证
  static Future<Map<String, dynamic>?> getLastLoginCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 检查是否开启了记住凭证功能
    final shouldRemember = prefs.getBool(_shouldRememberCredentialsKey) ?? false;
    
    if (!shouldRemember) {
      return null;
    }
    
    final phoneNumber = prefs.getString(_lastLoginPhoneKey);
    final password = prefs.getString(_lastLoginPasswordKey);
    
    if (phoneNumber != null && password != null) {
      return {
        'phoneNumber': phoneNumber,
        'password': password,
        'shouldRemember': true,
      };
    }
    
    return null;
  }

  /// 获取登录历史记录，最多返回三组最近的不同登录信息
  static Future<List<Map<String, dynamic>>> getLoginHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString(_loginHistoryKey);
    
    List<Map<String, dynamic>> history = [];
    
    if (historyString != null) {
      // 解析历史记录
      try {
        final List<dynamic> list = json.decode(historyString);
        history = list.map((item) => item as Map<String, dynamic>).toList();
      } catch (e) {
        // 如果解析失败，返回空列表
        history = [];
      }
    }
    
    return history;
  }

  /// 清除上次登录的用户凭证
  static Future<void> clearLastLoginCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastLoginPhoneKey);
    await prefs.remove(_lastLoginPasswordKey);
    await prefs.setBool(_shouldRememberCredentialsKey, false);
    // 不清除登录历史，除非明确调用clearLoginHistory
  }

  /// 清除所有登录历史记录
  static Future<void> clearLoginHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginHistoryKey);
  }

  /// 检查是否保存了上次登录的凭证
  static Future<bool> hasSavedCredentials() async {
    final credentials = await getLastLoginCredentials();
    return credentials != null;
  }
}