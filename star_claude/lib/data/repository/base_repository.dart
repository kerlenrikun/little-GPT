import 'package:sqflite_common/sqlite_api.dart';
import 'package:star_claude/data/db/database_manager.dart';

/// 本地数据库基础Repository抽象类 - 提供通用的数据操作方法
/// T: 实体类型
abstract class BaseRepository<T> {
  final DatabaseManager _databaseManager = DatabaseManager();
  final String tableName;
  // ==============================访问===============================//
  /// 访问databaseManager
  DatabaseManager get databaseManager => _databaseManager;
  //==================================================================//

  /// 构造函数 - 通过表名初始化
  BaseRepository(this.tableName);

  /// 从数据库返回的数据创建实体对象
  T fromDbMap(Map<String, dynamic> map);

  /// 将实体对象转换为数据库所需的格式
  Map<String, dynamic> toDbMap(T entity);

  /// 根据自定义过滤器查询数据记录
  Future<List<T>> queryData(String? whereClause, List<dynamic>? whereArgs) async {
    try {
      final db = await _databaseManager.database;
      final result = await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
      );

      return result.map<T>((map) => fromDbMap(map)).toList();
    } catch (e) {
      print('$tableName 查询数据失败: $e');
      return [];
    }
  }

  /// 获取所有数据记录
  Future<List<T>> getAllData() async {
    try {
      final db = await _databaseManager.database;
      final result = await db.query(tableName);

      return result.map<T>((map) => fromDbMap(map)).toList();
    } catch (e) {
      print('$tableName 获取所有数据失败: $e');
      return [];
    }
  }

  /// 添加新的数据记录到数据库
  Future<Map<String, dynamic>> addData(T entity) async {
    try {
      final db = await _databaseManager.database;
      final dataMap = toDbMap(entity);
      
      // 移除id字段，让数据库自动生成
      dataMap.remove('id');
      
      final id = await db.insert(
        tableName,
        dataMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return {
        'success': true,
        'message': '数据添加成功',
        'id': id,
        'data': entity,
      };
    } catch (e) {
      return {
        'success': false,
        'message': '添加过程中发生错误',
        'error': e.toString(),
      };
    }
  }

  /// 更新数据记录
  Future<Map<String, dynamic>> updateData(int? id, T entity) async {
    try {
      if (id == null || id <= 0) {
        return {
          'success': false,
          'message': '记录ID无效，无法更新',
        };
      }

      final db = await _databaseManager.database;
      final dataMap = toDbMap(entity);
      
      final rowsAffected = await db.update(
        tableName,
        dataMap,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected > 0) {
        return {
          'success': true,
          'message': '数据更新成功',
          'data': entity,
        };
      } else {
        return {
          'success': false,
          'message': '未找到要更新的记录',
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
  Future<Map<String, dynamic>> deleteData(int? id) async {
    try {
      if (id == null || id <= 0) {
        return {
          'success': false,
          'message': '记录ID无效，无法删除',
        };
      }

      final db = await _databaseManager.database;
      final rowsAffected = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsAffected > 0) {
        return {
          'success': true,
          'message': '数据删除成功',
        };
      } else {
        return {
          'success': false,
          'message': '未找到要删除的记录',
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
  Future<T?> getDataById(int id) async {
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
        return fromDbMap(result.first);
      }
      return null;
    } catch (e) {
      print('$tableName 获取数据失败: $e');
      return null;
    }
  }

  /// 根据飞书record_id获取单条记录
  Future<T?> getDataByRecordId(String recordId) async {
    try {
      if (recordId.isEmpty) {
        return null;
      }

      final db = await _databaseManager.database;
      final result = await db.query(
        tableName,
        where: 'record_id = ?',
        whereArgs: [recordId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return fromDbMap(result.first);
      }
      return null;
    } catch (e) {
      print('$tableName 根据record_id获取数据失败: $e');
      return null;
    }
  }
}
