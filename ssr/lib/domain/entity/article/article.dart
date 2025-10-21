import 'dart:convert';

/// 文章实体类 - 定义文章数据结构和操作
class Article {
  final String recordId;
  final String articleId;
  final String title;
  final String authorName;
  final String imageUrl;
  final String videoUrl;
  final String audioUrl;
  final String source;
  final DateTime publishTime;
  final String content;
  final String contentHash;
  final bool deleted;

  Article({
    required this.recordId,
    required this.articleId,
    required this.title,
    required this.authorName,
    required this.imageUrl,
    required this.videoUrl,
    required this.audioUrl,
    required this.source,
    required this.publishTime,
    required this.content,
    required this.contentHash,
    required this.deleted,
  });

  /// 创建一个新的文章实体，仅修改指定的属性
  Article copyWith({
    String? recordId,
    String? articleId,
    String? title,
    String? authorName,
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
    String? source,
    DateTime? publishTime,
    String? content,
    String? contentHash,
    bool? deleted,
  }) {
    return Article(
      recordId: recordId ?? this.recordId,
      articleId: articleId ?? this.articleId,
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      source: source ?? this.source,
      publishTime: publishTime ?? this.publishTime,
      content: content ?? this.content,
      contentHash: contentHash ?? this.contentHash,
      deleted: deleted ?? this.deleted,
    );
  }

  /// 从数据库Map转换为Article
  factory Article.fromLoMap(Map<String, dynamic> map) {
    return Article(
      recordId: map['record_id'] as String? ?? '',
      articleId: map['article_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      authorName: map['author_name'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      videoUrl: map['video_url'] as String? ?? '',
      audioUrl: map['audio_url'] as String? ?? '',
      source: map['source'] as String? ?? '',
      publishTime: map['publish_time'] != null
          ? DateTime.parse(map['publish_time'].toString())
          : DateTime.now(),
      content: map['content'] as String? ?? '',
      contentHash: map['content_hash'] as String? ?? '',
      deleted: map['deleted'] == 1 || map['deleted'] == true,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toLoMap() {
    return {
      'article_id': articleId,
      'title': title,
      'author_name': authorName,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'audio_url': audioUrl,
      'source': source,
      'publish_time': publishTime.toIso8601String(),
      'content': content,
      'content_hash': contentHash,
      'deleted': deleted ? 1 : 0,
    };
  }

  /// 从云端Map转换为Article
  factory Article.fromClMap(Map<String, dynamic> map) {
    return Article(
      recordId:
          map['article_id'] as String? ?? map['article_id'] as String? ?? '',
      articleId: map['article_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      authorName: map['author_name'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      videoUrl: map['video_url'] as String? ?? '',
      audioUrl: map['audio_url'] as String? ?? '',
      source: map['source'] as String? ?? '',
      publishTime: map['publish_time'] != null
          ? DateTime.parse(map['publish_time'].toString())
          : DateTime.now(),
      content: map['article_content'] as String? ?? '',
      contentHash: map['article_hash'] as String? ?? '',
      deleted: map['deleted'] == true,
    );
  }

  /// 转换为云端Map
  Map<String, dynamic> toClMap() {
    return {
      'recordId': recordId,
      'articleId': articleId,
      'title': title,
      'authorName': authorName,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'audioUrl': audioUrl,
      'source': source,
      'publishTime': publishTime.toIso8601String(),
      'content': content,
      'contentHash': contentHash,
      'deleted': deleted,
    };
  }

  /// 格式化字符串表示
  @override
  String toString() {
    return '文章信息：ID：$articleId，标题：$title，作者：$authorName，来源：$source，发布时间：${publishTime.year}年${publishTime.month}月${publishTime.day}日，是否删除：$deleted';
  }

  /// 比较两个文章实体是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Article && other.articleId == articleId;
  }

  @override
  int get hashCode => articleId.hashCode;

  /// 判断两个实体是否相同
  bool isSame(Article other) {
    return this.articleId == other.articleId &&
        this.contentHash == other.contentHash;
  }
}
