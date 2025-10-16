import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:ssr/presentation/sound_page/utils/audio_cache_manager_uilts.dart';

class CachedAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String artist;

  const CachedAudioPlayer({
    super.key,
    required this.audioUrl,
    this.title = '音频标题',
    this.artist = '未知作者',
  });

  @override
  State<CachedAudioPlayer> createState() => _CachedAudioPlayerState();
}

class _CachedAudioPlayerState extends State<CachedAudioPlayer> {
  late final AudioPlayer _player;
  double _downloadProgress = 0;
  bool _isCaching = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _buffered = Duration.zero;
  String? _cachePath;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    print('音频资源链接: ${widget.audioUrl}');
    _initialize();
  }

  Future<void> _initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await _loadAudio();
  }

  /// 检查缓存 → 若存在用本地文件播放，否则边播边缓存
  Future<void> _loadAudio() async {
    final cacheManager = AudioCacheManager(dio: Dio());
    await cacheManager.init();

    final cached = await cacheManager.getCachedFile(widget.audioUrl);

    if (cached != null && await cached.exists()) {
      print("📦 本地缓存命中，直接播放: ${cached.path}");
      _cachePath = cached.path;
      await _playFrom(Uri.file(cached.path));
    } else {
      print("🌐 缓存缺失，启动分段下载");
      _isCaching = true;
      cacheManager
          .download(
            widget.audioUrl,
            onProgress: (progress) {
              setState(() => _downloadProgress = progress);
            },
          )
          .then((_) async {
            _isCaching = false;
            final completed = await cacheManager.getCachedFile(widget.audioUrl);
            if (completed != null) {
              print("✅ 分段缓存完成，切换至本地播放");
              await _playFrom(Uri.file(completed.path));
            }
          });

      // 同时边播边下载
      await _playFrom(Uri.parse(widget.audioUrl));
    }
  }

  /// 播放音频
  Future<void> _playFrom(Uri uri) async {
    final prefs = await SharedPreferences.getInstance();
    final key = widget.audioUrl.split('/').last;
    final lastPos = prefs.getInt("pos_$key") ?? 0;

    await _player.setAudioSource(
      AudioSource.uri(
        uri,
        tag: MediaItem(
          id: widget.audioUrl,
          title: widget.title,
          artist: widget.artist,
          artUri: Uri.parse("https://picsum.photos/200"),
        ),
      ),
    );

    if (lastPos > 0) await _player.seek(Duration(milliseconds: lastPos));

    _player.positionStream.listen((pos) async {
      _position = pos;
      await prefs.setInt("pos_$key", pos.inMilliseconds);
      if (mounted) setState(() {});
    });

    _player.bufferedPositionStream.listen((b) {
      _buffered = b;
      if (mounted) setState(() {});
    });

    _player.durationStream.listen((d) {
      if (d != null && mounted) setState(() => _duration = d);
    });

    await _player.play();
  }

  /// 边播边缓存
  Future<void> _startStreamingAndCaching(
    String url,
    File target,
    File temp,
  ) async {
    setState(() => _isCaching = true);
    final dio = Dio();

    try {
      // 1️⃣ 先获取文件大小
      final head = await dio.head(url);
      final totalBytes =
          int.tryParse(
            head.headers.value(HttpHeaders.contentLengthHeader) ?? '0',
          ) ??
          0;

      if (totalBytes == 0) {
        print("⚠️ 无法获取音频大小，终止缓存");
        setState(() => _isCaching = false);
        return;
      }

      // 2️⃣ 设置缓存比例，例如 20%（或 10MB）
      const cachePercent = 0.2;
      final bytesToCache = (totalBytes * cachePercent).toInt();
      final rangeEnd = bytesToCache - 1;

      print(
        "🧩 开始缓存前 ${(cachePercent * 100).toInt()}% (${bytesToCache ~/ 1024} KB)",
      );

      // 3️⃣ 请求指定范围
      final response = await dio.get<ResponseBody>(
        url,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Range': 'bytes=0-$rangeEnd'},
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      final sink = temp.openWrite();
      int received = 0;
      final total = bytesToCache;

      response.data!.stream.listen(
        (chunk) {
          received += chunk.length;
          sink.add(chunk);
          if (mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
        onDone: () async {
          await sink.close();
          await temp.rename(target.path);
          print("✅ 已缓存 ${(_downloadProgress * 100).toStringAsFixed(1)}%");
          setState(() => _isCaching = false);
        },
        onError: (e) async {
          print("❌ 缓存失败: $e");
          await sink.close();
          setState(() => _isCaching = false);
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("❌ Dio缓存出错: $e");
      setState(() => _isCaching = false);
    }
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  // 首先修改 _buildProgress() 方法中的背景条和缓冲条高度
  Widget _buildProgress() {
    final total = _duration.inMilliseconds;
    final pos = _position.inMilliseconds;
    final buf = _buffered.inMilliseconds;

    double playedPercent = total > 0 ? pos / total : 0;
    double bufferPercent = total > 0 ? buf / total : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // 1️⃣ 背景条（未缓存）- 从6改为3
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // 2️⃣ 缓冲条（已缓存但未播放）- 从6改为3
            FractionallySizedBox(
              widthFactor: bufferPercent.clamp(0.0, 1.0),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // 3️⃣ 自定义滑块（显示播放进度）
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackShape: CustomTrackShape(), // 自定义轨道形状
                thumbShape: const CustomThumbShape(thumbRadius: 10), // 自定义滑块形状
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 0,
                ), // 禁止外层高亮圈
                activeTrackColor:
                    Colors.transparent, // 实际轨道绘制由 CustomTrackShape 控制
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.transparent,
              ),
              child: Slider(
                value: pos.toDouble().clamp(0, total.toDouble()),
                max: total > 0 ? total.toDouble() : 1,
                onChanged: (v) async =>
                    await _player.seek(Duration(milliseconds: v.toInt())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fmt(_position),
              style: const TextStyle(fontSize: 12, color: Color(0xffDCD2BD)),
            ),
            Text(
              _fmt(_duration),
              style: const TextStyle(fontSize: 12, color: Color(0xffDCD2BD)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return IconButton(
      iconSize: 52,
      icon: _player.playing
          ? const Icon(Icons.pause_circle_filled, color: Colors.blue)
          : const Icon(Icons.play_circle_fill, color: Colors.blue),
      onPressed: _isCaching
          ? null
          : () async {
              _player.playing ? await _player.pause() : await _player.play();
            },
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProgress(),
            const SizedBox(height: 8),
            _buildPlayButton(),
            if (_isCaching) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(value: _downloadProgress),
              Text(
                "正在缓存 ${(_downloadProgress * 100).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomThumbShape extends SliderComponentShape {
  final double thumbRadius;

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

    // 由于无法在paint方法中直接加载图片资源
    // 这里我们使用一个简单的圆形设计，保持与进度条颜色一致
    // 在实际项目中，你可能需要使用预加载的图片缓存或考虑其他方案

    // 绘制主圆形滑块
    final Paint paint = Paint()
      ..color =
          Color(0XFFF2B833) // 使用与进度条相同的黄色系
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, paint);

    // 绘制一个小一点的内部圆形，模拟图片的效果
    final Paint innerPaint = Paint()
      ..color =
          Color.fromARGB(255, 248, 233, 132) // 浅一点的颜色
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius * 0.7, innerPaint);

    // 保留发光效果
    if (activationAnimation.value > 0.0) {
      final Paint glowPaint = Paint()
        ..color = Color(0XFFF2B833).withOpacity(0.3 * activationAnimation.value)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, thumbRadius * 1.8, glowPaint);
    }
  }
}

// 然后修改 CustomTrackShape 类中的轨道高度
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 2.0; // 从4改为2，使轨道更细
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

    // 绘制背景轨道
    final Paint inactivePaint = Paint()..color = Colors.grey.withOpacity(0.15);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(4)),
      inactivePaint,
    );

    // 绘制渐变激活部分
    final Rect activeRect = Rect.fromLTRB(
      trackRect.left,
      trackRect.top,
      thumbCenter.dx,
      trackRect.bottom,
    );

    final Paint activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color.fromARGB(255, 248, 233, 132), Color(0XFFF2B833)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(activeRect);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(activeRect, Radius.circular(4)),
      activePaint,
    );
  }
}

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
