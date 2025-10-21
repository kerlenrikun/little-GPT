import 'dart:convert';

/// 评论实体类 - 定义文章评论数据结构和操作
class Comment {
  // 核心评论属性
  final String commentId; // UUID
  final String articleId; // 文章ID
  final int? start; // 可选：定位start
  final int? end; // 可选：定位end
  final String userId; // 用户ID
  final String text; // 选中内容
  final String comment; // 评论内容
  final DateTime createdAt; // 创建时间
  final DateTime updatedAt; // 更新时间
  final String deleted; // 本地删除标记（墓碑标记）

  /// 构造函数 - 创建评论实体实例
  Comment({
    required this.commentId,
    required this.articleId,
    this.start,
    this.end,
    required this.userId,
    required this.text, // 选中内容
    required this.comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deleted = '0',
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 创建一个新的评论实体，仅修改指定的属性
  Comment copyWith({
    String? commentId,
    String? articleId,
    int? start,
    int? end,
    String? userId,
    String? text, // 选中内容
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deleted,
  }) {
    return Comment(
      commentId: commentId ?? this.commentId,
      articleId: articleId ?? this.articleId,
      start: start ?? this.start,
      end: end ?? this.end,
      userId: userId ?? this.userId,
      text: text ?? this.text, // 选中内容
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
    );
  }

  /// 从数据库Map转换为Comment
  factory Comment.fromLoMap(Map<String, dynamic> map) {
    return Comment(
      commentId: map['id'] as String? ?? '',
      articleId: map['article_id'] as String? ?? '',
      start: map['start'] as int?,
      end: map['end'] as int?,
      userId: map['user_id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      comment: map['comment'] as String? ?? '',
      createdAt: DateTime.parse(map['created_time'] as String),
      updatedAt: DateTime.parse(map['updated_time'] as String),
      deleted: map['deleted'] as String? ?? '0',
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toLoMap() {
    return {
      'comment_id': commentId,
      'article_id': articleId,
      'start': start,
      'end': end,
      'user_id': userId,
      'text': text, // 选中内容
      'comment': comment,
      'created_time': createdAt.toIso8601String(),
      'updated_time': updatedAt.toIso8601String(),
      'deleted': deleted == '1' ? '1' : '0',
    };
  }

  /// 从云端Map转换为Comment
  factory Comment.fromClMap(Map<String, dynamic> map) {
    return Comment(
      commentId: map['comment_id'] as String? ?? '',
      articleId: map['article_id'] as String? ?? '',
      start: map['start'] as int?,
      end: map['end'] as int?,
      userId: map['user_id'] as String? ?? '',
      text: map['text'] as String? ?? '', // 选中内容
      comment: map['comment'] as String? ?? '',
      createdAt: map['create_time'] != null
          ? DateTime.parse(map['create_time'] as String)
          : DateTime.now(),
      updatedAt: map['updated_time'] != null
          ? DateTime.parse(map['updated_time'] as String)
          : DateTime.now(),
      deleted: map['deleted'] as String? ?? '0',
    );
  }

  /// 转换为云端Map
  Map<String, dynamic> toClMap() {
    return {
      'comment_id': commentId,
      'article_id': articleId,
      'start': start,
      'end': end,
      'user_id': userId,
      'comment': comment,
      'created_time': createdAt.toIso8601String(),
      'updated_time': updatedAt.toIso8601String(),
      'deleted': deleted,
    };
  }

  /// 格式化字符串表示
  @override
  String toString() {
    final commentPreview = comment.length > 50
        ? '${comment.substring(0, 50)}...'
        : comment;

    return '评论信息：ID：$commentId，文章ID：$articleId，用户ID：$userId，评论内容：$commentPreview，创建时间：${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
  }

  /// 比较两个评论实体是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Comment) return false;
    return other.toString() == toString();
  }

  /// 获取哈希码
  @override
  int get hashCode {
    return toString().hashCode;
  }

  /// 判断两个实体是否相同（深度比较）
  bool isSame(Comment other) {
    if (identical(this, other)) return true;

    return this.commentId == other.commentId &&
        this.articleId == other.articleId &&
        this.start == other.start &&
        this.end == other.end &&
        this.userId == other.userId &&
        this.comment == other.comment &&
        this.deleted == other.deleted;
  }
}
