import 'package:star_claude/data/sources/feishu_api_service.dart';

/// 基础Repository抽象类 - 提供通用的数据操作方法
/// T: 实体类型，必须实现fromFeishuMap和toFeishuMap方法
abstract class BaseRepository<T> {
  final FeishuApiService _feishuApiService;

  /// 构造函数 - 通过tableKey初始化飞书API服务
  BaseRepository(String tableKey) : _feishuApiService = FeishuApiService(tableKey: tableKey);

  /// 从飞书API返回的数据创建实体对象
  T fromFeishuMap(Map<String, dynamic> map);

  /// 将实体对象转换为飞书API所需的格式
  Map<String, dynamic> toFeishuMap(T entity);

  /// 根据自定义过滤器查询数据记录
  Future<List<T>> queryData(String filter) async {
    try {
      final result = await _feishuApiService.queryRecords(filter: filter);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final items = data['data']?['items'] as List? ?? [];
        
        return items.map<T>((item) {
          return fromFeishuMap(item as Map<String, dynamic>);
        }).toList();
      }
      return [];
    } catch (e) {
      print('查询数据失败: $e');
      return [];
    }
  }

  /// 获取所有数据记录
  Future<List<T>> getAllData() async {
    try {
      final result = await _feishuApiService.queryRecords();
      
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final items = data['data']?['items'] as List? ?? [];
        
        return items.map<T>((item) {
          return fromFeishuMap(item as Map<String, dynamic>);
        }).toList();
      }
      return [];
    } catch (e) {
      print('获取所有数据失败: $e');
      return [];
    }
  }

  /// 添加新的数据记录到飞书
  Future<Map<String, dynamic>> addData(T entity) async {
    try {
      final recordData = toFeishuMap(entity);
      print(recordData);
      final result = await _feishuApiService.addRecord(recordData);
      
      if (result['success'] == true) {
        return {
          'success': true,
          'message': '数据添加成功',
          'data': entity,
        };
      } else {
        return {
          'success': false,
          'message': '添加失败: ${result['message']}',
          'error': result['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '添加过程中发生错误',
        'error': e.toString(),
      };
    }
  }

  /// 更新数据记录
  Future<Map<String, dynamic>> updateData(String recordId, T entity) async {
    try {
      if (recordId.isEmpty) {
        return {
          'success': false,
          'message': '记录ID为空，无法更新',
        };
      }
      
      final recordData = toFeishuMap(entity);
      final result = await _feishuApiService.updateRecord(recordId, recordData);

      
      if (result['success'] == true) {
        return {
          'success': true,
          'message': '数据更新成功',
          'data': entity,
        };
      } else {
        return {
          'success': false,
          'message': '更新失败: ${result['message']}',
          'error': result['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '更新过程中发生错误',
        'error': e.toString(),
      };
    }
  }

  /// 删除数据记录
  Future<Map<String, dynamic>> deleteData(String recordId) async {
    try {
      if (recordId.isEmpty) {
        return {
          'success': false,
          'message': '记录ID为空，无法删除',
        };
      }
      
      final result = await _feishuApiService.deleteRecord(recordId);
      
      if (result['success'] == true) {
        return {
          'success': true,
          'message': '数据删除成功',
        };
      } else {
        return {
          'success': false,
          'message': '删除失败: ${result['message']}',
          'error': result['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '删除过程中发生错误',
        'error': e.toString(),
      };
    }
  }

  /// 根据ID获取单条记录
  Future<T?> getDataById(String recordId) async {
    try {
      if (recordId.isEmpty) {
        return null;
      }
      
      final result = await _feishuApiService.getRecordById(recordId);
      
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final record = data['data']?['record'] as Map<String, dynamic>?;
        
        if (record != null) {
          return fromFeishuMap(record);
        }
      }
      return null;
    } catch (e) {
      print('获取数据失败: $e');
      return null;
    }
  }
}
