class AudioInfo {
  final String audioId;
  final String listId;
  final String audioName;
  final String listName;
  final List listAudioId;
  final List rootCommentId;
  final Map interaction;

  AudioInfo(
    this.audioId,
    this.listId,
    this.audioName,
    this.listName,
    this.listAudioId,
    this.rootCommentId,
    this.interaction,
  );

  // 从JSON数据创建AudioInfo实体对象
  factory AudioInfo.fromJson(Map<String, dynamic> json) {
    return AudioInfo(
      json['audioId'] ?? '',
      json['listId'] ?? '',
      json['audioName'] ?? '',
      json['listName'] ?? '',
      json['listAudioId'] ?? [],
      json['rootCommentId'] ?? [],
      json['interaction'] ?? {},
    );
  }

  @override
  String toString() =>
      'AudioInfo[$audioId,$listId,$audioName,$listName,$listAudioId,$rootCommentId,$interaction]';
}
