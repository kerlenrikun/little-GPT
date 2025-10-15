import 'dart:async';

import 'package:flutter/material.dart';
import 'package:star_claude/domain/entities/auth/user.dart';
import 'package:star_claude/domain/usecases/job_resources.dart';
import 'package:star_claude/presentation/auth/utils/storage_utils.dart';

/// 用户信息状态管理类
/// 只提供必要的用户状态共享，具体数据操作由Repository负责
class UserProvider extends ChangeNotifier {
  // 初始化用户实体
  UserEntity _currentUser = UserEntity(
    fullName: '',
    phoneNumber: '',
    password: '',
    createdTime: DateTime.now(),
    lastLoginTime: DateTime.now(),
    allowJob: {'流量端':0,'承接端':0, '直销端':0, '转化端':0, '数据端':0},
  );

  // 登录状态标志
  bool _isLoggedIn = false;
  
  // 加载状态
  bool _isLoading = false;
  
  // 错误信息
  String? _errorMessage;

  // 获取当前登录用户信息
  UserEntity get currentUser => _currentUser;

  // 检查用户是否已登录
  bool get isLoggedIn => _isLoggedIn;
  
  // 获取加载状态
  bool get isLoading => _isLoading;
  
  // 获取错误信息
  String? get errorMessage => _errorMessage;

  // 相关用户列表
  List<UserEntity> _usersList = [];

  // 获取相关用户列表
  List<UserEntity> get usersList => _usersList;

  // 设置相关用户列表
  void setUsersList(List<UserEntity> users) {
    _usersList = users;
    notifyListeners();
  }

  // 设置用户信息并登录
  void setUserAndLogin(UserEntity user) {
    _currentUser = user;
    _isLoggedIn = true;
    _errorMessage = null;
    notifyListeners();
  }

  // 登出用户
  Future<void> logoutUser() async {
    // 清除本地存储的登录凭证
    await StorageUtils.clearLastLoginCredentials();
    
    // 重置用户信息
    _resetUser();
    notifyListeners();
  }

  // 更新用户信息
  void updateUserInfo({
    String? fullName,
    String? phoneNumber,
    String? password,
    int? selectedId,
    DateTime? createdTime,
    DateTime? lastLoginTime,
  }) {
    // 利用UserEntity的copyWith方法来更新用户信息，保持不可变对象的特性
    _currentUser = _currentUser.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      password: password,
      createdTime: createdTime,
      lastLoginTime: lastLoginTime,
      job: selectedId != null ? JobUtils.idToString(selectedId) : _currentUser.job,
    );
    notifyListeners();
  }

  // 重置用户信息为默认状态
  void _resetUser() {
    _currentUser = UserEntity(
      fullName: '',
      phoneNumber: '',
      password: '',
      createdTime: DateTime.now(),
      lastLoginTime: DateTime.now(),
      allowJob: {'流量端':0,'承接端':0, '直销端':0, '转化端':0, '数据端':0},
    );
    _isLoggedIn = false;
  }
  
  // 设置加载状态
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // 设置错误信息
  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
