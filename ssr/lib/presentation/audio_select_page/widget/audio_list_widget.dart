import 'package:flutter/material.dart';
import 'package:ssr/presentation/audio_page/utils/audio_cloud_sync_util.dart';
import 'package:ssr/presentation/audio_select_page/widget/audio_list_card_widget.dart';

class AudioListWidget extends StatefulWidget {
  const AudioListWidget({super.key});
  @override
  State<AudioListWidget> createState() => _AudioListWidgetState();
}

class _AudioListWidgetState extends State<AudioListWidget> {
  List<Map<String, dynamic>> audioList = [];

  @override
  void initState() {
    super.initState();
    // 异步获取音频列表并更新状态
    AudioCloudSync()
        .getListInfoById('WJ6WHdexv0L7')
        .then((value) {
          setState(() {
            // 将Map<String, dynamic>转换为List<Map<String, dynamic>>
            final listContentMap = value['listContent'] as Map<String, dynamic>;
            audioList = listContentMap.values
                .map(
                  (item) => {
                    'audioId': item['audioId'] ?? '',
                    'audioName': item['name'] ?? item['audioName'] ?? '',
                    'sort': item['sort'] ?? '0',
                  },
                )
                .toList();
            print('转换后的音频列表长度: ${audioList.length}');
            print('音频列表内容: $audioList');
          });
        })
        .catchError((error) {
          print('获取音频列表失败: $error');
        });
  }

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
            audioUrl: audioList[index]['audioId'],
            index: index + 1, // 直接使用索引+1作为序号
            listCount: audioList.length,
          );
        },
      ),
    );
  }
}
