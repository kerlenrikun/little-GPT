import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:ssr/presentation/sound_page/widget/audio_players_widget.dart';
import 'package:ssr/presentation/sound_page/widget/cover_widget.dart';
import 'package:ssr/presentation/sound_page/widget/title_widget.dart';

class SoundPage extends StatefulWidget {
  final String title;
  final String soundFileUrl;
  final String coverUrl;
  final String listName;
  final int listCount;
  const SoundPage({
    super.key,
    required this.title,
    required this.soundFileUrl,
    required this.coverUrl,
    required this.listName,
    required this.listCount,
  });

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  AudioPlayer advancedPlayer = AudioPlayer();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 1, 29, 68),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '听音频',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.none, // 明确设置为无装饰线
                        decorationStyle: null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                CoverWidget(coverUrl: widget.coverUrl),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),

                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24),

                        child: Column(
                          children: [
                            TitleWidget(
                              title: widget.title,
                              listName: widget.listName,
                            ),
                            SizedBox(height: 8),
                            ListTitleView(
                              listName: widget.listName,
                              listCount: widget.listCount,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Divider(height: 16, color: Color(0xff815B0B)),
                      SizedBox(height: 16),

                      // AudioPlayerWidget(advancedPlayer: advancedPlayer),
                    ],
                  ),
                ),
              ],
            ),
          ),

          CachedAudioPlayer(
            audioUrl: widget.soundFileUrl,
            title: widget.title,
            artist: widget.listName,
          ),
        ],
      ),
    );
  }
}
