import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String videoUrl;
  final String coverUrl;
  final bool autoPlay;
  final bool looping;
  final double aspectRatio;

  const VideoView({
    super.key,
    required this.videoUrl,
    this.coverUrl = '',
    this.autoPlay = true,
    this.looping = true,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    try {
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: widget.aspectRatio,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
      );
      setState(() {
        _isReady = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "视频加载失败：$e";
        print("Error initializing video player: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = screenWidth / widget.aspectRatio;

    return Stack(
      children: [
        Column(
          children: [
            SafeArea(top: false, child: SizedBox(height: 0)),
            Container(
              width: screenWidth,
              height: screenHeight,
              child: _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _isReady && _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ],
        ),
        AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
      ],
    );
  }
}
