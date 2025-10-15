import 'package:flutter/material.dart';

class RootCommentCard extends StatefulWidget {
  final String userName;
  final String department;
  final String comment;
  final int commentCount;
  final int likeCount;
  final int date;
  const RootCommentCard({
    super.key,
    required this.userName,
    required this.department,
    required this.comment,
    required this.commentCount,
    required this.likeCount,
    required this.date,
  });

  @override
  State<RootCommentCard> createState() => _RootCommentCardState();
}

class _RootCommentCardState extends State<RootCommentCard> {
  bool _imageLoaded = false;
  bool _imageLoading = true;
  bool commentExpand = false;

  int len() {
    return widget.comment.length;
  }

  void toggleCommentExpand() {
    setState(() {
      commentExpand = !commentExpand;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.network(
                  'https://rmtt.top/projectDoc/testAvatar2.jpg',
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    // 图像加载完成前显示加载指示器
                    if (loadingProgress == null) {
                      // 图像加载完成
                      if (!_imageLoaded) {
                        Future.microtask(() {
                          if (mounted) {
                            setState(() {
                              _imageLoaded = true;
                              _imageLoading = false;
                            });
                          }
                        });
                      }
                      return child;
                    } else {
                      // 图像加载中
                      return Container(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // 当网络图片加载失败时，显示默认头像
                    Future.microtask(() {
                      if (mounted) {
                        setState(() {
                          _imageLoading = false;
                        });
                      }
                    });
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.account_circle,
                        size: 40,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text('${widget.department}', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 8, left: 54),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        (len() <= 50 || commentExpand)
                            ? widget.comment
                            : widget.comment.substring(0, 50) + '...',
                        style: TextStyle(fontSize: 16),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),

                    Container(
                      child: Column(
                        children: [
                          Icon(Icons.thumb_up_off_alt),
                          Text('${widget.likeCount}'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (len() > 50)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: toggleCommentExpand,
                        child: Text(
                          commentExpand ? '收起' : '展开',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.lightBlue,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 36),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
