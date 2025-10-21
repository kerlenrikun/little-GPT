import 'dart:convert';

/// 系列实体类 - 定义音频系列数据结构和操作
class SeriesEntity {
  final String recordId; // UID
  final String seriesName; // 系列名称
  final String seriesType; // 系列类型
  final List<String> seriesId; // 系列ID（字符串列表类型）
  final List<Map<String, dynamic>> seriesContent; // 系列内容

  SeriesEntity({
    this.recordId = '',
    this.seriesId = const [], // 空列表作为默认值
    this.seriesName = '',
    this.seriesType = '',
    this.seriesContent = const [],
  });

  /// 创建一个新的系列实体，仅修改指定的属性
  /// 方便在不改变原有实体的情况下更新部分属性
  SeriesEntity copyWith({
    String? recordId,
    List<String>? seriesId,
    String? seriesName,
    String? seriesType,
    List<Map<String, dynamic>>? seriesContent,
  }) {
    return SeriesEntity(
      recordId: recordId ?? this.recordId,
      seriesId: seriesId ?? this.seriesId,
      seriesName: seriesName ?? this.seriesName,
      seriesType: seriesType ?? this.seriesType,
      seriesContent: seriesContent ?? this.seriesContent,
    );
  }

  /// 从数据库Map转换为SeriesEntity
  factory SeriesEntity.fromLoMap(Map<String, dynamic> map) {
    // 解析seriesContent，需要先解码JSON字符串
    List<Map<String, dynamic>> parsedSeriesContent = [];
    final seriesContentStr = map['series_content'] as String?;
    if (seriesContentStr != null && seriesContentStr.isNotEmpty) {
      try {
        final decoded = _parseJson(seriesContentStr);
        if (decoded is List) {
          // 如果是List类型，直接转换
          parsedSeriesContent = decoded.map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }
            return <String, dynamic>{};
          }).toList();
        } else if (decoded is Map) {
          // 兼容旧格式，将Map转换为List
          decoded.forEach((key, value) {
            if (value is Map) {
              final item = Map<String, dynamic>.from(value);
              parsedSeriesContent.add(item);
            }
          });
        }
      } catch (e) {
        print('解析seriesContent失败: $e');
      }
    }

    return SeriesEntity(
      recordId: map['record_id'] as String? ?? '',
      // 解析seriesId为List<String>
      seriesId: _parseSeriesId(map['series_id']),
      seriesName: map['series_name'] as String? ?? '',
      seriesType: map['series_type'] as String? ?? '',
      seriesContent: parsedSeriesContent,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toLoMap() {
    // 将seriesContent转换为JSON字符串存储
    final seriesContentJson = _toJson(seriesContent);

    return {
      'record_id': recordId,
      // 将List<String>转换为JSON字符串存储
      'series_id': _toJson(seriesId),
      'series_name': seriesName,
      'series_type': seriesType,
      'series_content': seriesContentJson,
    };
  }

  /// 从云端Map转换为SeriesEntity
  factory SeriesEntity.fromClMap(Map<String, dynamic> map) {
    // 处理seriesContent
    List<Map<String, dynamic>> parsedSeriesContent = [];
    final seriesContentData = map['seriesContent'];

    if (seriesContentData is Map) {
      // 兼容旧格式(Map)，将其转换为List
      seriesContentData.forEach((key, value) {
        if (value is Map) {
          final item = Map<String, dynamic>.from(value);
          parsedSeriesContent.add(item);
        }
      });
    } else if (seriesContentData is List) {
      // 新格式(List)，直接转换
      parsedSeriesContent = seriesContentData.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }

    return SeriesEntity(
      recordId: map['seriesId'] as String? ?? '',
      // 解析seriesId为List<String>
      seriesId: _parseSeriesId(map['seriesId']),
      seriesName: map['seriesName'] as String? ?? '',
      seriesType: map['seriesType'] as String? ?? '',
      seriesContent: parsedSeriesContent,
    );
  }

  /// 转换为云端Map
  Map<String, dynamic> toClMap() {
    return {
      'seriesId': seriesId,
      'seriesName': seriesName,
      'seriesType': seriesType,
      'seriesContent': seriesContent,
    };
  }

  /// 格式化字符串表示 - 向量化专用
  @override
  String toString() {
    return '系列信息：ID：$seriesId，名称：$seriesName，类型：$seriesType，记录ID：$recordId，内容数量：${seriesContent.length}';
  }

  /// 比较两个系列实体是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeriesEntity &&
        other.recordId == recordId &&
        other.seriesId == seriesId &&
        other.seriesName == seriesName &&
        other.seriesType == seriesType &&
        _areListsEqual(other.seriesContent, seriesContent);
  }

  @override
  int get hashCode {
    return recordId.hashCode ^
        seriesId.hashCode ^
        seriesName.hashCode ^
        seriesType.hashCode ^
        _listHashCode(seriesContent);
  }

  /// 辅助方法：比较两个List<Map>是否相等
  bool _areListsEqual(
    List<Map<String, dynamic>> list1,
    List<Map<String, dynamic>> list2,
  ) {
    if (list1.length != list2.length) return false;

    // 对于列表比较，我们假设元素顺序不重要，只比较内容
    // 创建临时集合来跟踪已经匹配的元素
    final matchedIndices = <int>{};

    for (int i = 0; i < list1.length; i++) {
      bool foundMatch = false;
      for (int j = 0; j < list2.length; j++) {
        if (!matchedIndices.contains(j) && _areMapsEqual(list1[i], list2[j])) {
          matchedIndices.add(j);
          foundMatch = true;
          break;
        }
      }
      if (!foundMatch) return false;
    }

    return true;
  }

  /// 辅助方法：比较两个Map是否相等
  bool _areMapsEqual(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;

    for (final key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      if (map1[key] != map2[key]) return false;
    }

    return true;
  }

  /// 辅助方法：计算List<Map>的哈希码
  int _listHashCode(List<Map<String, dynamic>> list) {
    int hashCode = 0;
    for (final map in list) {
      // 对每个map的键排序后计算哈希码，确保顺序不影响结果
      final sortedKeys = map.keys.toList()..sort();
      for (final key in sortedKeys) {
        hashCode ^= key.hashCode ^ map[key].hashCode;
      }
    }
    return hashCode;
  }

  /// 辅助方法：解析JSON字符串
  static dynamic _parseJson(String jsonString) {
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      print('解析JSON失败: $e');
      return null;
    }
  }

  /// 辅助方法：转换为JSON字符串
  static String _toJson(dynamic value) {
    try {
      return jsonEncode(value);
    } catch (e) {
      print('转换JSON失败: $e');
      return '{}';
    }
  }

  /// 辅助方法：解析seriesId为List<String>
  static List<String> _parseSeriesId(dynamic value) {
    if (value == null) return const [];

    if (value is List) {
      // 已经是List类型，确保元素都是String
      return value
          .where((item) => item is String)
          .map((item) => item as String)
          .toList();
    } else if (value is String) {
      if (value.startsWith('[') && value.endsWith(']')) {
        // 尝试解析为JSON数组
        try {
          final List parsed = jsonDecode(value);
          return parsed
              .where((item) => item is String)
              .map((item) => item as String)
              .toList();
        } catch (e) {
          print('解析seriesId JSON数组失败: $e');
          return const [];
        }
      } else {
        // 单个字符串，转换为包含单个元素的列表
        return [value];
      }
    }

    return const [];
  }
}
