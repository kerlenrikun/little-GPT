import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerWidget extends StatefulWidget {
  final AudioPlayer advancedPlayer;
  const AudioPlayerWidget({super.key, required this.advancedPlayer});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  final String audioUrl = 'https://rmtt.top/projectDoc/testMp3.mp3';
  bool _isPlaying = false;
  bool isLoop = false;
  bool _isBuffering = false;
  List<String> audioList = ['https://rmtt.top/projectDoc/testMp3.mp3'];
  List<Icon> iconList = [Icon(Icons.play_arrow), Icon(Icons.pause)];

  // 添加缓存进度状态
  double _bufferProgress = 0.0;
  Duration _bufferedDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    // 配置音频播放器以支持流式播放
    _configureAudioPlayer();

    // 监听音频时长变化
    widget.advancedPlayer.onDurationChanged.listen((Duration d) {
      if (mounted) {
        setState(() {
          _duration = d;
        });
      }
    });

    // 监听播放位置变化
    widget.advancedPlayer.onPositionChanged.listen((Duration p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });

    // 监听播放器状态变化
    widget.advancedPlayer.onPlayerStateChanged.listen((PlayerState s) {
      if (mounted) {
        setState(() {
          _isPlaying = s == PlayerState.playing;
          // _isBuffering = s == PlayerState.buffering;
        });
      }
    });

    // 监听缓冲更新（这对于流式播放特别重要）
    widget.advancedPlayer.onSeekComplete.listen((_) {
      // 当seek完成时可能需要的处理
    });

    // 设置音频源为URL，准备流式播放
    _prepareAudioSource();
  }

  // 配置音频播放器以支持流式播放
  void _configureAudioPlayer() {
    // 设置音频播放器参数以优化流式播放体验
    widget.advancedPlayer.setPlayerMode(PlayerMode.mediaPlayer); // 确保使用合适的播放器模式
    widget.advancedPlayer.setReleaseMode(ReleaseMode.stop); // 根据需要设置释放模式

    // 监听缓冲进度（通过检查可播放的位置）
    // 注意：audioplayers库可能不会直接提供缓冲进度事件，这里使用位置变化来估算

    // 如果需要，可以设置低延迟模式
    // widget.advancedPlayer.setLowLatencyMode(true);
  }

  // 准备音频源
  Future<void> _prepareAudioSource() async {
    try {
      // 设置URL源并准备播放，但不自动开始播放
      await widget.advancedPlayer.setSourceUrl(audioUrl);
      // 预加载音频以开始缓存过程
      // 这里不调用play，而是让用户点击播放按钮触发
    } catch (e) {
      print('准备音频源时出错: $e');
    }
  }

  Widget btnPlay() {
    return IconButton(
      icon: _isBuffering
          ? Icon(Icons.hourglass_empty, size: 28)
          : _isPlaying
          ? Icon(Icons.pause, size: 28)
          : Icon(Icons.play_arrow, size: 28),
      iconSize: 32,
      padding: EdgeInsets.all(8),
      onPressed: () async {
        try {
          // 获取当前播放状态，避免状态不匹配
          final PlayerState playerState = await widget.advancedPlayer.state;

          if (_isPlaying) {
            // 暂停逻辑
            await widget.advancedPlayer.pause();
            if (mounted) {
              setState(() {
                _isPlaying = false;
              });
            }
          } else {
            // 播放逻辑
            // 首先检查播放器状态，避免重复加载
            if (playerState == PlayerState.stopped ||
                playerState == PlayerState.completed) {
              // 如果是停止状态或播放完成，需要重新设置源
              setState(() {
                _isBuffering = true;
              });
              await widget.advancedPlayer.setSource(UrlSource(audioUrl));
              await widget.advancedPlayer.play(UrlSource(audioUrl));
            } else if (playerState == PlayerState.paused) {
              // 如果是暂停状态，直接恢复播放
              await widget.advancedPlayer.play(UrlSource(audioUrl));
            }

            if (mounted) {
              setState(() {
                _isPlaying = true;
                _isBuffering = false;
              });
            }
          }
        } catch (e) {
          print('播放控制出错: $e');
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _isBuffering = false;
            });
          }
        }
      },
    );
  }

  // 显示播放进度条，包括已播放和已缓冲部分
  Widget _buildProgressIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SliderTheme(
          data: SliderThemeData(
            // 自定义整体主题
            trackHeight: 8.0, // 轨道高度
            thumbShape: CustomThumbShape(), // 自定义滑块形状
            trackShape: CustomTrackShape(), // 自定义轨道形状
            overlayShape: RoundSliderOverlayShape(overlayRadius: 20), // 点击时的覆盖层
            tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4), // 刻度标记
            inactiveTrackColor: Colors.grey.withOpacity(0.3), // 未激活部分轨道颜色
            activeTrackColor: Colors.blue, // 激活部分轨道颜色
            thumbColor: Colors.blue, // 滑块颜色
            overlayColor: Colors.blue.withOpacity(0.2), // 覆盖层颜色
            disabledActiveTrackColor: Colors.grey,
            disabledInactiveTrackColor: Colors.grey.withOpacity(0.3),
            disabledThumbColor: Colors.grey,
          ),
          child: Slider(
            value: _position.inSeconds.toDouble(),
            min: 0.0,
            max: _duration.inSeconds.toDouble(),
            onChanged: (double value) async {
              await widget.advancedPlayer.seek(
                Duration(seconds: value.toInt()),
              );
            },
            onChangeStart: (double value) {
              // 开始拖动时的回调
              print('开始拖动到: $value');
            },
            onChangeEnd: (double value) {
              // 结束拖动时的回调
              print('结束拖动到: $value');
            },
            // 你也可以在这里直接设置颜色，但SliderTheme优先级更高
            // activeColor: Colors.blue,
            // inactiveColor: Colors.grey,
          ),
        ),
        SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_formatDuration(_position)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            Text(
              '${_formatDuration(_duration)}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  // 格式化时间显示
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
  }

  Widget loadAsset() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProgressIndicator(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [btnPlay()],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 添加Material组件作为根元素，确保Slider等Material组件正常工作
    return Material(
      type: MaterialType.transparency, // 使用透明背景，避免影响现有UI
      child: Container(child: loadAsset()),
    );
  }

  @override
  void dispose() {
    // 确保在组件销毁时释放资源
    widget.advancedPlayer.stop();
    super.dispose();
  }
}

