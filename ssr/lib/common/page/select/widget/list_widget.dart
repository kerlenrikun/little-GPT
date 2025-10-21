import 'package:flutter/material.dart';
import 'package:ssr/presentation/audio/utils/audio_cloud_sync_util.dart';
import 'package:ssr/common/page/select/widget/list_card_widget.dart';

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
    getAudioListInfo();
  }

  void getAudioListInfo() async {
    // 异步获取音频列表并更新状态
    await AudioCloudSync()
        .getListInfoById('WJ6WHdexv0L7')
        .then((value) {
          setState(() {
            // 将Map<String, dynamic>转换为List<Map<String, dynamic>>
            if (value.containsKey('listContent') &&
                value['listContent'] is Map) {
              final listContentMap =
                  value['listContent'] as Map<String, dynamic>;
              audioList = listContentMap.entries.map((entry) {
                try {
                  final item = entry.value as Map<String, dynamic>;
                  return {
                    'audioId': item['audioId'] ?? entry.key,
                    'audioName': item['name'] ?? item['audioName'] ?? '',
                    'sort': item['sort'] ?? '0',
                  };
                } catch (e) {
                  print('处理单个音频项时出错: $e');
                  return {'audioId': entry.key, 'audioName': '', 'sort': '0'};
                }
              }).toList();

              // 如果有sort字段，按sort值排序
              audioList.sort((a, b) {
                int sortA = int.tryParse(a['sort'].toString()) ?? 0;
                int sortB = int.tryParse(b['sort'].toString()) ?? 0;
                return sortA.compareTo(sortB);
              });
            } else {
              print('listContent字段不存在或格式不正确');
              audioList = [];
            }

            print('转换后的音频列表长度: ${audioList.length}');
            print('音频列表内容: $audioList');
          });
        })
        .catchError((error) {
          print('获取音频列表失败: $error');
          // 发生错误时清空列表
          setState(() {
            audioList = [];
          });
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
