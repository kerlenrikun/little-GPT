import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 日期状态管理类
/// 提供全局日期选择状态共享
class DateProvider with ChangeNotifier {
  
  final _dateController = StreamController<DateTime>.broadcast();
  final _rangeController = StreamController<Map<String, DateTime>>.broadcast();

  DateTime _selectedDate = DateTime.now();
  DateTime _rangeStart = DateTime.now();
  DateTime _rangeEnd = DateTime.now();

  /// 获取当前选择的日期
  DateTime get selectedDate => _selectedDate;
  
  /// 获取日期变化流
  Stream<DateTime> get selectedDateStream => _dateController.stream;
  
  /// 获取范围变化流
  Stream<Map<String, DateTime>> get rangeStream => _rangeController.stream;
  
  /// 格式化后的字符串形式（YYYY-MM-DD）
  String get selectedDateStr => DateFormat('yyyy-MM-dd').format(_selectedDate);
  
  /// 获取范围开始日期
  DateTime get rangeStart => _rangeStart;
  
  /// 获取范围结束日期
  DateTime get rangeEnd => _rangeEnd;
  
  /// 格式化后的范围开始日期字符串（YYYY-MM-DD）
  String get startedDateStr => DateFormat('yyyy-MM-dd').format(_rangeStart);
  
  /// 格式化后的范围结束日期字符串（YYYY-MM-DD）
  String get endDateStr => DateFormat('yyyy-MM-dd').format(_rangeEnd);

  /// 设置选择的日期
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _dateController.add(date); // 发送日期变化通知
    notifyListeners();
  }
  
  /// 设置选择的日期范围
  void setDateRange(DateTime start, DateTime end) {
    _rangeStart = start;
    _rangeEnd = end;
    // 更新选中的日期为范围结束日期
    _selectedDate = end;
    // 发送范围变化通知
    _rangeController.add({'start': start, 'end': end});
    _dateController.add(end); // 同时发送日期变化通知
    notifyListeners();
  }

  @override
  void dispose() {
    _dateController.close();
    _rangeController.close();
    super.dispose();
  }
}