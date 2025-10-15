import 'package:flutter/material.dart';

class ReplayCommentCard extends StatefulWidget {
  final String userName;
  final String department;
  final String comment;
  final int commentCount;
  final int likeCount;
  final int date;
  final int replyCommentId;
  const ReplayCommentCard({
    super.key,
    required this.userName,
    required this.department,
    required this.comment,
    required this.commentCount,
    required this.likeCount,
    required this.date,
    this.replyCommentId = -1,
  });

  @override
  State<ReplayCommentCard> createState() => _ReplayCommentCardState();
}

class _ReplayCommentCardState extends State<ReplayCommentCard> {
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

  String timeCalculate() {
    int time = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(widget.date))
        .inMinutes;
    if (time < 60) {
      return '${time}分钟前';
    } else if (time < 1440) {
      return '${time ~/ 60}小时前';
    } else {
      return '${time ~/ 1440}天前';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0xfff0f0f0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.network(
                  'https://rmtt.top/projectDoc/testAvatar2.jpg',
                  width: 30,
                  height: 30,
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
                        width: 30,
                        height: 30,
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
                      width: 30,
                      height: 30,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.account_circle,
                        size: 30,
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2),
                  Text('${widget.department}', style: TextStyle(fontSize: 10)),
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
                        style: TextStyle(fontSize: 14),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),

                    Container(
                      child: Column(
                        children: [
                          Icon(Icons.thumb_up_off_alt, size: 20),
                          Text(
                            '${widget.likeCount}',
                            style: TextStyle(fontSize: 12),
                          ),
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
                            fontSize: 12,
                            color: Colors.lightBlue,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 36),
                    ],
                  ),
                Container(
                  child: Row(
                    children: [
                      Text(
                        '${timeCalculate()}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(width: 8),
                      if (widget.commentCount > 0)
                        Text(
                          '${widget.commentCount}条回复',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
