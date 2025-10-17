import 'package:flutter/material.dart';
import 'package:ssr/presentation/audio_select_page/widget/art_word_widget.dart';
import 'package:ssr/presentation/audio_select_page/widget/audio_list_widget.dart';

class AudioSelectPage extends StatefulWidget {
  const AudioSelectPage({super.key});

  @override
  State<AudioSelectPage> createState() => _AudioSelectPageState();
}

class _AudioSelectPageState extends State<AudioSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
          ),
          ArtWordWidget(),
          SizedBox(height: 12),
          AudioListWidget(),
        ],
      ),
    );
  }
}
