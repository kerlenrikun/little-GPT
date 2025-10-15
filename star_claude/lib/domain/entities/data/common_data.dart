import 'dart:core';
import 'dart:convert';
import 'package:intl/intl.dart';

/// 通用数据实体类 - 定义数据库common数据表的数据结构
class CommonData {
  // 数据库ID，自增
  final int? id;
  
  // 记录ID
  final String? recordId;
  
  // 来源字段
  final String fromLL;
  final String fromCj;
  final String fromZx;
  final String fromZh;
  
  // 目标字段
  final String toLL;
  final String toCj;
  final String toZx;
  final String toZh;

  // 数据值（如加粉数量）
  final int value;
  
  // 日期
  final DateTime date;

  /// 构造函数 - 创建通用数据实体实例
  CommonData({
    this.id,
    this.recordId,
    this.fromLL = '',
    this.fromCj = '',
    this.fromZx = '',
    this.fromZh = '',
    this.toLL = '',
    this.toCj = '',
    this.toZx = '',
    this.toZh = '',
    required this.value,
    required this.date,
  });

  /// 创建一个新的通用数据实体，仅修改指定的属性
  /// 方便在不改变原有实体的情况下更新部分属性
  CommonData copyWith({
    int? id,
    String? recordId,
    String? fromLL,
    String? fromCj,
    String? fromZx,
    String? fromZh,
    String? toLL,
    String? toCj,
    String? toZx,
    String? toZh,
    int? value,
    DateTime? date,
  }) {
    return CommonData(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      fromLL: fromLL ?? this.fromLL,
      fromCj: fromCj ?? this.fromCj,
      fromZx: fromZx ?? this.fromZx,
      fromZh: fromZh ?? this.fromZh,
      toLL: toLL ?? this.toLL,
      toCj: toCj ?? this.toCj,
      toZx: toZx ?? this.toZx,
      toZh: toZh ?? this.toZh,
      value: value ?? this.value,
      date: date ?? this.date,
    );
  }

  /// 从数据库Map转换为实体
  factory CommonData.fromMap(Map<String, dynamic> map) {
    return CommonData(
      id: map['id'] as int?,
      recordId: map['record_id'] as String?,
      fromLL: map['from_ll']?.toString() ?? '',
      fromCj: map['from_cj']?.toString() ?? '',
      fromZx: map['from_zx']?.toString() ?? '',
      fromZh: map['from_zh']?.toString() ?? '',
      toLL: map['to_ll']?.toString() ?? '',
      toCj: map['to_cj']?.toString() ?? '',
      toZx: map['to_zx']?.toString() ?? '',
      toZh: map['to_zh']?.toString() ?? '',
      value: map['value'] as int? ?? 0,
      date: DateTime.parse(map['date']),
    );
  }

  /// 转换为数据库Map 
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'record_id': recordId,
      'from_ll': fromLL,
      'from_cj': fromCj,
      'from_zx': fromZx,
      'from_zh': fromZh,
      'to_ll': toLL,
      'to_cj': toCj,
      'to_zx': toZx,
      'to_zh': toZh,
      'value': value,
      'date': DateFormat('yyyy-MM-dd').format(date),
    };
  }


  /// 转换为JSON字符串
  String toJson() {
    return json.encode(toMap());
  }
  
  /// 从JSON字符串创建实体
  factory CommonData.fromJson(String source) {
    return CommonData.fromMap(json.decode(source) as Map<String, dynamic>);
  }
  
  @override
  String toString() {
    return 'CommonData{id: $id, recordId: $recordId, fromLL: $fromLL, fromCj: $fromCj, fromZx: $fromZx, fromZh: $fromZh, toLL: $toLL, toCj: $toCj, toZx: $toZx, toZh: $toZh, value: $value, date: $date}';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is CommonData &&
        other.id == id &&
        other.recordId == recordId &&
        other.fromLL == fromLL &&
        other.fromCj == fromCj &&
        other.fromZx == fromZx &&
        other.fromZh == fromZh &&
        other.toLL == toLL &&
        other.toCj == toCj &&
        other.toZx == toZx &&
        other.toZh == toZh &&
        other.value == value &&
        other.date == date;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        recordId.hashCode ^
        fromLL.hashCode ^
        fromCj.hashCode ^
        fromZx.hashCode ^
        fromZh.hashCode ^
        toLL.hashCode ^
        toCj.hashCode ^
        toZx.hashCode ^
        toZh.hashCode ^
        value.hashCode ^
        date.hashCode;
  }
  
  /// 从飞书Map转换为CommonData
  factory CommonData.fromFeishuMap(Map<String, dynamic> map) {
      return CommonData(
        recordId: map['record_id'] as String?,
        fromLL: map['fields']['From流量端']?.toString() ?? '',
        fromCj: map['fields']['From承接端']?.toString() ?? '',
        fromZx: map['fields']['From直销端']?.toString() ?? '',
        fromZh: map['fields']['From转化端']?.toString() ?? '',
        toLL: map['fields']['To流量端']?.toString() ?? '',
        toCj: map['fields']['To承接端']?.toString() ?? '',
        toZx: map['fields']['To直销端']?.toString() ?? '',
        toZh: map['fields']['To转化端']?.toString() ?? '',
        value: int.parse(map['fields']['数据值']),
        date: DateTime.parse(map['fields']['日期']),
      );
  }
  
  /// 转换为飞书Map
  Map<String, dynamic> toFeishuMap() {
    return {
      'id': id,
      'recordId': recordId,
      'fields': {
        'From流量端': fromLL,
        'From承接端': fromCj,
        'From直销端': fromZx,
        'From转化端': fromZh,
        'To流量端': toLL,
        'To承接端': toCj,
        'To直销端': toZx,
        'To转化端': toZh,
        '数据值': value,
        '日期': DateFormat('yyyy-MM-dd').format(date),
      },
    };
  }
}