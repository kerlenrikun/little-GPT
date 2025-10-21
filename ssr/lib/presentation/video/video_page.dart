import 'package:flutter/material.dart';
import 'package:ssr/presentation/video/widget/tabbar_widget.dart';
import 'package:ssr/presentation/video/widget/video_view.dart';

class PlayVideo extends StatefulWidget {
  const PlayVideo({super.key});

  @override
  State<PlayVideo> createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // AppBar(title: Text('播放视频')),
          Container(
            color: Colors.black,
            child: VideoView(
              videoUrl: 'https://rmtt.top/projectDoc/testMp4XX.mp4',
              coverUrl: 'https://rmtt.top/projectDoc/testPngXX.png',
            ),
          ),
          Expanded(child: Container(child: VideoContact())),
        ],
      ),
    );
  }
}
