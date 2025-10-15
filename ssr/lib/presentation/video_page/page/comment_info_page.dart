import 'package:flutter/material.dart';

class CommentInfoPage extends StatefulWidget {
  const CommentInfoPage({super.key});

  @override
  State<CommentInfoPage> createState() => _CommentInfoPageState();
}

class _CommentInfoPageState extends State<CommentInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('评论详情')),
      body: const Center(child: Text('评论详情')),
    );
  }
}
