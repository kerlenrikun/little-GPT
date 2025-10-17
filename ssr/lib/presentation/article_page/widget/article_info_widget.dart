import 'package:flutter/material.dart';
import 'package:ssr/presentation/article_page/article_provider.dart';

class ArticleInfoWidget extends StatefulWidget {
  const ArticleInfoWidget({super.key});

  @override
  State<ArticleInfoWidget> createState() => _ArticleInfoWidgetState();
}

class _ArticleInfoWidgetState extends State<ArticleInfoWidget> {
  final ArticleInfoProvider articleInfoProvider = ArticleInfoProvider();
  late String title;
  late String postDate;
  late String auther;

  @override
  void initState() {
    super.initState();
    // 初始赋值
    title = articleInfoProvider.articleTitle;
    postDate = articleInfoProvider.articlePostDate;
    auther = articleInfoProvider.articleAuther;
    // 添加监听器，当数据变化时更新UI
    articleInfoProvider.addListener(_updateTitle);
  }

  void _updateTitle() {
    setState(() {
      title = articleInfoProvider.articleTitle;
      postDate = articleInfoProvider.articlePostDate;
      auther = articleInfoProvider.articleAuther;
    });
  }

  @override
  void dispose() {
    // 移除监听器，避免内存泄漏
    articleInfoProvider.removeListener(_updateTitle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 12, right: screenWidth * 0.2),
            child: Text(
              title,
              textAlign: TextAlign.left,
              overflow: TextOverflow.visible,
              maxLines: null,
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 12, right: screenWidth * 0.2),
                  child: Text(
                    auther,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 12),
                child: Text(
                  postDate,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Divider(height: 1, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
