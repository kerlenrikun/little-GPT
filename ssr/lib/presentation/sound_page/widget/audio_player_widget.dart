import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayProvider extends StatefulWidget {
  final AudioPlayer advancedPlayer;
  const AudioPlayProvider({super.key, required this.advancedPlayer});

  @override
  State<AudioPlayProvider> createState() => _AudioPlayProviderState();
}

class _AudioPlayProviderState extends State<AudioPlayProvider> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  final String audioUrl = 'https://rmtt.top/projectDoc/testMp3.mp3';
  bool _isPlaying = false;
  bool isLoop = false;
  List<String> audioList = ['https://rmtt.top/projectDoc/testMp3.mp3'];
  List<Icon> iconList = [Icon(Icons.play_arrow), Icon(Icons.pause)];

  @override
  void initState() {
    super.initState();
    widget.advancedPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });
    widget.advancedPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    widget.advancedPlayer.setSourceUrl(audioUrl);

    // widget.advancedPlayer.onPlayerStateChanged.listen((PlayerState s) {
    //   setState(() {
    //     _isPlaying = s == PlayerState.playing;
    //   });
    // });
  }

  Widget btnPlay() {
    return IconButton(
      icon: iconList[_isPlaying ? 1 : 0],
      onPressed: () async {
        if (_isPlaying) {
          await widget.advancedPlayer.pause();
        } else {
          await widget.advancedPlayer.play(UrlSource(audioUrl));
        }
        setState(() {
          _isPlaying = !_isPlaying;
        });
      },
    );
  }

  Widget loadAsset() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [btnPlay()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: [loadAsset()]));
  }
}
