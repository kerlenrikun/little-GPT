import 'package:sqflite/sqflite.dart';
import 'package:ssr/data/service/cloude/cloude_api_service.dart';
import 'package:ssr/data/service/local/database_manager.dart';

/// T: 实体类型，必须实现fromMap和toMap方法
abstract class Repository<T> {
  /// ==================================云端 API服务==================================

  late CloudApiService _cloudeApiService;
  late DatabaseManager _databaseManager;

  /// 构造函数 - 通过tableKey初始化  云端  API服务
  Repository(String tableKey, String tableName) : tableName = tableName {
    _cloudeApiService = CloudApiService(tableKey: tableKey);
    _databaseManager = DatabaseManager();
  }

  /// 泛型 - 所有实体都会有fromMap方法, 这里通过泛型调用
  T fromClMap(Map<String, dynamic> map);

  /// 泛型 - 所有实体都会有toMap方法, 这里通过泛型调用
  Map<String, dynamic> toClMap(T entity);

  /// 泛型 - 所有服务体都会有queryRecords方法, 这里通过泛型调用
  Future<List<T>> getResource(String resourceType, String resourceId) async {
    try {
      final result = await _cloudeApiService.getResource(
        resourceType,
        resourceId,
      );

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final items = data['data']?['items'] as List? ?? [];

        return items.map<T>((item) {
          return fromClMap(item as Map<String, dynamic>);
        }).toList();
      }
      return [];
    } catch (e) {
      print('查询数据失败: $e');
      return [];
    }
  }

  /// ==================================本地 API服务==================================

  /// 本地数据库服务
  String tableName = 'users';

  /// 访问databaseManager
  DatabaseManager get databaseManager => _databaseManager;

  /// 从数据库返回的数据创建实体对象
  T fromLoMap(Map<String, dynamic> map);

  /// 将实体对象转换为数据库所需的格式
  Map<String, dynamic> toLoMap(T entity);

  /// 根据自定义过滤器查询本地数据
  Future<List<T>> queryLo(String? whereClause, List<dynamic>? whereArgs) async {
    try {
      final db = await _databaseManager.database;
      final result = await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
      );

      return result.map<T>((map) => fromLoMap(map)).toList();
    } catch (e) {
      print('$tableName 查询数据失败: $e');
      return [];
    }
  }

  /// 获取所有本地数据
  Future<List<T>> getAllLo() async {
    try {
      final db = await _databaseManager.database;
      final result = await db.query(tableName);

      return result.map<T>((map) => fromLoMap(map)).toList();
    } catch (e) {
      print('$tableName 获取所有数据失败: $e');
      return [];
    }
  }

  /// 添加新的数据到本地
  Future<Map<String, dynamic>> addLo(T entity) async {
    try {
      final db = await _databaseManager.database;
      final dataMap = toLoMap(entity);

      // 移除id字段，让数据库自动生成
      dataMap.remove('id');

      final id = await db.insert(
        tableName,
        dataMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return {'success': true, 'message': '数据添加成功', 'id': id, 'data': entity};
    } catch (e) {
      return {'success': false, 'message': '添加过程中发生错误', 'error': e.toString()};
    }
  }

  /// 更新本地数据
  Future<Map<String, dynamic>> updateLo(int? id, T entity) async {
    try {
      if (id == null || id <= 0) {
        return {'success': false, 'message': '记录ID无效，无法更新'};
      }

      final db = await _databaseManager.database;
      final dataMap = toLoMap(entity);

      final rowsAffected = await db.update(
        tableName,
        dataMap,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected > 0) {
        return {'success': true, 'message': '数据更新成功', 'data': entity};
      } else {
        return {'success': false, 'message': '未找到要更新的记录'};
      }
    } catch (e) {
      return {'success': false, 'message': '更新过程中发生错误', 'error': e.toString()};
    }
  }

  /// 删除数据记录
  Future<Map<String, dynamic>> deleteLo(int? id) async {
    try {
      if (id == null || id <= 0) {
        return {'success': false, 'message': '记录ID无效，无法删除'};
      }

      final db = await _databaseManager.database;
      final rowsAffected = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected > 0) {
        return {'success': true, 'message': '数据删除成功'};
      } else {
        return {'success': false, 'message': '未找到要删除的记录'};
      }
    } catch (e) {
      return {'success': false, 'message': '删除过程中发生错误', 'error': e.toString()};
    }
  }

  /// 根据ID获取单条记录
  Future<T?> getLoById(int id) async {
    try {
      if (id <= 0) {
        return null;
      }

      final db = await _databaseManager.database;
      final result = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return fromLoMap(result.first);
      }
      return null;
    } catch (e) {
      print('$tableName 获取数据失败: $e');
      return null;
    }
  }
}


  // /// 泛型 - 所有服务体都会有queryRecords方法, 这里通过泛型调用
  // Future<List<T>> query(String filter) async {
  //   try {
  //     final result = await _cloudeApiService.queryRecords(filter: filter);

  //     if (result['success'] == true) {
  //       final data = result['data'] as Map<String, dynamic>;
  //       final items = data['data']?['items'] as List? ?? [];

  //       return items.map<T>((item) {
  //         return fromClMap(item as Map<String, dynamic>);
  //       }).toList();
  //     }
  //     return [];
  //   } catch (e) {
  //     print('查询数据失败: $e');
  //     return [];
  //   }
  // }

  // /// 获取所有数据记录
  // Future<List<T>> getAll() async {
  //   try {
  //     final result = await _cloudeApiService.queryRecords();

  //     if (result['success'] == true) {
  //       final data = result['data'] as Map<String, dynamic>;
  //       final items = data['data']?['items'] as List? ?? [];

  //       return items.map<T>((item) {
  //         return fromClMap(item as Map<String, dynamic>);
  //       }).toList();
  //     }
  //     return [];
  //   } catch (e) {
  //     print('获取所有数据失败: $e');
  //     return [];
  //   }
  // }

  // /// 添加新的数据记录到云端
  // Future<Map<String, dynamic>> add(T entity) async {
  //   try {
  //     final recordData = toClMap(entity);
  //     print(recordData);
  //     final result = await _cloudeApiService.addRecord(recordData);

  //     if (result['success'] == true) {
  //       return {'success': true, 'message': '数据添加成功', 'data': entity};
  //     } else {
  //       return {
  //         'success': false,
  //         'message': '添加失败: ${result['message']}',
  //         'error': result['error'],
  //       };
  //     }
  //   } catch (e) {
  //     return {'success': false, 'message': '添加过程中发生错误', 'error': e.toString()};
  //   }
  // }

  // /// 更新数据记录
  // Future<Map<String, dynamic>> update(String recordId, T entity) async {
  //   try {
  //     if (recordId.isEmpty) {
  //       return {'success': false, 'message': '记录ID为空，无法更新'};
  //     }

  //     final recordData = toClMap(entity);
  //     final result = await _cloudeApiService.updateRecord(recordId, recordData);

  //     if (result['success'] == true) {
  //       return {'success': true, 'message': '数据更新成功', 'data': entity};
  //     } else {
  //       return {
  //         'success': false,
  //         'message': '更新失败: ${result['message']}',
  //         'error': result['error'],
  //       };
  //     }
  //   } catch (e) {
  //     return {'success': false, 'message': '更新过程中发生错误', 'error': e.toString()};
  //   }
  // }

  // /// 删除数据记录
  // Future<Map<String, dynamic>> delete(String recordId) async {
  //   try {
  //     if (recordId.isEmpty) {
  //       return {'success': false, 'message': '记录ID为空，无法删除'};
  //     }

  //     final result = await _cloudeApiService.deleteRecord(recordId);

  //     if (result['success'] == true) {
  //       return {'success': true, 'message': '数据删除成功'};
  //     } else {
  //       return {
  //         'success': false,
  //         'message': '删除失败: ${result['message']}',
  //         'error': result['error'],
  //       };
  //     }
  //   } catch (e) {
  //     return {'success': false, 'message': '删除过程中发生错误', 'error': e.toString()};
  //   }
  // }
