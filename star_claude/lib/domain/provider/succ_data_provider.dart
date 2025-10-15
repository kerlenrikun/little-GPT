import 'package:flutter/material.dart';
import 'package:star_claude/domain/entities/data/succ_data.dart';

/// 成功数据状态管理类
/// 只提供必要的全局状态共享，具体数据操作由Repository负责
class SuccDataProvider extends ChangeNotifier {
  // 私有变量定义
  List<SuccDataEntity> _succDataList = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 公共核心变量定义
  /// 获取成功数据列表
  List<SuccDataEntity> get succDataList => List.unmodifiable(_succDataList);
  
  /// 获取加载状态
  bool get isLoading => _isLoading;
  
  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  // 设置成功数据列表
  /// [dataList] - 要设置的成功数据列表
  void setSuccDataList(List<SuccDataEntity> dataList) {
    _succDataList = List.from(dataList); // 创建新列表以保持不可变性
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

  // 清空所有成功数据
  void clearAllSuccData() {
    _succDataList.clear();
    notifyListeners();
  }
}