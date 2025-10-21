import 'dart:convert';

/// 音频实体类 - 定义音频数据结构和操作
/// 用于表示和处理音频相关信息----播单
class AudioEntity {
  // 核心音频属性
  final String? recordId; // UID
  final String audioId; // 音频ID
  final String audioName; // 音频名
  final Map<String, dynamic> interaction; // 交互数据，包含收藏和点赞信息
  final List<String> ancestorIds; // 从属播单集合
  final List<String> rootCommentIds; // 根评论ID集合
  final DateTime createdTime; // 创建时间
  final DateTime updatedTime; // 更新时间

  /// 构造函数 - 创建音频实体实例
  AudioEntity({
    this.recordId,
    required this.audioId,
    required this.audioName,
    Map<String, dynamic>? interaction,
    List<String>? ancestorIds,
    List<String>? rootCommentIds,
    DateTime? createdTime,
    DateTime? updatedTime,
  }) : interaction = interaction ?? {'collection': '', 'thump': ''},
       ancestorIds = ancestorIds ?? [],
       rootCommentIds = rootCommentIds ?? [],
       createdTime = createdTime ?? DateTime.now(),
       updatedTime = updatedTime ?? DateTime.now();

  /// 创建一个新的音频实体，仅修改指定的属性
  /// 方便在不改变原有实体的情况下更新部分属性
  AudioEntity copyWith({
    int? id,
    String? recordId,
    String? audioId,
    String? audioName,
    Map<String, String>? interaction,
    List<String>? listAudioId,
    String? listId,
    String? listName,
    List<String>? rootCommentId,
    DateTime? createdTime,
    DateTime? updatedTime,
  }) {
    return AudioEntity(
      recordId: recordId ?? this.recordId,
      audioId: audioId ?? this.audioId,
      audioName: audioName ?? this.audioName,
      interaction: interaction ?? this.interaction,
      ancestorIds: ancestorIds,
      rootCommentIds: rootCommentIds,
      createdTime: createdTime ?? this.createdTime,
      updatedTime: updatedTime ?? this.updatedTime,
    );
  }

  /// 从数据库Map转换为AudioEntity
  factory AudioEntity.fromLoMap(Map<String, dynamic> map) {
    return AudioEntity(
      recordId: map['record_id'] as String?,
      audioId: map['audio_id'] as String? ?? '',
      audioName: map['audio_name'] as String? ?? '',
      interaction: _parseInteraction(map['interaction']),
      ancestorIds: _parseStringList(map['ancestor_ids']),
      rootCommentIds: _parseStringList(map['root_comment_ids']),
      createdTime: DateTime.parse(map['created_time']),
      updatedTime: DateTime.parse(map['updated_time']),
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toLoMap() {
    return {
      'record_id': recordId,
      'audio_id': audioId,
      'audio_name': audioName,
      'interaction': jsonEncode(interaction),
      'ancestor_ids': jsonEncode(ancestorIds),
      'root_comment_ids': jsonEncode(rootCommentIds),
      // 'created_time': createdTime.toIso8601String(),
      // 'updated_time': updatedTime.toIso8601String(),
    };
  }

  /// 从云端Map转换为AudioEntity
  factory AudioEntity.fromClMap(Map<String, dynamic> map) {
    return AudioEntity(
      recordId: map['audioId'] as String?,
      audioId: map['audioId'] as String? ?? '',
      audioName: map['audioName'] as String? ?? '',
      interaction: _parseInteraction(map['interaction']),
      ancestorIds: _parseStringList(map['listId']),
      rootCommentIds: _parseStringList(map['root_comment_ids']),
    );
  }

  /// 转换为云端Map
  Map<String, dynamic> toClMap() {
    return {
      'record_id': recordId,
      'audio_id': audioId,
      'audio_name': audioName,
      'interaction': interaction,
      'ancestor_ids': ancestorIds,
      'root_comment_ids': rootCommentIds,
    };
  }

  /// 格式化字符串表示 - 向量化专用
  @override
  String toString() {
    // 构建交互信息描述
    final collectionInfo = interaction['collection'] ?? '无';
    final thumpInfo = interaction['thump'] ?? '无';
    final audioListInfo = ancestorIds.isNotEmpty
        ? '包含${ancestorIds.length}个音频'
        : '无关联音频';
    final commentInfo = rootCommentIds.isNotEmpty
        ? '包含${rootCommentIds.length}条评论'
        : '无评论';

    return '音频信息：ID：$audioId，名称：$audioName，父亲们：$ancestorIds，收藏：$collectionInfo，点赞：$thumpInfo，$audioListInfo，$commentInfo，创建时间：${createdTime.year}年${createdTime.month}月${createdTime.day}日';
  }

  /// 比较两个音频实体是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioEntity && other.toString() == toString();
  }

  // 私有辅助方法：解析interaction字段
  static Map<String, dynamic> _parseInteraction(dynamic map) {
    // 如果map是字符串，先解析为JSON对象
    if (map is String) {
      try {
        final decodedMap = jsonDecode(map);
        if (decodedMap is Map) {
          map = decodedMap;
        }
      } catch (e) {
        print('解析interaction JSON字符串失败: $e');
        return {'collection': '', 'thump': ''};
      }
    }

    // 如果map不是Map类型，返回默认值
    if (map is! Map) {
      return {'collection': '', 'thump': ''};
    }

    Map<String, String> result = {};
    map.forEach((key, value) {
      result[key.toString()] = value.toString();
    });

    // 确保包含必要的键
    if (!result.containsKey('collection')) {
      result['collection'] = '';
    }
    if (!result.containsKey('thump')) {
      result['thump'] = '';
    }

    return result;
  }

  // 私有辅助方法：解析字符串列表
  static List<String> _parseStringList(dynamic list) {
    // 如果list是字符串，先解析为JSON数组
    if (list is String) {
      try {
        final decodedList = jsonDecode(list);
        if (decodedList is List) {
          list = decodedList;
        }
      } catch (e) {
        print('解析字符串列表JSON失败: $e');
        return [];
      }
    }

    // 如果list不是List类型，返回空列表
    if (list is! List) {
      return [];
    }

    return list.map((item) => item.toString()).toList();
  }
}
