import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:ssr/presentation/audio/utils/audio_cache_manager_uilts.dart';
import 'package:ssr/domain/provider/audio_url_provider.dart';

// 全局AudioPlayer单例 - 使用公开命名以便其他文件访问
AudioPlayer? _globalAudioPlayer;

// // 全局AudioPlayer使用方法
// // 1. 首先导入audio_players_widget.dart文件
// import 'package:ssr/presentation/sound_page/widget/audio_players_widget.dart';

// // 2. 获取全局播放器实例
// AudioPlayer player = getGlobalAudioPlayer();

// // 3. 然后你就可以控制播放器了
// // 暂停播放
// await player.pause();

// // 继续播放
// await player.play();

// // 刷新音频源
// await player.setAudioSource(/* 新的音频源 */);

// // 跳转到指定位置
// await player.seek(Duration(seconds: 30));

// // 获取播放状态
// bool isPlaying = player.playing;
// Duration position = await player.position;

// // - 3.
// // 资源管理 ：
// // - 在应用退出时，应该调用 disposeGlobalAudioPlayer() 来释放资源
// // - 这通常放在应用的主入口文件(main.dart)的dispose逻辑中

// // - 4.
// // 注意事项 ：
// // - 由于这是全局共享的实例，任何文件中的操作都会影响到所有使用该实例的组件
// // - 多个组件同时控制播放器时需要注意状态同步问题
// // - 建议添加状态监听，以便在一个组件中操作播放器时，其他组件能够感知到状态变化

/// 获取全局共享的AudioPlayer实例
/// 其他文件可以导入此文件并使用此函数获取同一个播放器实例
AudioPlayer getGlobalAudioPlayer() {
  if (_globalAudioPlayer == null) {
    print('🎵 创建全局AudioPlayer单例实例');
    _globalAudioPlayer = AudioPlayer();
  }
  return _globalAudioPlayer!;
}

/// 释放全局AudioPlayer实例资源
/// 应该在应用退出前调用此方法
void disposeGlobalAudioPlayer() {
  if (_globalAudioPlayer != null) {
    print('🔇 释放全局AudioPlayer实例资源');
    _globalAudioPlayer!.dispose();
    _globalAudioPlayer = null;
  }
}

// 假设的修改，确保CachedAudioPlayer能响应URL变化
class CachedAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String artist;

  const CachedAudioPlayer({
    Key? key,
    required this.audioUrl,
    required this.title,
    required this.artist,
  }) : super(key: key);

  @override
  _CachedAudioPlayerState createState() => _CachedAudioPlayerState();
}

class _CachedAudioPlayerState extends State<CachedAudioPlayer> {
  // 完善didUpdateWidget方法，确保URL变化时正确切换音频
  @override
  void didUpdateWidget(covariant CachedAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果音频URL发生变化，重新加载音频
    if (oldWidget.audioUrl != widget.audioUrl && widget.audioUrl.isNotEmpty) {
      print('检测到音频URL变化: ${oldWidget.audioUrl} -> ${widget.audioUrl}');
      _loadAndPlayNewAudio(widget.audioUrl);
    }
  }

  // 实现加载并播放新音频的方法
  Future<void> _loadAndPlayNewAudio(String url) async {
    try {
      // 停止当前播放的音频
      if (_player.playing) {
        await _player.stop();
      }

      // 清除旧的播放进度记录
      final prefs = await SharedPreferences.getInstance();
      final oldKey = _currentAudioUrl?.split('/').last ?? '';
      if (oldKey.isNotEmpty) {
        await prefs.remove("pos_$oldKey");
        print("🧹 清除旧音频播放进度记录: pos_$oldKey");
      }

      // 更新当前音频URL
      _currentAudioUrl = url;

      // 播放新音频前清零播放进度
      setState(() {
        _position = Duration.zero;
        _duration = Duration.zero;
      });

      // 重新加载音频
      print('准备加载新音频: $url');
      await _loadAudio(url);
    } catch (e) {
      print('加载新音频失败: $e');
    }
  }

