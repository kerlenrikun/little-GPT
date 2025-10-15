import 'package:star_claude/domain/repository/base_repository.dart';
import 'package:star_claude/domain/entities/data/succ_data.dart';

/// 成功数据仓库 - 负责处理成功数据相关的业务逻辑和数据库操作
class SuccDataRepository extends BaseRepository<SuccDataEntity> {
  /// 构造函数
  SuccDataRepository() : super('succData');

  @override
  SuccDataEntity fromFeishuMap(Map<String, dynamic> map) {
    return SuccDataEntity.fromFeishuMap(map);
  }

  @override
  Map<String, dynamic> toFeishuMap(SuccDataEntity entity) {
    return entity.toFeishuMap();
  }
  
  /// 根据自定义过滤器查询成功数据记录
  Future<List<SuccDataEntity>> querySuccData(String filter) async {
    return await queryData(filter);
  }

  /// 添加成功数据记录
  Future<Map<String, dynamic>> addSuccDataRecord(SuccDataEntity succData) async {
    return await addData(succData);
  }

  /// 更新成功数据记录
  Future<Map<String, dynamic>> updateSuccDataRecord(String recordId, SuccDataEntity succData) async {
    if (recordId.isEmpty) {
      return {
        'success': false,
        'message': '记录ID为空，无法更新',
      };
    }
    return await updateData(recordId, succData);
  }
  
  /// 根据name查询成功数据记录
  Future<Map<String, dynamic>> querySuccDataByName(String name) async {
    final filter = 'CurrentValue.[姓名] = "$name"';
    final results = await queryData(filter);
    
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
  
  /// 根据succID查询成功数据记录
  Future<Map<String, dynamic>> querySuccDataBySuccId(String succId) async {
    final filter = 'CurrentValue.[succID] = "$succId"';
    final results = await queryData(filter);
    
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
  Future<Map<String, dynamic>> deleteSuccDataRecord(SuccDataEntity succData) async {
    if (succData.recordId.isEmpty) {
      return {
        'success': false,
        'message': '记录ID为空，无法删除',
      };
    }
    
    return await deleteData(succData.recordId);
  }
  
  /// 检查是否存在指定姓名的成功数据
  Future<bool> isSuccDataExists(String name) async {
    final results = await queryData('CurrentValue.[姓名] = "$name"');
    return results.isNotEmpty;
  }
  
  /// 根据姓名查询并获取实体对象
  Future<SuccDataEntity?> getSuccDataByName(String name) async {
    final results = await queryData('CurrentValue.[姓名] = "$name"');
    return results.isNotEmpty ? results.first : null;
  }
}