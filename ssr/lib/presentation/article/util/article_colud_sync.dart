import 'package:ssr/dio/utils/dio_utils.dart';
import 'package:ssr/domain/entity/article/article.dart';
import 'package:ssr/domain/entity/article/comment.dart';
import 'package:ssr/domain/entity/article/high_light.dart';
import 'package:ssr/presentation/article/util/article_db_manager.dart';
import 'package:ssr/presentation/article/util/article_provider.dart';

final articleBasePath = 'http://116.62.64.88/xhxsapi/';

class ArticleColudSync {
  final ArticleInfoProvider? articleInfoProvider;

  ArticleColudSync({this.articleInfoProvider});

  Future<dynamic> getArticleInfoById(String id) async {
    try {
      final thisActionPath = articleBasePath + 'article/get-resource/' + id;
      print('正在请求文章信息API: $thisActionPath');

      final response = await DioUtil().get(
        thisActionPath,
        // 可以在这里添加查询参数、选项或取消令牌
        // params: {'key': 'value'},
        // options: Options(headers: {'Authorization': 'Bearer token'}),
      );
      print('文章信息获取成功，状态码: ${response.statusCode}');
      final resourceData = response.data["resource"];

      final article = ArticleEntity.fromClMap(resourceData);
      await ArticleDbManager().insertArticle(article.toLoMap());

      // 解析并存储评论列表
      final commentsData =
          resourceData['article_mark']['comments'] as List<dynamic>?;
      if (commentsData != null) {
        await parseAndInsertComments(commentsData, article.articleId);
      }

      // 解析并存储高亮列表
      final highlightsData =
          resourceData['article_mark']['highlights'] as List<dynamic>?;
      if (highlightsData != null) {
        await parseAndInsertHighlights(highlightsData, article.articleId);
      }

      return response.data;
    } catch (e) {
      print('获取文章信息失败: $e');
      if (e.toString().contains('status code of 404')) {
        print('警告: 请求的文章资源不存在或路径错误');
        // 返回null或空对象，而不是抛出异常
        return null;
      }
    }
  }

  /// 解析评论列表并逐个插入数据库
  Future<void> parseAndInsertComments(
    List<dynamic> commentsList,
    String articleId,
  ) async {
    try {
      for (var commentData in commentsList) {
        if (commentData is Map<String, dynamic>) {
          // 确保commentData包含articleId
          final commentMap = Map<String, dynamic>.from(commentData);
          commentMap['articleId'] = articleId;

          final comment = Comment.fromClMap(commentMap);
          await ArticleDbManager().insertCommentFromCl(comment.toLoMap());
        }
      }
    } catch (e) {
      print('解析或插入评论列表失败: $e');
    }
  }

  /// 解析高亮列表并逐个插入数据库
  Future<void> parseAndInsertHighlights(
    List<dynamic> highlightsList,
    String articleId,
  ) async {
    try {
      for (var highlightData in highlightsList) {
        if (highlightData is Map<String, dynamic>) {
          // 确保highlightData包含articleId
          final highlightMap = Map<String, dynamic>.from(highlightData);
          highlightMap['articleId'] = articleId;

          final highlight = Highlight.fromClMap(highlightMap);
          await ArticleDbManager().insertHighlightFromCl(highlight.toLoMap());
        }
      }
    } catch (e) {
      print('解析或插入高亮列表失败: $e');
    }
  }
}
