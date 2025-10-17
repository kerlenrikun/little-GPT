import 'package:flutter/material.dart';
import 'package:ssr/presentation/audio_select_page/widget/audio_list_card_widget.dart';

class AudioListWidget extends StatefulWidget {
  const AudioListWidget({super.key});
  @override
  State<AudioListWidget> createState() => _AudioListWidgetState();
}

class _AudioListWidgetState extends State<AudioListWidget> {
  List<Map<String, dynamic>> audioList = [
    {
      'audioName': '音频1',
      'audioUrl': 'http://116.62.64.88/projectDoc/testLongMp3.mp3',
    },
    {
      'audioName': '音频2',
      'audioUrl': 'http://116.62.64.88/projectDoc/testMp3.mp3',
    },
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio3.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio4.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio5.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio6.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio7.mp3'},
    {'audioName': '音频1', 'audioUrl': 'https://example.com/audio1.mp3'},
    {'audioName': '音频2', 'audioUrl': 'https://example.com/audio2.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio3.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio4.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio5.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio6.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio7.mp3'},
    {'audioName': '音频1', 'audioUrl': 'https://example.com/audio1.mp3'},
    {'audioName': '音频2', 'audioUrl': 'https://example.com/audio2.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio3.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio4.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio5.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio6.mp3'},
    {'audioName': '音频3', 'audioUrl': 'https://example.com/audio7.mp3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 300), // 将constraints移到Container中
      padding: EdgeInsets.zero, // 移除内边距，确保紧密贴合
      child: ListView.builder(
        itemCount: audioList.length,
        shrinkWrap: true, // 使ListView适应内容高度
        // physics: NeverScrollableScrollPhysics(), // 禁用ListView自身滚动
        padding: EdgeInsets.zero, // 移除ListView的内边距
        itemBuilder: (context, index) {
          return AudioListCardWidget(
            audioName: audioList[index]['audioName'],
            audioUrl: audioList[index]['audioUrl'],
            index: index + 1, // 直接使用索引+1作为序号
            listCount: audioList.length,
          );
        },
      ),
    );
  }
}
