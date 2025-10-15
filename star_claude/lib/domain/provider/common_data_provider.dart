import 'package:flutter/material.dart';
import 'package:star_claude/domain/entities/auth/user.dart';
import 'package:star_claude/domain/entities/data/common_data.dart';

/// 通用数据状态管理类
/// 只提供必要的全局状态共享，具体数据操作由Repository负责
class CommonDataProvider extends ChangeNotifier {
  // 私有变量定义
  List<CommonData> _commonDataList = [];
  Map<String, List<int>> _totalData = {
    '总体': [0,0,0],
    '流量端': [0,0,0],
    '承接端': [0,0,0],
    '直销端': [0,0,0],
    '转化端': [0,0,0],
  };
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedDk = '流量端';

  // 公共核心变量定义
  /// 获取通用数据列表
  List<CommonData> get commonDataList => List.unmodifiable(_commonDataList);
  
  /// 整体总数据
  Map<String, List<int>> get totalData => _totalData;
  
  /// 检查数据加载状态
  bool get isLoading => _isLoading;
  
  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  /// 数据端选择特有的排名
  String get selectedDk => _selectedDk;

  // 设置selectedDk
  void setSelectedDk(String newselectedDk){
    _selectedDk = newselectedDk;
    notifyListeners();
  }

  /// 设置整体总数据
  /// [totalData] - 要设置的整体总数据
  void setTotalData(Map<String, List<int>> totalData) {
    _totalData = Map.from(totalData);
    _errorMessage = null;
    notifyListeners();
  }
  
  /// 设置通用数据列表
  /// [dataList] - 要设置的通用数据列表
  void setCommonDataList(List<CommonData> dataList) {
    _commonDataList = List.from(dataList); // 创建新列表以保持不可变性
    _errorMessage = null;
    notifyListeners();
  }

  /// 清空所有通用数据
  void clearAllCommonData() {
    _commonDataList.clear();
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
}