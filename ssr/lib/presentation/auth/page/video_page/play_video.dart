import 'package:flutter/material.dart';
import 'package:ssr/presentation/auth/page/video_page/video_view.dart';

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
        children: [
          // AppBar(title: Text('播放视频')),
          Container(
            color: Colors.black,
            child: VideoView(
              videoUrl:
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
              coverUrl:
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.jpg',
            ),
          ),
        ],
      ),
    );
  }
}
