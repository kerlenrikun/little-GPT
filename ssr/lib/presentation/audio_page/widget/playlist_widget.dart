import 'package:flutter/material.dart';
import 'package:ssr/presentation/audio_page/widget/playlist_card_widget.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  List<Map<String, dynamic>> playlist = [
    {
      'title': '师父的录音长录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testLongMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {
      'title': '师父的录音短录音',
      'coverUrl': 'https://example.com/cover1.jpg',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blueAccent,
      constraints: BoxConstraints(maxHeight: 200), // 将constraints移到Container中
      padding: EdgeInsets.zero, // 移除内边距，确保紧密贴合
      child: ListView.builder(
        itemCount: playlist.length,
        shrinkWrap: true, // 使ListView适应内容高度
        // physics: NeverScrollableScrollPhysics(), // 禁用ListView自身滚动
        padding: EdgeInsets.zero, // 移除ListView的内边距
        itemBuilder: (context, index) {
          final audio = playlist[index];
          return PlaylistCard(
            audioTitle: audio['title'] ?? '',
            audioUrl: audio['audioUrl'] ?? '',
          );
        },
      ),
    );
  }
}
