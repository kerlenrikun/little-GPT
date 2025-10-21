// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// import 'package:ssr/domain/repository/user_repository.dart';

// /// 数据库管理器 - 负责数据库的创建、初始化和操作
// class DatabaseManager {
//   static final DatabaseManager _instance = DatabaseManager._internal();
//   static Database? _database;
//   String? _actualDbPath;

//   // 当前数据库版本号
//   static const int _dbVersion = 2;

//   factory DatabaseManager() {
//     return _instance;
//   }

//   DatabaseManager._internal();
  
//   String? get dbPath => _actualDbPath;

//   /// 获取数据库实例
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   /// 初始化数据库
//   Future<Database> _initDatabase() async {

//     final path = join(await getDatabasesPath(), 'data.db');
//     _actualDbPath = path;
//     print('<DatabaseManager>数据库路径: $path');

//     return await openDatabase(
//       path,
//       version: _dbVersion,
//       onCreate: _createTables,
//       onUpgrade: _upgradeTables,
//     );
//   }

//   /// 创建数据库表
//   Future<void> _createTables(Database db, int version) async {
//     // 创建用户表
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS users (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         record_id TEXT,
//         full_name TEXT NOT NULL,
//         phone_number TEXT NOT NULL UNIQUE,
//         password TEXT NOT NULL,
//         created_time TEXT DEFAULT '',
//         last_login_time TEXT DEFAULT '',
//         allow_job TEXT DEFAULT '{}'
//       )
//     ''');

//     // 创建缓存表，用于存储临时数据和缓存
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS cache (
//         key TEXT PRIMARY KEY,
//         value TEXT,
//         expiry_time TIMESTAMP,
//         updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
//       )
//     ''');
//   }

//   /// 升级数据库表
//   Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
//     // 当数据库版本不匹配时，删除并重新创建所有表
//     print('<DatabaseManager>升级数据库: 从版本 $oldVersion 升级到 $newVersion');
    
//     // 删除所有表
//     await db.execute('DROP TABLE IF EXISTS users');
//     await db.execute('DROP TABLE IF EXISTS account_data');
//     await db.execute('DROP TABLE IF EXISTS common_data');
//     await db.execute('DROP TABLE IF EXISTS succ_data');
//     await db.execute('DROP TABLE IF EXISTS cache');
    
//     // 重新创建所有表
//     await _createTables(db, newVersion);
//   }
  
//   /// 关闭数据库连接
//   Future<void> close() async {
//     if (_database != null) {
//       await _database!.close();
//       _database = null;
//     }
//   }
  
//   /// 重置数据库 - 删除所有表并重新创建
//   Future<void> resetDatabase() async {
//     await close();
    
//     // 删除数据库文件
//     if (_actualDbPath != null) {
//       try {
//         final file = File(_actualDbPath!);
//         if (await file.exists()) {
//           await file.delete();
//           print('<DatabaseManager>数据库文件已删除: $_actualDbPath');
//         }
//       } catch (e) {
//         print('<DatabaseManager>删除数据库文件失败: $e');
//       }
//     }
    
//     // 重置数据库连接
//     _database = null;
//     // 重新初始化数据库
//     await database;
//   }

//   /// 清除所有数据
//   Future<void> clearAllData() async {
//     final db = await database;
//     await db.delete('users');
//   }

//   /// 从飞书导入用户数据到本地数据库
//   Future<int> importUsersFromFeishu() async {
//     final db = await database;
//     final userRepository = UserRepository();
//     int importedCount = 0;

//     try {
//       // 从飞书获取所有用户
//       final users = await userRepository.getAll();
//       //----------------------------------------------//
//       if (users.isNotEmpty) {
//         // 使用事务批量插入
//         await db.transaction((txn) async {
//           // 先清空本地用户表
//           await txn.delete('users');
          
//           // 批量插入新数据
//           for (final user in users) {
//             final map = user.toLoMap();
//             // 移除id字段，让数据库自动生成
//             map.remove('id');
//             await txn.insert('users', map, conflictAlgorithm: ConflictAlgorithm.replace);
//             importedCount++;
//           }
//         });
//       }
      
//       print('<DatabaseManager>成功从飞书导入 $importedCount 条用户数据');
//       return importedCount;
//     } catch (e) {
//       print('<DatabaseManager>从飞书导入用户数据失败: $e');
//       return 0;
//     }
//   }


//   /// 导入所有飞书数据到本地数据库
//   Future<Map<String, int>> importAllDataFromFeishu() async {
//     final result = <String, int>{
//       'users': 0,
//       'accountData': 0,
//       'commonData': 0,
//       'succData': 0,
//     };

//     try {
//       result['users'] = await importUsersFromFeishu();
      
//       print('<DatabaseManager>成功从飞书导入所有数据');
//     } catch (e) {
//       print('<DatabaseManager>从飞书导入所有数据失败: $e');
//     }

//     return result;
//   }
// }
