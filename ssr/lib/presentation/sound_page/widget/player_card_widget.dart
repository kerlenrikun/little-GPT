import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:ssr/presentation/sound_page/widget/audio_player_widget.dart';

class PlayerCardWidget extends StatefulWidget {
  final AudioPlayer advancedPlayer;
  final String title;
  const PlayerCardWidget({
    super.key,
    required this.advancedPlayer,
    required this.title,
  });

  @override
  State<PlayerCardWidget> createState() => _PlayerCardWidgetState();
}

class _PlayerCardWidgetState extends State<PlayerCardWidget> {
  Widget AudioTitle() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              // 处理点击事件
            },
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 10),
          Container(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              // 处理点击事件
            },
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.85;
    final screenHeight = MediaQuery.of(context).size.height * 0.35;

    return Container(
      width: screenWidth,
      height: screenHeight,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          AudioTitle(),
          AudioPlayerWidget(advancedPlayer: widget.advancedPlayer),
        ],
      ),
    );
  }
}
