import 'dart:developer';
import 'package:star_claude/domain/entities/data/common_data.dart';
import 'package:star_claude/data/repository/base_repository.dart';
import 'package:star_claude/data/db/database_manager.dart';

/// 本地通用数据仓库 - 负责处理本地数据库中通用数据相关的操作
class CommonDbDataRepository extends BaseRepository<CommonData> {
  /// 构造函数
  CommonDbDataRepository() : super('common_data');

  @override
  CommonData fromDbMap(Map<String, dynamic> map) {
    return CommonData.fromMap(map);
  }

  @override
  Map<String, dynamic> toDbMap(CommonData entity) {
    return entity.toMap();
  }

  /// 根据自定义条件查询通用数据记录
  Future<List<CommonData>> queryCommonData(String? whereClause, List<dynamic>? whereArgs) async {
    return queryData(whereClause, whereArgs);
  }

  /// 添加新的通用数据记录到本地数据库
  Future<Map<String, dynamic>> addCommonData(CommonData data) async {
    return addData(data);
  }

  /// 获取所有通用数据记录
  Future<List<CommonData>> getAllCommonData() async {
    return getAllData();
  }

  /// 根据日期范围获取通用数据记录
  Future<List<CommonData>> getCommonDataByDateRange(DateTime startDate, DateTime endDate) async {
    // 格式化日期为YYYY-MM-DD格式
    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];
    
    return queryData(
      'date BETWEEN ? AND ?',
      [startDateStr, endDateStr],
    );
  }

  /// 根据人员名称获取相关数据记录
  Future<List<CommonData>> getCommonDataByPerson(String personName) async {
    // 查询来源或目标包含该人员的记录
    return queryData(
      '(from_ll = ? OR from_cj = ? OR from_zx = ? OR from_zh = ? OR to_ll = ? OR to_cj = ? OR to_zx = ? OR to_zh = ?)',
      List.filled(8, personName),
    );
  }

  /// 更新通用数据记录
  Future<Map<String, dynamic>> updateCommonData(int? id, CommonData data) async {
    if (id == null || id <= 0) {
      return {
        'success': false,
        'message': '记录ID无效，无法更新',
      };
    }
    
    return updateData(id, data);
  }

  /// 根据本地ID获取通用数据
  Future<CommonData?> getCommonDataById(int id) async {
    return getDataById(id);
  }

  /// 根据飞书record_id获取通用数据
  Future<CommonData?> getCommonDataByRecordId(String recordId) async {
    return getDataByRecordId(recordId);
  }

  /// 删除通用数据记录
  Future<Map<String, dynamic>> deleteCommonData(int? id) async {
    return deleteData(id);
  }

  /// 根据流量端获取数据
  Future<List<CommonData>> getCommonDataByLL(String llName) async {
    return queryData('from_ll = ?', [llName]);
  }

  /// 根据承接端获取数据
  Future<List<CommonData>> getCommonDataByCJ(String cjName) async {
    return queryData('from_cj = ?', [cjName]);
  }

  /// 根据直销端获取数据
  Future<List<CommonData>> getCommonDataByZX(String zxName) async {
    return queryData('from_zx = ?', [zxName]);
  }

  /// 根据转化端获取数据
  Future<List<CommonData>> getCommonDataByZH(String zhName) async {
    return queryData('from_zh = ?', [zhName]);
  }

  /// 获取指定月份的通用数据
  Future<List<CommonData>> getCommonDataByMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    
    return getCommonDataByDateRange(startDate, endDate);
  }

  /// 获取指定日期的通用数据
  Future<List<CommonData>> getCommonDataByDate(String date) async {
    return queryData('date = ?', [date]);
  }

  /// 获取指定范围内的总数值
  Future<int> getTotalValueByDateRange(DateTime startDate, DateTime endDate) async {
    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];
    
    try {
      final db = await databaseManager.database;
      final result = await db.rawQuery(
        'SELECT SUM(value) as total FROM common_data WHERE date BETWEEN ? AND ?',
        [startDateStr, endDateStr],
      );
      
      if (result.isNotEmpty && result[0]['total'] != null) {
        // SQLite的SUM函数返回的可能是num类型，需要转换为int
        return int.tryParse(result[0]['total'].toString()) ?? 0;
      }
      return 0;
    } catch (e) {
      print('计算总数值失败: $e');
      return 0;
    }
  }
}