  // 删除原有的空方法
  // void _loadNewAudio() {
  //   // 实现加载新音频的逻辑
  // }

  // 使用全局AudioPlayer单例
  late final AudioPlayer _player;
  double _downloadProgress = 0;
  bool _isCaching = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  Duration _buffered = Duration.zero;
  String? _cachePath;
  String? _currentAudioUrl;

  @override
  void initState() {
    super.initState();
    // 获取全局AudioPlayer单例实例
    _player = getGlobalAudioPlayer();

    // 优先使用组件传递的URL，如果为空则使用Provider中的URL
    _updateCurrentAudioUrl();
    print('初始音频资源链接: $_currentAudioUrl');
    _initialize();
  }

  @override
  void dispose() {
    // 不在这里释放_player，因为它是全局单例
    // 如果需要在应用退出时释放，应该在应用的主入口或专用的资源管理类中处理
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 优先使用组件传递的URL，如果为空则使用Provider中的URL并监听变化
    final newAudioUrl = widget.audioUrl.isNotEmpty
        ? widget.audioUrl
        : context.watch<AudioUrlProvider>().audioUrl;

    if (newAudioUrl != _currentAudioUrl && newAudioUrl.isNotEmpty) {
      print('检测到音频URL变化: $_currentAudioUrl -> $newAudioUrl');
      _currentAudioUrl = newAudioUrl;
      _loadAndPlayNewAudio(newAudioUrl);
    }
  }