// 自定义滑块形状类
class CustomThumbShape extends SliderComponentShape {
  final double thumbRadius; // 滑块半径

  const CustomThumbShape({this.thumbRadius = 12.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // 绘制滑块背景圆
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, paint);

    // 在滑块上绘制自定义图标（比如播放图标）
    final icon = Icons.play_arrow_outlined;
    final iconSize = thumbRadius * 1.5;
    final iconPainter = IconPainter(
      icon: icon,
      color: Colors.white,
      size: iconSize,
    );

    final Offset iconOffset = Offset(
      center.dx - iconSize / 2,
      center.dy - iconSize / 2,
    );

    iconPainter.paint(canvas, iconOffset);

    // 可以添加额外的装饰，比如发光效果
    if (activationAnimation.value > 0.0) {
      final Paint glowPaint = Paint()
        ..color = Colors.blue.withOpacity(0.4 * activationAnimation.value)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, thumbRadius * 1.5, glowPaint);
    }
  }
}

// 自定义轨道形状类 - 还原为单条模式
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    // 设置正常的轨道高度
    final double trackHeight = 2.0;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    double additionalActiveTrackHeight = 2,
    required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    required RenderBox parentBox,
    Offset? secondaryOffset,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required Offset thumbCenter,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // 单条轨道实现 - 首先绘制未激活部分
    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(trackRect.height / 2)),
      inactivePaint,
    );

    // 绘制激活部分（渐变效果）
    final LinearGradient gradient = LinearGradient(
      colors: [Colors.amberAccent.shade200, Colors.amberAccent.shade700],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    // 计算激活部分的矩形
    final Rect activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    // 绘制激活部分
    final Paint activePaint = Paint()
      ..shader = gradient.createShader(activeRect);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(
        activeRect,
        Radius.circular(activeRect.height / 2),
      ),
      activePaint,
    );

    // 注意：不再需要dart:math包，因为不再使用Random类
  }
}

