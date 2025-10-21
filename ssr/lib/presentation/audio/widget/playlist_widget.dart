import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ssr/domain/provider/series_id_provider.dart';
import 'package:ssr/presentation/audio/utils/audio_cloud_sync_util.dart';
import 'package:ssr/presentation/audio/utils/audio_db_manager.dart';
import 'package:ssr/presentation/audio/widget/playlist_card_widget.dart';
import 'package:ssr/domain/provider/audio_url_provider.dart';

class Playlist extends StatefulWidget {
  const Playlist({super.key});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  List<Map<String, dynamic>> playlist = [];

  @override
  void initState() {
    super.initState();
    // AudioCloudSync()
    //     .getListInfoById(context.read<AudioUrlProvider>().listId)
    //     .then((value) {
    //       setState(() {
    //         // 将Map<String, dynamic>转换为List<Map<String, dynamic>>
    //         final listContentMap = value['listContent'] as Map<String, dynamic>;
    //         playlist = listContentMap.values
    //             .map(
    //               (item) => {
    //                 'audioId': item['audioId'] ?? '',
    //                 'audioName': item['name'] ?? item['audioName'] ?? '',
    //                 'sort': item['sort'] ?? '0',
    //               },
    //             )
    //             .toList();
    //         print('转换后的音频列表长度: ${playlist.length}');
    //         print('音频列表内容: $playlist');
    //       });
    //     })
    //     .catchError((error) {
    //       print('获取音频列表失败: $error');
    //     });
    getSeriesInfoByDb();
  }

  void getSeriesInfoByDb() async {
    await AudioDbManager().getSeriesIdFormDb(context);
    final seriesId = context.read<SeriesIdProvider>().seriesId;
    if (seriesId.isEmpty) {
      print('seriesId为空');
      return;
    }
    await AudioCloudSync()
        .getListInfoById(seriesId)
        .then((value) {
          setState(() {
            // 将Map<String, Map<String, dynamic>>转换为List<Map<String, dynamic>>
            if (value.containsKey('seriesContent') &&
                value['seriesContent'] is Map) {
              final seriesContentMap =
                  value['seriesContent'] as Map<String, dynamic>;
              playlist = seriesContentMap.entries.map((entry) {
                final audioData = entry.value as Map<String, dynamic>;
                return {
                  'audioId': audioData['audioId'] ?? entry.key,
                  'audioName':
                      audioData['name'] ?? audioData['audioName'] ?? '',
                  'sort': audioData['sort'] ?? '0',
                };
              }).toList();
              // 如果有sort字段，按sort值排序
              playlist.sort((a, b) {
                int sortA = int.tryParse(a['sort'].toString()) ?? 0;
                int sortB = int.tryParse(b['sort'].toString()) ?? 0;
                return sortA.compareTo(sortB);
              });
            } else {
              print('seriesContent字段不存在或格式不正确');
              playlist = [];
            }
            print('转换后的音频列表长度: ${playlist.length}');
            print('音频列表内容: $playlist');
          });
        })
        .catchError((error) {
          print('获取音频列表失败: $error');
        });
    // final seriesContentList = await AudioDbManager().querySeriesRecord();
    // if (seriesContentList.isNotEmpty) {
    //   setState(() {
    //     // 假设seriesContentList是包含series记录的列表
    //     // 我们取第一条记录中的series_content字段（如果存在）
    //     final firstRecord = seriesContentList[0];
    //     if (firstRecord is Map<String, dynamic> &&
    //         firstRecord.containsKey('series_content')) {
    //       try {
    //         // 解析series_content字段为List<Map<String, dynamic>>
    //         final seriesContent = firstRecord['series_content'];
    //         if (seriesContent is String) {
    //           // 如果是JSON字符串，需要先解码
    //           // 注意：这里假设已经导入了dart:convert
    //           final decoded = jsonDecode(seriesContent);
    //           if (decoded is List) {
    //             playlist = decoded
    //                 .where((item) => item is Map)
    //                 .map(
    //                   (item) => {
    //                     'audioId': item['audioId'] ?? '',
    //                     'audioName': item['name'] ?? item['audioName'] ?? '',
    //                     'sort': item['sort'] ?? '0',
    //                   },
    //                 )
    //                 .toList();
    //           }
    //         } else if (seriesContent is List) {
    //           // 如果已经是List类型，直接处理
    //           playlist = seriesContent
    //               .where((item) => item is Map)
    //               .map(
    //                 (item) => {
    //                   'audioId': item['audioId'] ?? '',
    //                   'audioName': item['name'] ?? item['audioName'] ?? '',
    //                   'sort': item['sort'] ?? '0',
    //                 },
    //               )
    //               .toList();
    //         }
    //         print('从数据库获取的音频列表长度: ${playlist.length}');
    //         print('从数据库获取的音频列表内容: $playlist');
    //       } catch (e) {
    //         print('解析series_content失败: $e');
    //         playlist = [];
    //       }
    //     }
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    // 使用Consumer监听AudioUrlProvider的变化
    return Consumer<AudioUrlProvider>(
      builder: (context, audioUrlProvider, child) {
        // 当音频ID更新时，组件会自动重建，显示正确的选中状态
        final currentAudioId = audioUrlProvider.audioId;
        print('当前选中的音频ID: $currentAudioId');

        return Container(
          // color: Colors.blueAccent,
          constraints: BoxConstraints(
            maxHeight: 200,
          ), // 将constraints移到Container中
          padding: EdgeInsets.zero, // 移除内边距，确保紧密贴合
          child: ListView.builder(
            itemCount: playlist.length,
            shrinkWrap: true, // 使ListView适应内容高度
            // physics: NeverScrollableScrollPhysics(), // 禁用ListView自身滚动
            padding: EdgeInsets.zero, // 移除ListView的内边距
            itemBuilder: (context, index) {
              final audio = playlist[index];
              return PlaylistCard(
                audioTitle: audio['audioName'] ?? '',
                audioUrl: audio['audioId'] ?? '',
              );
            },
          ),
        );
      },
    );
  }
}
