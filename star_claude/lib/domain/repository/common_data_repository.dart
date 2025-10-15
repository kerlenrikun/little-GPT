import 'package:star_claude/domain/entities/data/common_data.dart';
import 'dart:developer';
import 'package:star_claude/domain/repository/base_repository.dart';

class CommonDataRepository extends BaseRepository<CommonData> {
  CommonDataRepository() : super('commonData');

  @override
  CommonData fromFeishuMap(Map<String, dynamic> map) {
    return CommonData.fromFeishuMap(map);
  }

  @override
  Map<String, dynamic> toFeishuMap(CommonData entity) {
    return entity.toFeishuMap();
  }

  /// 根据自定义过滤器查询成功数据记录
  /// 返回commonData对象列表
  Future<List<CommonData>> queryCommonData(String filter) async {
    return queryData(filter);
  }

  /// 添加新的通用数据记录到飞书
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
    
    // 构建飞书筛选条件
    final filter = 'CurrentValue.[日期] >= "$startDateStr" and CurrentValue.[日期] <= "$endDateStr"';
    
    return queryData(filter);
  }
  
  /// 根据人员名称获取相关数据记录
  Future<List<CommonData>> getCommonDataByPerson(String personName) async {
    // 构建飞书筛选条件，查询来源或目标包含该人员的记录
    final filter = 'CurrentValue.[来源] = "$personName" or CurrentValue.[目标] = "$personName"';
    
    return queryData(filter);
  }
  
  /// 更新通用数据记录
  Future<Map<String, dynamic>> updateCommonData(CommonData data) async {
    if (data.id == null || data.id == 0) {
      return {
        'success': false,
        'message': '记录ID为空，无法更新',
      };
    }
    
    return updateData(data.id.toString(), data);
  }
  
  /// 根据ID获取通用数据
  Future<CommonData?> getCommonDataById(String recordId) async {
    final results = await getDataById(recordId);
    return results;
  }
  
  /// 删除通用数据记录
  Future<Map<String, dynamic>> deleteCommonData(String recordId) async {
    return deleteData(recordId);
  }
}