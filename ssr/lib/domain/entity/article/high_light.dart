import 'dart:convert';

/// 高亮实体类 - 定义文章高亮标记的数据结构和操作
class Highlight {
  final String highlightId; // 用户ID
  final String userId; // 用户ID
  final String articleId; // 文章ID
  final int start; // 在文章内容中的起始索引（字符偏移量）
  final int end; // 结束索引（不包含）
  final String text; // 被收藏的实际文本（快照）
  final String? color;
  final DateTime createdAt; // 创建时间
  final DateTime updatedAt; // 更新时间
  final bool deleted; // 本地删除标记（墓碑标记）

  /// 构造函数 - 创建高亮实体实例
  Highlight({
    required this.highlightId,
    required this.userId,
    required this.articleId,
    required this.start,
    required this.end,
    required this.text,
    required this.color,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deleted = false,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 创建一个新的高亮实体，仅修改指定的属性
  Highlight copyWith({
    String? highlightId,
    String? userId,
    String? articleId,
    int? start,
    int? end,
    String? text,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? deleted,
  }) {
    return Highlight(
      highlightId: highlightId ?? this.highlightId,
      userId: userId ?? this.userId,
      articleId: articleId ?? this.articleId,
      start: start ?? this.start,
      end: end ?? this.end,
      text: text ?? this.text,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }

  /// 从数据库Map转换为Highlight
  factory Highlight.fromLoMap(Map<String, dynamic> map) {
    return Highlight(
      highlightId: map['highlight_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      articleId: map['article_id'] as String? ?? '',
      start: map['start'] as int? ?? 0,
      end: map['end'] as int? ?? 0,
      text: map['text'] as String? ?? '',
      color: map['color'] as String? ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'].toString())
          : DateTime.now(),
      deleted: map['deleted'] == 1 || map['deleted'] == true,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toLoMap() {
    return {
      'highlight_id': highlightId,
      'user_id': userId,
      'article_id': articleId,
      'start': start,
      'end': end,
      'text': text,
      'color': color,
      'created_time': createdAt.toIso8601String(),
      'updated_time': updatedAt.toIso8601String(),
      'deleted': deleted ? 1 : 0,
    };
  }

  /// 从云端Map转换为Highlight
  factory Highlight.fromClMap(Map<String, dynamic> map) {
    return Highlight(
      highlightId: map['highlight_id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      articleId: map['articleId'] as String? ?? '',
      start: map['start'] as int? ?? 0,
      end: map['end'] as int? ?? 0,
      text: map['text'] as String? ?? '',
      color: map['color'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'].toString())
          : DateTime.now(),
      deleted: map['deleted'] == true,
    );
  }

  /// 转换为云端Map
  Map<String, dynamic> toClMap() {
    return {
      'highlight_id': highlightId,
      'userId': userId,
      'articleId': articleId,
      'start': start,
      'end': end,
      'text': text,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deleted': deleted,
    };
  }

  /// 格式化字符串表示
  @override
  String toString() {
    return '高亮信息：ID：$highlightId，文章ID：$articleId，起始位置：$start-$end，文本：${text.length > 20 ? text.substring(0, 20) + '...' : text}，颜色：$color，创建时间：${createdAt.year}年${createdAt.month}月${createdAt.day}日';
  }

  /// 比较两个高亮实体是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Highlight && other.highlightId == highlightId;
  }

  @override
  int get hashCode => highlightId.hashCode;

  /// 判断两个实体是否相同
  bool isSame(Highlight other) {
    return this.highlightId == other.highlightId &&
        this.start == other.start &&
        this.end == other.end &&
        this.text == other.text;
  }
}
