import 'dart:async';
import 'package:flutter/material.dart';
import '../entities/data/account_data.dart';

/// 账号数据提供者类
/// 只提供必要的全局状态共享，具体数据操作由Repository负责
class AccountDataProvider extends ChangeNotifier {
  // 账号数据列表
  List<AccountDataEntity> _accountList = [];
  
  // 加载状态
  bool _isLoading = false;
  
  // 错误信息
  String? _errorMessage;

  // 获取账号数据列表
  List<AccountDataEntity> get accountList => List.unmodifiable(_accountList);
  
  // 获取加载状态
  bool get isLoading => _isLoading;
  
  // 获取错误信息
  String? get errorMessage => _errorMessage;

  // 设置账号数据列表
  void setAccountList(List<AccountDataEntity> accounts) {
    _accountList = List.from(accounts); // 创建新列表以保持不可变性
    _errorMessage = null;
    notifyListeners();
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

  // 清空账号列表
  void clearAllAccounts() {
    _accountList.clear();
    notifyListeners();
  }
}