import 'dart:math';
import 'dart:convert';
import 'package:intl/intl.dart';

/// 成功数据实体类 - 定义数据库succ_data数据表的数据结构
class SuccDataEntity {
  // 数据库ID，自增
  final int? id;
  
  // 记录ID
  String recordId;
  
  // 核心数据属性
  final String studentName;         // 姓名
  final String succLl;       // 流量端
  final String succCj;       // 承接端
  final String succZx;       // 直销端
  final String succZh;       // 转化端
  final int c0;              // C0值 (0或1)
  final int c1;              // C1值 (0或1)
  final DateTime succDate;     // 成功日期
  final DateTime classDate;    // 交付时间
  final DateTime updateDate;   // 更新日期

  /// 构造函数 - 创建成功数据实体实例
  SuccDataEntity({
    int? id,
    String? recordId,
    required this.studentName,
    required this.succLl,
    required this.succCj,
    required this.succZx,
    required this.succZh,
    required this.c0,
    required this.c1,
    required this.succDate,
    required this.classDate,
    DateTime? updateDate,
  }) : id = id ?? _generateSuccID(),  
       recordId = recordId ?? '',
       updateDate = updateDate ?? DateTime.now();

  /// 生成唯一的succID
  /// 格式：纯数字 (时间戳 + 随机数)
  static int _generateSuccID() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    // 将时间戳和随机数组合成纯数字字符串
    return int.parse('${timestamp}${random.toString().padLeft(4, '0')}');
  }

  /// 从数据库Map转换为实体
  factory SuccDataEntity.fromMap(Map<String, dynamic> map) {
    return SuccDataEntity(
      recordId: map['record_id'] as String?,
      id: map['id'] as int?,
      studentName: map['student_name'] as String? ?? '',
      succLl: map['succ_ll'] as String? ?? '',
      succCj: map['succ_cj'] as String? ?? '',
      succZx: map['succ_zx'] as String? ?? '',
      succZh: map['succ_zh'] as String? ?? '',
      c0: map['class_type'] == '月训班' ? 1 : 0,
      c1: map['class_type'] == '中级班' ? 1 : 0,
      succDate: DateTime.parse(map['succ_date']),
      classDate: DateTime.parse(map['base_class_date']),
      updateDate: DateTime.parse(map['update_date']),
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'record_id': recordId,
      'id': id,
      'student_name': studentName,    
      'succ_ll': succLl,
      'succ_cj': succCj,
      'succ_zx': succZx,
      'succ_zh': succZh,
      'succ_date': DateFormat('yyyy-MM-dd').format(succDate),
      'base_class_date': DateFormat('yyyy-MM-dd').format(classDate), 
      'update_date': DateFormat('yyyy-MM-dd').format(updateDate),
      'class_type': c0==1?'月训班':
                    c1==1?'中级班':'进阶课',
    };
  }

  /// 创建一个新的成功数据实体，仅修改指定的属性
  /// 方便在不改变原有实体的情况下更新部分属性
  SuccDataEntity copyWith({
    int? id,
    String? recordId,
    String? succID,
    String? name,
    String? succLl,
    String? succCj,
    String? succZx,
    String? succZh,
    String? succDate,
    String? classDate,
    String? updateDate,
    int? c0,
    int? c1,
  }) {
    return SuccDataEntity(
      recordId: recordId ?? this.recordId,
      id: id ?? this.id,
      studentName: studentName,
      succLl: succLl ?? this.succLl,
      succCj: succCj ?? this.succCj,
      succZx: succZx ?? this.succZx,
      succZh: succZh ?? this.succZh,
      c0: c0 ?? this.c0,
      c1: c1 ?? this.c1,
      succDate: DateTime.parse(succDate ?? this.succDate.toString()),
      classDate: DateTime.parse(classDate ?? this.classDate.toString()),
      updateDate: DateTime.parse(updateDate ?? this.updateDate.toString()),
    );
  }

  /// 转换为JSON字符串
  String toJson() {
    return jsonEncode({
      'recordId': recordId,
      'id': id,
      'studentName': studentName,
      'succLl': succLl,
      'succCj': succCj,
      'succZx': succZx,
      'succZh': succZh,
      'c0': c0,
      'c1': c1,
    });
  }

  /// 从JSON字符串创建成功数据实体
  factory SuccDataEntity.fromJson(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return SuccDataEntity(
      recordId: map['recordId'] as String?,
      id: map['id'] as int?,
      studentName: map['studentName'] as String? ?? '',
      succLl: map['succLl'] as String? ?? '',
      succCj: map['succCj'] as String? ?? '',
      succZx: map['succZx'] as String? ?? '',
      succZh: map['succZh'] as String? ?? '',
      c0: map['c0'] as int? ?? 0,
      c1: map['c1'] as int? ?? 0,
      succDate: DateTime.parse(map['succDate'] as String? ?? ''),
      classDate: DateTime.parse(map['classDate'] as String? ?? ''),
      updateDate: DateTime.parse(map['updateDate'] as String? ?? ''),
    );
  }

  /// 格式化字符串表示
  @override
  String toString() {
    return 'SuccDataEntity{id: $id, recordId: $recordId, id: $id, studentName: $studentName, succLl: $succLl, succCj: $succCj, succZx: $succZx, succZh: $succZh, c0: $c0, c1: $c1}';
  }

  /// 比较两个成功数据实体是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuccDataEntity &&
        other.recordId == recordId &&
        other.id == id &&
        other.studentName == studentName &&
        other.succLl == succLl &&
        other.succCj == succCj &&
        other.succZx == succZx &&
        other.succZh == succZh &&
        other.c0 == c0 &&
        other.c1 == c1;
  }

  /// 生成哈希码
  @override
  int get hashCode {
    return Object.hash(
        recordId, id, studentName, succLl, succCj, succZx, succZh, c0, c1);
  }

  // 私有辅助方法：解析二进制值（确保返回0或1）
  static int _parseBinaryValue(dynamic value) {
    if (value == null) return 0;
    if (value is bool) {
      return value ? 1 : 0;
    } else if (value is String) {
      final intVal = int.tryParse(value);
      return (intVal != null && (intVal == 0 || intVal == 1)) ? intVal : 0;
    } else if (value is int) {
      return (value == 0 || value == 1) ? value : 0;
    }
    return 0;
  }

  /// 从飞书API返回的Map转换为实体对象
  factory SuccDataEntity.fromFeishuMap(Map<String, dynamic> map) {
    final fields = map['fields'] as Map<String, dynamic>? ?? {};
    final recordId = map['record_id'] as String?;
    
    // 安全地解析日期字段
    DateTime parseDateField(dynamic dateField) {
      if (dateField == null) {
        return DateTime.now();
      }
      if (dateField is String) {
        try {
          return DateTime.parse(dateField);
        } catch (_) {
          // 如果解析失败，返回当前时间
          return DateTime.now();
        }
      }
      // 其他类型，返回当前时间
      return DateTime.now();
    }
    
    return SuccDataEntity(
      recordId: recordId,
      id:  int.tryParse(fields['ID'] as String) ?? 0,
      studentName: fields['姓名'] as String? ?? '',
      succLl: fields['流量端'] as String? ?? '',
      succCj: fields['承接端'] as String? ?? '',
      succZx: fields['直销端'] as String? ?? '',
      succZh: fields['转化端'] as String? ?? '',
      c0: _parseBinaryValue(fields['C0']),
      c1: _parseBinaryValue(fields['C1']),
      succDate: parseDateField(fields['报名时间']),
      classDate: parseDateField(fields['基础课时间']),
      updateDate: parseDateField(fields['填写时间']),
    );
  }

  /// 转换为飞书API所需的Map格式
  Map<String, dynamic> toFeishuMap() {
      var map = {
      'record_id': recordId,
      'fields': {
        'ID': id,
        '姓名': studentName,
        '流量端': succLl,
        '承接端': succCj,
        '直销端': succZx,
        '转化端': succZh,
        'C0': c0,
        'C1': c1,
        '报名时间': DateFormat('yyyy-MM-dd').format(succDate),
        '基础课时间': DateFormat('yyyy-MM-dd').format(classDate),
        '填写时间': DateFormat('yyyy-MM-dd').format(updateDate),
      },
    };
    return map;
  }
}
