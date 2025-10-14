import 'package:flutter/material.dart';

class VideoTranscript extends StatefulWidget {
  const VideoTranscript({super.key});

  @override
  State<VideoTranscript> createState() => _VideoTranscriptState();
}

class _VideoTranscriptState extends State<VideoTranscript> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Text('视频转写'));
  }
}
