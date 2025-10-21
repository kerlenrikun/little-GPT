import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ssr/domain/provider/audio_url_provider.dart';

class PlaylistCard extends StatefulWidget {
  final String audioTitle;
  final String audioUrl;
  const PlaylistCard({
    super.key,
    required this.audioTitle,
    required this.audioUrl,
  });

  @override
  State<PlaylistCard> createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<PlaylistCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    // 创建动画控制器
    _controller = AnimationController(
      duration: const Duration(seconds: 8), // 旋转一圈的时间
      vsync: this,
    )..repeat(); // 设置为重复运行

    // 创建旋转动画 (使用弧度值)
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.141592653589793,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放资源
    super.dispose();
  }

  Widget adjustCard() {
    if (context.read<AudioUrlProvider>().audioId == widget.audioUrl) {
      return currentAudio();
    } else {
      return nonCurrentAudio();
    }
  }

  Widget currentAudio() {
    return Column(
      children: [
        SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: child,
                  );
                },
                child: SvgPicture.asset(
                  'assets/vectors/current_audio_in_playlist.svg', // 资源路径
                  width: 30, // 设置宽度
                  height: 30, // 设置高度
                  semanticsLabel: '我的图标', // 无障碍标签
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              // padding: EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Text(
                    widget.audioTitle,
                    style: TextStyle(
                      color: Color(0xffDCD2BD),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 2),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Divider(height: 0.5, color: Color(0xff815B0B)),
      ],
    );
  }

  Widget nonCurrentAudio() {
    return GestureDetector(
      onTap: () {
        // 确保widget.audioUrl不为空，并且正确传递给Provider
        if (widget.audioUrl.isNotEmpty) {
          // 更新音频ID而不是URL，确保组件正确刷新
          final audioUrlProvider = context.read<AudioUrlProvider>();
          audioUrlProvider.updateAudioId(widget.audioUrl);
          print('更新音频ID: ${widget.audioUrl}'); // 添加调试日志以确认ID被正确传递
        } else {
          print('警告: 音频URL为空'); // 添加错误处理
        }
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.audioTitle,
                      style: TextStyle(
                        color: Color(0xffDCD2BD),
                        fontSize: 16,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Divider(height: 0.5, color: Color(0xff815B0B)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 使用Consumer监听AudioUrlProvider的变化，确保点击后正确刷新
    return Consumer<AudioUrlProvider>(
      builder: (context, audioUrlProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: audioUrlProvider.audioId == widget.audioUrl
              ? currentAudio()
              : nonCurrentAudio(),
        );
      },
    );
  }
}
