import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ssr/data/service/local/database_manager.dart';
import 'package:ssr/domain/entity/audio.dart';
import 'package:ssr/domain/provider/series_id_provider.dart';

class AudioDbManager {
  // 使用DatabaseManager单例实例
  final DatabaseManager _dbManager = DatabaseManager();
  Future<Database> get _database => _dbManager.database;

  /// 更新音频记录
  Future<void> insertAudioRecord(Map<String, dynamic> record) async {
    print('插入audio记录: $record');
    final db = await _database;
    try {
      await db.insert('audio', {
        'uni_key': 'nocache',
        ...record,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print('audio记录插入成功');
    } catch (e) {
      print('audio记录插入失败: $e');
      rethrow;
    }
  }

  /// 更新系列记录
  Future<void> insertSeriesRecord(Map<String, dynamic> record) async {
    print('插入series记录: $record');
    final db = await _database;
    try {
      await db.insert('series', {
        'uni_key': 'nocache',
        ...record,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      print('series记录插入成功');
    } catch (e) {
      print('series记录插入失败: $e');
      rethrow;
    }
  }

  Future<void> getSeriesIdFormDb(BuildContext context) async {
    final audioContentList = await AudioDbManager().queryAudioRecord();

    print('audioContentList: $audioContentList');

    // 从audioContentList中提取ancestor_ids并解析
    try {
      final ancestorIdsData = audioContentList[0]['ancestor_ids'];
      List<String> ancestorIds = [];

      if (ancestorIdsData is String) {
        // 如果是JSON字符串，进行解析
        try {
          final decoded = jsonDecode(ancestorIdsData);
          if (decoded is List) {
            ancestorIds = decoded
                .where((item) => item is String)
                .map((item) => item as String)
                .toList();
          }
        } catch (e) {
          print('解析ancestor_ids JSON失败: $e');
        }
      } else if (ancestorIdsData is List) {
        // 如果已经是List类型
        ancestorIds = ancestorIdsData
            .where((item) => item is String)
            .map((item) => item as String)
            .toList();
      }

      print('获取到的ancestor_ids: $ancestorIds');
      if (ancestorIds.isNotEmpty) {
        // 使用context获取已注册的SeriesIdProvider实例
        Provider.of<SeriesIdProvider>(
          context,
          listen: false,
        ).updateSeriesId(ancestorIds);
        print('ancestor_ids[0]: ${ancestorIds[0]}');
      }
    } catch (e) {
      print('处理ancestor_ids时出错: $e');
    }
  }

  Future<List<Map<String, Object?>>> queryAudioRecord() async {
    final db = await _database;
    final result = await db.query(
      'audio',
      where: 'uni_key = ?',
      whereArgs: ['nocache'],
    );
    print('查询audio记录: $result');
    return result;
  }

  Future<List<Map<String, Object?>>> querySeriesRecord() async {
    final db = await _database;
    final result = await db.query(
      'series',
      where: 'uni_key = ?',
      whereArgs: ['nocache'],
    );
    print('查询series记录: $result');
    return result;
  }
}