// 图标绘制辅助类
class IconPainter {
  final IconData icon;
  final Color color;
  final double size;

  IconPainter({required this.icon, required this.color, required this.size});

  void paint(Canvas canvas, Offset offset) {
    final textSpan = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        color: color,
        fontSize: size,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();

    textPainter.paint(canvas, offset);
  }
}

// // 自定义轨道形状类 - 录音条样式
// class CustomTrackShape extends RoundedRectSliderTrackShape {
//   @override
//   Rect getPreferredRect({
//     required RenderBox parentBox,
//     Offset offset = Offset.zero,
//     required SliderThemeData sliderTheme,
//     bool isEnabled = false,
//     bool isDiscrete = false,
//   }) {
//     // 设置轨道高度，录音条样式需要稍高一些
//     final double trackHeight = 20.0;
//     final double trackLeft = offset.dx;
//     final double trackTop =
//         offset.dy + (parentBox.size.height - trackHeight) / 2;
//     final double trackWidth = parentBox.size.width;
//     return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
//   }

//   @override
//   void paint(
//     PaintingContext context,
//     Offset offset, {
//     double additionalActiveTrackHeight = 2,
//     required Animation<double> enableAnimation,
//     bool isDiscrete = false,
//     bool isEnabled = false,
//     required RenderBox parentBox,
//     Offset? secondaryOffset,
//     required SliderThemeData sliderTheme,
//     required TextDirection textDirection,
//     required Offset thumbCenter,
//   }) {
//     final Rect trackRect = getPreferredRect(
//       parentBox: parentBox,
//       offset: offset,
//       sliderTheme: sliderTheme,
//       isEnabled: isEnabled,
//       isDiscrete: isDiscrete,
//     );

//     // 绘制不规则录音条效果
//     final Canvas canvas = context.canvas;
//     final int barCount = 50; // 录音条数量
//     final double barSpacing = trackRect.width / (barCount * 2); // 条间距
//     final double barWidth = trackRect.width / (barCount * 2.5); // 条宽度
//     final double maxBarHeight = trackRect.height * 2.3; // 最大条高度

//     // 创建随机数生成器，但使用固定种子以保持一致的波形
//     final Random random = Random(320);

//     // 绘制未激活的录音条
//     for (int i = 0; i < barCount; i++) {
//       final double barX = trackRect.left + (i * 2 + 1) * barSpacing;
//       final double barHeight =
//           (random.nextDouble() * 0.6 + 0.4) * maxBarHeight; // 随机高度，范围40%-100%
//       final double barY = trackRect.center.dy - barHeight / 2;

//       final Rect barRect = Rect.fromLTWH(barX, barY, barWidth, barHeight);

//       final Paint barPaint = Paint()
//         ..color = sliderTheme.inactiveTrackColor!.withOpacity(0.5);

//       canvas.drawRRect(
//         RRect.fromRectAndRadius(barRect, Radius.circular(barWidth / 2)),
//         barPaint,
//       );
//     }

//     // 绘制激活的录音条
//     final LinearGradient gradient = LinearGradient(
//       colors: [Colors.amberAccent.shade200, Colors.amberAccent.shade700],
//       begin: Alignment.bottomCenter,
//       end: Alignment.topCenter,
//     );

//     // 计算在滑块位置之前的录音条数量
//     final int activeBarCount =
//         (barCount * (thumbCenter.dx - trackRect.left) / trackRect.width)
//             .round();

//     for (int i = 0; i < activeBarCount; i++) {
//       final double barX = trackRect.left + (i * 2 + 1) * barSpacing;
//       final double barHeight = (random.nextDouble() * 0.6 + 0.4) * maxBarHeight;
//       final double barY = trackRect.center.dy - barHeight / 2;

//       final Rect barRect = Rect.fromLTWH(barX, barY, barWidth, barHeight);

//       final Paint barPaint = Paint()..shader = gradient.createShader(barRect);

//       canvas.drawRRect(
//         RRect.fromRectAndRadius(barRect, Radius.circular(barWidth / 2)),
//         barPaint,
//       );
//     }

//     // 注意：需要导入dart:math包来使用Random类
//     // import 'dart:math';
//   }
// }
