import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ssr/domain/entity/user.dart';
import 'package:ssr/domain/usecases/job_resources.dart';
import 'package:ssr/presentation/auth/util/storage_utils.dart';

/// 用户信息状态管理类
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

  // 获取当前登录用户信息
  UserEntity get currentUser => _currentUser;

  // 检查用户是否已登录
  bool get isLoggedIn => _isLoggedIn;

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
}
