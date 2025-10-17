import 'package:flutter/material.dart';
import 'package:ssr/presentation/article_page/util/article_provider.dart';
import 'package:ssr/presentation/article_page/widget/article_content_widget.dart';
import 'package:ssr/presentation/article_page/widget/article_cover_widget.dart';
import 'package:ssr/presentation/article_page/widget/article_info_widget.dart';

class ArticlePage extends StatefulWidget {
  const ArticlePage({super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final ArticleInfoProvider articleInfoProvider = ArticleInfoProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: Stack(
          children: [
            // 可滚动内容
            SingleChildScrollView(
              child: Column(
                children: [
                  // 顶部空间，确保内容不会被AppBar遮挡
                  // SizedBox(height: kToolbarHeight),
                  ArticleCoverWidget(),
                  ArticleInfoWidget(),
                  ArticleContentPage(),
                ],
              ),
            ),

            // 固定在顶部的AppBar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0, // 去除阴影，让它看起来更像悬浮在内容上
              ),
            ),
          ],
        ),
      ),
    );
  }
}
