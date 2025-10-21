import 'package:sqflite/sqflite.dart';
import 'package:ssr/data/service/local/database_manager.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class ArticleDbManager {
  final dbHelper = DatabaseManager();

  /// 插入文章
  Future<int> insertArticle(Map<String, dynamic> article) async {
    final db = await dbHelper.database;
    return await db.insert(
      'articles',
      article,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取文章
  Future<Map<String, dynamic>?> getArticle(String article_id) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'articles',
      where: 'article_id = ?',
      whereArgs: [article_id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// 插入高亮（收藏）
  Future<int> insertHighlight(Map<String, dynamic> data) async {
    final db = await dbHelper.database;
    return await db.insert('highlights', {
      ...data,
      'highlight_id': uuid.v4(),
      'created_time': DateTime.now().toIso8601String(),
      'updated_time': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 插入高亮（收藏）
  Future<int> insertHighlightFromCl(Map<String, dynamic> data) async {
    final db = await dbHelper.database;
    return await db.insert(
      'highlights',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取文章对应的所有高亮
  Future<List<Map<String, dynamic>>> getHighlights(String articleId) async {
    final db = await dbHelper.database;
    return await db.query(
      'highlights',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );
  }

  /// 插入评论
  Future<int> insertComment(Map<String, dynamic> data) async {
    final db = await dbHelper.database;
    return await db.insert(
      'comments',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 插入评论
  Future<int> insertCommentFromCl(Map<String, dynamic> data) async {
    final db = await dbHelper.database;
    return await db.insert(
      'comments',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取文章对应评论
  Future<List<Map<String, dynamic>>> getComments(String articleId) async {
    final db = await dbHelper.database;
    return await db.query(
      'comments',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );
  }

  /// 删除某篇文章的本地数据（用于同步更新）
  Future<void> deleteArticleData(String articleId) async {
    final db = await dbHelper.database;
    await db.delete(
      'highlights',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );
    await db.delete(
      'comments',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );
  }

  Future<void> deleteHighlight(String highlightId) async {
    final db = await dbHelper.database;
    await db.delete(
      'highlights',
      where: 'highlight_id = ?',
      whereArgs: [highlightId],
    );
  }

  Future<void> updateComment(String commentId, String newText) async {
    final db = await dbHelper.database;
    await db.update(
      'comments',
      {'text': newText},
      where: 'comment_id = ?',
      whereArgs: [commentId],
    );
  }
}
