import 'dart:convert';

/// 系列内容实体类 - 定义系列内容的数据结构和操作
/// 用于表示和处理系列内容相关信息
class SeriesContent {
  // 核心系列内容属性
  final String recordId; // 记录ID
  final String audioId; // 音频ID
  final String sort; // 排序
  final String name; // 名称
  final String type; // 类型

  /// 构造函数 - 创建系列内容实体实例
  SeriesContent({
    required this.recordId,
    required this.audioId,
    required this.sort,
    required this.name,
    required this.type,
  });

  /// 创建一个新的系列内容实体，仅修改指定的属性
  /// 方便在不改变原有实体的情况下更新部分属性
  SeriesContent copyWith({
    String? recordId,
    String? audioId,
    String? sort,
    String? name,
    String? type,
  }) {
    return SeriesContent(
      recordId: recordId ?? this.recordId,
      audioId: audioId ?? this.audioId,
      sort: sort ?? this.sort,
      name: name ?? this.name,
      type: type ?? this.type,
    );
  }

  /// 从数据库Map转换为SeriesContent
  factory SeriesContent.fromLoMap(Map<String, dynamic> map) {
    return SeriesContent(
      recordId: map['record_id'] as String? ?? '',
      audioId: map['audio_id'] as String? ?? '',
      sort: map['sort'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? '',
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toLoMap() {
    return {
      'record_id': recordId,
      'audio_id': audioId,
      'sort': sort,
      'name': name,
      'type': type,
    };
  }

  /// 从云端Map转换为SeriesContent
  factory SeriesContent.fromClMap(Map<String, dynamic> map) {
    return SeriesContent(
      recordId: map['recordId'] as String? ?? '',
      audioId: map['audioId'] as String? ?? '',
      sort: map['sort'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? '',
    );
  }

  /// 转换为云端Map
  Map<String, dynamic> toClMap() {
    return {
      'recordId': recordId,
      'audioId': audioId,
      'sort': sort,
      'name': name,
      'type': type,
    };
  }

  /// 格式化字符串表示
  @override
  String toString() {
    return '系列内容：ID：$recordId，音频ID：$audioId，排序：$sort，名称：$name，类型：$type';
  }

  /// 比较两个系列内容实体是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeriesContent && other.toString() == toString();
  }
}
