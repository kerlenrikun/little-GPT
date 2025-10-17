import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ssr/presentation/article_page/util/article_provider.dart';

class ArticleCoverWidget extends StatefulWidget {
  const ArticleCoverWidget({super.key});

  @override
  State<ArticleCoverWidget> createState() => _ArticleCoverWidgetState();
}

class _ArticleCoverWidgetState extends State<ArticleCoverWidget> {
  final ArticleInfoProvider articleInfoProvider = ArticleInfoProvider();
  late String coverUrl;

  @override
  void initState() {
    super.initState();
    // 初始赋值
    coverUrl = articleInfoProvider.articleCoverUrl;
    // 添加监听器，当数据变化时更新UI
    articleInfoProvider.addListener(_updateCoverUrl);
  }

  void _updateCoverUrl() {
    setState(() {
      coverUrl = articleInfoProvider.articleCoverUrl;
    });
  }

  @override
  void dispose() {
    // 移除监听器，避免内存泄漏
    articleInfoProvider.removeListener(_updateCoverUrl);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height * 0.3;
    return Container(
      width: screenWidth,
      height: screenHeight,
      color: Colors.grey[400],
      child: CachedNetworkImage(
        imageUrl: coverUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }
}
