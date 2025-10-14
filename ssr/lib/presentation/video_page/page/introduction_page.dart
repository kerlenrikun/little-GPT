import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:ssr/presentation/video_page/widget/list_widget.dart';
import 'package:ssr/presentation/video_page/widget/title_widget.dart';

class VideoIntroduction extends StatefulWidget {
  const VideoIntroduction({super.key});

  @override
  State<VideoIntroduction> createState() => _VideoIntroductionState();
}

class _VideoIntroductionState extends State<VideoIntroduction> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [VideoTitle()],
          ),
        ),
        SizedBox(height: 8),
        Divider(height: 1),
        // SizedBox(height: 8),
        VideoListWidget(),
      ],
    );
  }
}