  Future<void> _initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    if (_currentAudioUrl?.isNotEmpty == true) {
      _loadAudio(_currentAudioUrl!);
    }
  }

  //判断使用音频资源的路径，优先使用传递的Url，若无则使用Provider的
  void _updateCurrentAudioUrl() {
    _currentAudioUrl = widget.audioUrl.isNotEmpty || widget.audioUrl != ''
        ? widget.audioUrl
        : context.read<AudioUrlProvider>().audioUrl;
  }

  /// 检查缓存 → 若存在用本地文件播放，否则边播边缓存
  /// 加载并播放音频（带分段缓存 + 断点续传 + 自动清理）
  Future<void> _loadAudio(String url) async {
    final dio = Dio();
    final cacheManager = AudioCacheManager();

    // 初始化缓存系统
    await cacheManager.init();

    // 每次加载时执行一次清理任务（清理两天前未访问缓存）
    await AudioCacheManager.scheduledCleanup();

    final cachedFile = await cacheManager.getCachedFile(url);

    // ① 若命中缓存文件 → 直接本地播放
    if (cachedFile != null && await cachedFile.exists()) {
      print("📦 本地缓存命中，直接播放: ${cachedFile.path}");
      _cachePath = cachedFile.path;

      await cacheManager.updateAccessTime(url);
      await _playFrom(Uri.file(cachedFile.path), url);
      return;
    }

    // ② 若缓存缺失 → 启动动态边播边缓存
    print("🌐 缓存缺失，启动动态缓存任务");
    _isCaching = true;

    // 获取缓存路径
    final temp = await cacheManager.createTempFile(url);
    final target = await cacheManager.createTargetFile(url);

    // 开始边播边缓存任务
    unawaited(_startStreamingAndCaching(url, target, temp));

    // 同时播放网络流（边播边缓存）
    await _playFrom(Uri.parse(url), url);
  }

  /// 播放音频
  Future<void> _playFrom(Uri uri, String url) async {
    final prefs = await SharedPreferences.getInstance();
    final key = url.split('/').last;

    // ❌ 删除或注释掉旧进度恢复逻辑
    // final lastPos = prefs.getInt("pos_$key") ?? 0;

    // ✅ 强制新音频从头开始
    final lastPos = 0;

    await _player.setAudioSource(
      AudioSource.uri(
        uri,
        tag: MediaItem(
          id: url,
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
  /// 动态分段续缓存 + 自动断点续传
  Future<void> _startStreamingAndCaching(
    String url,
    File target,
    File temp,
  ) async {
    if (!mounted) return;
    setState(() => _isCaching = true);
    final dio = Dio();

    try {
      // 1️⃣ 获取文件大小
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

      // 2️⃣ 检查已缓存进度（断点续传）
      int downloaded = 0;
      if (await temp.exists()) {
        downloaded = await temp.length();
        print("🔁 检测到已缓存部分数据: $downloaded 字节");
      }

      // 若已缓存完毕直接转为目标文件
      if (downloaded >= totalBytes) {
        try {
          if (await target.exists()) {
            await target.delete();
          }
          await temp.rename(target.path);
          print("✅ 已完全缓存，无需继续下载");
        } catch (e) {
          print("❌ 文件重命名失败: $e");
        } finally {
          if (mounted) setState(() => _isCaching = false);
        }
        return;
      }

      // 3️⃣ 设置 Range 请求，断点续传
      final response = await dio.get<ResponseBody>(
        url,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Range': 'bytes=$downloaded-${totalBytes - 1}'},
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      final sink = temp.openWrite(mode: FileMode.append);
      int received = downloaded;

      response.data!.stream.listen(
        (chunk) {
          received += chunk.length;
          sink.add(chunk);

          final progress = received / totalBytes;
          if (mounted) setState(() => _downloadProgress = progress);
        },
        onDone: () async {
          await sink.close();

          try {
            // 下载完成 → 覆盖目标文件
            if (await target.exists()) {
              await target.delete();
            }
            await temp.rename(target.path);
            print("✅ 分段缓存完成，总计 ${(received / 1024).toStringAsFixed(1)} KB");

            // 更新最后访问时间
            await AudioCacheManager().updateAccessTime(url);

            if (mounted) setState(() => _isCaching = false);

            // 下载完毕后切换播放源到本地缓存
            if (mounted && _player.playing) {
              // 记录当前播放进度
              final currentPosition = _player.position;
              print("🔄 缓存完成后切换到本地播放，当前进度: $currentPosition");

              // 设置本地音频源
              await _player.setAudioSource(
                AudioSource.uri(
                  Uri.file(target.path),
                  tag: MediaItem(
                    id: url,
                    title: widget.title,
                    artist: widget.artist,
                    artUri: Uri.parse("https://picsum.photos/200"),
                  ),
                ),
              );

              // 恢复到之前的播放进度
              await _player.seek(currentPosition);
              print("✅ 已恢复播放进度到: $currentPosition");
            }
          } catch (e) {
            print("❌ 缓存处理完成阶段出现错误: $e");
            if (mounted) setState(() => _isCaching = false);
          }
        },
        onError: (e) async {
          print("❌ 缓存失败: $e");
          await sink.close();
          if (mounted) setState(() => _isCaching = false);
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("❌ Dio缓存出错: $e");
      if (mounted) setState(() => _isCaching = false);
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
                thumbShape: const CustomThumbShape(thumbRadius: 8), // 自定义滑块形状
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
          ? SvgPicture.asset(
              'assets/vectors/audio_pause.svg',
              colorFilter: ColorFilter.mode(Color(0xffDCD2BD), BlendMode.srcIn),
              width: 65,
              height: 65,
            )
          : SvgPicture.asset(
              'assets/vectors/audio_play.svg',
              colorFilter: ColorFilter.mode(Color(0xffDCD2BD), BlendMode.srcIn),
              width: 65,
              height: 65,
            ),
      // 🔹 删除了 `_isCaching ? null :` 限制，让播放键始终可用
      onPressed: () async {
        _player.playing ? await _player.pause() : await _player.play();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProgress(),
            const SizedBox(height: 8),
            _buildPlayButton(),
            // if (_isCaching) ...[
            //   const SizedBox(height: 10),
            //   LinearProgressIndicator(value: _downloadProgress),
            //   Text(
            //     "正在缓存 ${(_downloadProgress * 100).toStringAsFixed(1)}%",
            //     style: const TextStyle(fontSize: 12, color: Colors.grey),
            //   ),
            // ],
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
