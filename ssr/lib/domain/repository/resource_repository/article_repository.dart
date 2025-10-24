import 'package:ssr/data/config/xhxs_config.dart';
import 'package:ssr/dio/utils/dio_utils.dart';
import 'package:ssr/domain/entity/article/article.dart';
import 'package:ssr/domain/entity/audio.dart';
import 'package:ssr/domain/repository/repository.dart';

class ArticleRepository extends Repository<ArticleEntity> {
  ArticleRepository() : super('article', 'article');

  @override
  Map<String, dynamic> toClMap(ArticleEntity entity) {
    return entity.toClMap();
  }

  @override
  ArticleEntity fromClMap(Map<String, dynamic> map) {
    return ArticleEntity.fromClMap(map);
  }

  @override
  ArticleEntity fromLoMap(Map<String, dynamic> map) {
    return ArticleEntity.fromLoMap(map);
  }

  @override
  Map<String, dynamic> toLoMap(ArticleEntity entity) {
    return entity.toLoMap();
  }

  Future<List<ArticleEntity>> getResourceById(String articleId) async {
    return await super.getResource('article', articleId);
  }
}
