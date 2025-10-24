import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ssr/domain/entity/user.dart';
import 'package:ssr/domain/usecases/job_resources.dart';
import 'package:ssr/presentation/auth/util/storage_utils.dart';

/// 用户信息状态管理类
class UserProvider extends ChangeNotifier {
  String _userUid = ''; // 唯一ID
  String _userOpenid = ''; // 登录ID
  String _userName = ''; // 用户全名
  String _permissions = ''; // 权限
  String _department = ''; // 部门
  String _entryTime = ''; // 入职时间
  String _profilePhotoUrl = ''; // 头像URL
  String _token = ''; // 登录令牌
  bool _fullTimeJob = false; // 是否全职
  bool _isVip = false; // 是否会员

  String get token => _token;
  String get userUid => _userUid;
  String get userId => _userOpenid;
  String get userName => _userName;
  String get permissions => _permissions;
  String get department => _department;
  String get entryTime => _entryTime;
  String get profilePhotoUrl => _profilePhotoUrl;
  bool get fullTimeJob => _fullTimeJob;
  bool get isVip => _isVip;

  /// 设置用户信息
  void setUserInfoBatch(Map<String, dynamic> user) {
    _userUid = user['user_uid'] as String? ?? '';
    _userOpenid = user['user_openid'] as String? ?? '';
    _userName = user['user_name'] as String? ?? '';
    _permissions = user['permissions'] as String? ?? '';
    _department = user['department'] as String? ?? '';
    _entryTime = user['entry_time'] as String? ?? '';
    _profilePhotoUrl = user['profile_photo_url'] as String? ?? '';
    _token = user['token'] as String? ?? '';
    _fullTimeJob = user['full_time_job'] as bool? ?? false;
    _isVip = user['is_vip'] as bool? ?? false;
    notifyListeners();
  }
}
