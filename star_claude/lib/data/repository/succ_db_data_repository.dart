import 'package:star_claude/domain/entities/data/succ_data.dart';
import 'package:star_claude/data/repository/base_repository.dart';

/// 本地成功数据仓库 - 负责处理本地数据库中成功数据相关的操作
class SuccDbDataRepository extends BaseRepository<SuccDataEntity> {
  /// 构造函数
  SuccDbDataRepository() : super('succ_data');

  @override
  SuccDataEntity fromDbMap(Map<String, dynamic> map) {
    return SuccDataEntity.fromMap(map);
  }

  @override
  Map<String, dynamic> toDbMap(SuccDataEntity entity) {
    return entity.toMap();
  }

  /// 根据自定义条件查询成功数据记录
  Future<List<SuccDataEntity>> querySuccData(String? whereClause, List<dynamic>? whereArgs) async {
    return await queryData(whereClause, whereArgs);
  }

  /// 添加成功数据记录
  Future<Map<String, dynamic>> addSuccDataRecord(SuccDataEntity succData) async {
    return await addData(succData);
  }

  /// 更新成功数据记录
  Future<Map<String, dynamic>> updateSuccDataRecord(int? id, SuccDataEntity succData) async {
    return await updateData(id, succData);
  }

  /// 根据学生姓名查询成功数据记录
  Future<Map<String, dynamic>> querySuccDataByName(String name) async {
    final results = await queryData('student_name = ?', [name]);
    
    if (results.isNotEmpty) {
      return {
        'success': true,
        'message': '查询成功',
        'data': results,
      };
    } else {
      return {
        'success': true,
        'message': '未找到匹配记录',
        'data': [],
      };
    }
  }

  /// 获取所有成功数据记录
  Future<List<SuccDataEntity>> getAllSuccDataRecords() async {
    return await getAllData();
  }

  /// 根据记录ID查询成功数据记录
  Future<Map<String, dynamic>> querySuccDataByRecordId(String recordId) async {
    final results = await queryData('record_id = ?', [recordId]);
    
    if (results.isNotEmpty) {
      return {
        'success': true,
        'message': '查询成功',
        'data': results.first,
      };
    } else {
      return {
        'success': true,
        'message': '未找到匹配记录',
        'data': null,
      };
    }
  }

  /// 删除成功数据记录
  Future<Map<String, dynamic>> deleteSuccDataRecord(int? id) async {
    return await deleteData(id);
  }

  /// 检查是否存在指定姓名的成功数据
  Future<bool> isSuccDataExists(String name) async {
    final results = await queryData('student_name = ?', [name]);
    return results.isNotEmpty;
  }

  /// 根据姓名查询并获取实体对象
  Future<SuccDataEntity?> getSuccDataByName(String name) async {
    final results = await queryData('student_name = ?', [name]);
    return results.isNotEmpty ? results.first : null;
  }

  /// 根据日期范围查询成功数据
  Future<List<SuccDataEntity>> getSuccDataByDateRange(DateTime startDate, DateTime endDate) async {
    final formattedStartDate = startDate.toIso8601String().split('T')[0];
    final formattedEndDate = endDate.toIso8601String().split('T')[0];
    
    return await queryData(
      'succ_date BETWEEN ? AND ?',
      [formattedStartDate, formattedEndDate],
    );
  }

  /// 获取指定月份的成功数据
  Future<List<SuccDataEntity>> getSuccDataByMonth(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);
    
    return await getSuccDataByDateRange(startDate, endDate);
  }

  /// 根据直销端查询成功数据
  Future<List<SuccDataEntity>> getSuccDataByZX(String zxName) async {
    return await queryData('succ_zx = ?', [zxName]);
  }

  /// 根据转化端查询成功数据
  Future<List<SuccDataEntity>> getSuccDataByZH(String zhName) async {
    return await queryData('succ_zh = ?', [zhName]);
  }

  /// 根据流量端查询成功数据
  Future<List<SuccDataEntity>> getSuccDataByLL(String llName) async {
    return await queryData('succ_ll = ?', [llName]);
  }

  /// 根据承接端查询成功数据
  Future<List<SuccDataEntity>> getSuccDataByCJ(String cjName) async {
    return await queryData('succ_cj = ?', [cjName]);
  }

  /// 根据课程类型查询成功数据
  Future<List<SuccDataEntity>> getSuccDataByClassType(String classType) async {
    return await queryData('class_type = ?', [classType]);
  }
}