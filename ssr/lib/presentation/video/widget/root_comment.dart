import 'package:flutter/material.dart';
import 'package:ssr/presentation/video/widget/reply_comment.dart';

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
        color: Colors.white,
      ),
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
                SizedBox(height: 8),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReplayCommentCard(
                        userName: '一个名字，应该是实名的',
                        department: '项目-部门-岗位',
                        comment:
                            '这是一条评论，可以是很长很长的感悟，或者只是一条很普通的哈哈，但是因为要测试评论长度的压力测试，所以要写很多很多很多的字，来看看会不会溢出，如果溢出就修复，当然没有溢出最好，不过现在貌似还不够长，所以我得再多写一点，我觉得一个人要是很有感悟的话，写的评论肯定会很长，就像看一篇文章一样，为了模拟长的文段，我只能写很多的文字，为了防止团队伙伴写很长的评论导致数据溢出，那我是不是应该还得限制一下评论的长度，不然要是评论无限长的话大家的评论都被刷下去了，这肯定是不行的，我觉得字数差不多了，就这样吧',
                        commentCount: 0,
                        likeCount: 124,
                        date: 1760499111000,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '查看剩余 ${widget.commentCount - 1} 条评论 》',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.lightBlue,
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
          ),
        ],
      ),
    );
  }
}
