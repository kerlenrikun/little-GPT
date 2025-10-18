import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ssr/model/router.dart';
import 'package:ssr/presentation/audio_page/audio_page.dart';
import 'package:ssr/provider/audio_url_provider/audio_url_provider.dart';

class AudioListCardWidget extends StatefulWidget {
  final String audioName;
  final String audioUrl;
  final int index;
  final int listCount;
  const AudioListCardWidget({
    super.key,
    required this.audioName,
    required this.audioUrl,
    required this.index,
    required this.listCount,
  });
  @override
  State<AudioListCardWidget> createState() => _AudioListCardWidgetState();
}

class _AudioListCardWidgetState extends State<AudioListCardWidget> {
  final fontColor = Colors.black87;
  final bgc = Colors.white70;

  // final fontColor = Colors.white70;
  // final bgc = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.to(
          SoundPage(
            title: widget.audioName,
            coverUrl: '',
            listName: '',
            listCount: widget.listCount,
          ).runtimeType,
        );
        // 确保widget.audioUrl不为空，并且正确传递给Provider
        if (widget.audioUrl.isNotEmpty) {
          context.read<AudioUrlProvider>().updateAudioUrl(widget.audioUrl);
          print('更新音频URL: ${widget.audioUrl}'); // 添加调试日志以确认URL被正确传递
        } else {
          print('警告: 音频URL为空'); // 添加错误处理
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      widget.index.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'hcSimple',
                        color: fontColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        letterSpacing: 0.0, // 减少字间距
                      ),
                      strutStyle: StrutStyle(
                        fontSize: 10, // 减少行间距
                        fontFamily: 'yzRH',
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      widget.audioName,
                      style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'yzRH',
                        color: fontColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        letterSpacing: 0.0, // 减少字间距
                      ),
                      strutStyle: StrutStyle(
                        fontSize: 10, // 减少行间距
                        fontFamily: 'yzRH',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 12, color: fontColor),
          ],
        ),
      ),
    );
  }
}
