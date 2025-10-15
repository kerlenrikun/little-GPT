import 'package:flutter/material.dart';
import 'package:ssr/presentation/video_page/page/comment_page.dart';
import 'package:ssr/presentation/video_page/page/introduction_page.dart';
import 'package:ssr/presentation/video_page/page/transcript_page.dart';

class VideoContact extends StatefulWidget {
  const VideoContact({super.key});

  @override
  State<VideoContact> createState() => _VideoContactState();
}

class _VideoContactState extends State<VideoContact>
    with SingleTickerProviderStateMixin {
  final List<Tab> tabs = [Tab(text: '简介'), Tab(text: '评论'), Tab(text: '转写')];
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white, // 设置背景色
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: TabBar(tabs: tabs, controller: _tabController),
              ),
              Expanded(flex: 2, child: SizedBox(width: 0)),
            ],
          ),
          Divider(height: 0, color: Colors.grey),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                VideoIntroduction(),
                VideoComment(),
                VideoTranscript(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
