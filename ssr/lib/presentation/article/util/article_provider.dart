import 'package:flutter/foundation.dart';
import 'package:ssr/presentation/article/util/article_colud_sync.dart';

class ArticleInfoProvider extends ChangeNotifier {
  Map<String, dynamic> articleList = {};

  void getArticleInfo(String articleId) async {
    this.articleList = await ArticleColudSync().getArticleInfoById(articleId);
    print("获取的文章信息：$articleList");

    // 解析resource数据并添加到articleList中
    if (articleList.containsKey('resource')) {
      final resource = articleList['resource'];
      if (resource is Map<String, dynamic>) {
        // 添加文章内容
        if (resource.containsKey('article_content')) {
          articleList['articleContent'] = resource['article_content'];
        }

        // 添加文章ID（如果不存在）
        if (!articleList.containsKey('articleId') &&
            resource.containsKey('article_id')) {
          articleList['articleId'] = resource['article_id'];
        }

        // 添加文章哈希值
        if (resource.containsKey('article_hash')) {
          articleList['articleHash'] = resource['article_hash'];
        }

        // 添加文章标记（评论和高亮）
        if (resource.containsKey('article_mark')) {
          final articleMark = resource['article_mark'];
          if (articleMark is Map<String, dynamic>) {
            // 添加评论
            if (articleMark.containsKey('comments')) {
              articleList['comments'] = articleMark['comments'];
            }

            // 添加高亮
            if (articleMark.containsKey('highlights')) {
              articleList['highlights'] = articleMark['highlights'];
            }
          }
        }
      }
    }

    // notifyListeners();
  }

  String get articleId => articleList['articleId'];
  String get articleCoverUrl => articleList['coverUrl'];
  String get articleTitle => articleList['title'];
  String get articlePublishTime => articleList['publishTime'];
  String get articleauthor => articleList['author'];
  String get articleUrl => articleList['articleUrl'];
  String get articleContent => articleList['articleContent'] ?? '';
  String get articleHash => articleList['articleHash'] ?? '';
  List get comments => articleList['comments'] ?? [];
  List get highlights => articleList['highlights'] ?? [];

  void updateArticleInfo(String info) {
    articleList['title'] = info;
    notifyListeners();
  }

  void updateComments(List comments) {
    articleList['comments'] = comments;
    notifyListeners();
  }

  void updateHighlights(List highlights) {
    articleList['highlights'] = highlights;
    notifyListeners();
  }
}
