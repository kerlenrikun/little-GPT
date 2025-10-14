import 'package:flutter/material.dart';
import 'package:ssr/presentation/video_page/widget/comment_sort_widget.dart';
import 'package:ssr/presentation/video_page/widget/root_comment.dart';

class VideoComment extends StatefulWidget {
  const VideoComment({super.key});

  @override
  State<VideoComment> createState() => _VideoCommentState();
}

class _VideoCommentState extends State<VideoComment> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: [SortWidget(), CommentList()]));
  }
}

class CommentList extends StatefulWidget {
  const CommentList({super.key});

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: RootCommentCard(
        userName: '一个名字，应该是实名的',
        department: '项目-部门-岗位',
        comment:
            '这是一条评论，可以是很长很长的感悟，或者只是一条很普通的哈哈，但是因为要测试评论长度的压力测试，所以要写很多很多很多的字，来看看会不会溢出，如果溢出就修复，当然没有溢出最好，不过现在貌似还不够长，所以我得再多写一点，我觉得一个人要是很有感悟的话，写的评论肯定会很长，就像看一篇文章一样，为了模拟长的文段，我只能写很多的文字，为了防止团队伙伴写很长的评论导致数据溢出，那我是不是应该还得限制一下评论的长度，不然要是评论无限长的话大家的评论都被刷下去了，这肯定是不行的，我觉得字数差不多了，就这样吧',
        commentCount: 0,
        likeCount: 124,
        date: 1694560000,
      ),
    );
  }
}
