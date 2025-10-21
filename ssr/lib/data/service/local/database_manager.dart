import 'package:flutter/material.dart';
import 'package:local_db_explorer/local_db_explorer.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ssr/domain/provider/db_path_provider.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._internal();
  static Database? _database;
  String? _customPath;
  DbPathProvider? _provider;
  String? _actualDbPath;

  factory DatabaseManager({String? dbPath, DbPathProvider? provider}) {
    _instance._customPath = dbPath;
    _instance._provider = provider;
    return _instance;
  }

  DatabaseManager._internal();

  String? get dbPath => _actualDbPath;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    // 🔍 注册数据库到本地可视化工具
    DBExplorer.registerAdapter(
      SqfliteAdapter(_database!, databaseName: 'SSR App Database'),
    );

    return _database!;
  }

  Future<Database> _initDatabase() async {
    DatabaseFactory factory = databaseFactory;

    final path = _customPath ?? join(await getDatabasesPath(), 'data.db');
    _actualDbPath = path; // 保存实际使用的路径
    print('<DatabaseManager>数据库路径: $path');

    // 同步给 Provider
    _provider?.setDbPath(path);

    // 使用正确的参数打开数据库
    return await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 15, // 升级版本号以触发onUpgrade
        onCreate: _createTables,
        onOpen: _updateTables,
        onUpgrade: _upgradeDatabase, // 添加升级回调
      ),
    );
  }

  // 初始化整体数据库表
  Future<void> _createTables(Database db, int version) async {
    //用法
    // await db.execute('''
    //     CREATE TABLE IF NOT EXISTS 表名 (
    //       列名 列类型,
    //       列名 列类型,
    //       列名 列类型,
    //       列名 列类型,
    //       列名 列类型,
    //       列名 列类型,
    //     )
    //   ''');

    await db.execute('''
        CREATE TABLE IF NOT EXISTS audio (
          audio_id TEXT PRIMARY KEY,
          uni_key TEXT DEFAULT 'nocache',
          record_id TEXT,
          audio_name TEXT,
          interaction TEXT,
          ancestor_ids TEXT,
          root_comment_ids TEXT,
          UNIQUE(uni_key, audio_id)
        )
      ''');
    await db.execute('''
        CREATE TABLE IF NOT EXISTS series (
          series_id TEXT PRIMARY KEY,
          uni_key TEXT DEFAULT 'nocache',
          record_id TEXT,
          series_name TEXT,
          series_type TEXT,
          series_content TEXT,
          UNIQUE(uni_key, series_id)
        )
      ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS articles (
        article_id TEXT PRIMARY KEY,
        content_hash TEXT,
        author_name TEXT,
        title TEXT,
        content TEXT,
        article_mark TEXT,
        publish_time TEXT,
        image_url TEXT,
        source TEXT,
        video_url TEXT,
        audio_url TEXT,
        deleted INTEGER DEFAULT 0,
        record_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS highlights (
        highlight_id TEXT PRIMARY KEY,
        user_id TEXT,
        article_id TEXT,
        start INTEGER,
        end INTEGER,
        text TEXT,
        color TEXT,
        created_time TEXT,
        updated_time TEXT,
        deleted INTEGER DEFAULT 0,
        FOREIGN KEY(article_id) REFERENCES articles(article_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS comments (
        comment_id TEXT PRIMARY KEY,
        article_id TEXT,
        start INTEGER,
        end INTEGER,
        user_id TEXT,
        text TEXT,
        comment TEXT,
        created_time TEXT,
        updated_time TEXT,
        deleted INTEGER DEFAULT 0,
        FOREIGN KEY(article_id) REFERENCES articles(article_id)
      )
    ''');
  }

  // 更新数据库表结构
  Future<void> _updateTables(Database db) async {
    await _upgradeDatabase(db, 14, 15);
    // 用法
    // await _addColumnIfNotExists (db, '表名', '新增列名', '列类型')
    // 使用CREATE TABLE IF NOT EXISTS确保表存在但不会重复创建
  }

  // 更新数据库表结构
  Future<void> _addColumnIfNotExists(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final res = await db.rawQuery('PRAGMA table_info($table)');
    final exists = res.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  // 数据库升级逻辑
  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (true) {
      // 删除旧表
      await db.execute('DROP TABLE IF EXISTS audio');
      await db.execute('DROP TABLE IF EXISTS series');
      await db.execute('DROP TABLE IF EXISTS articles');
      await db.execute('DROP TABLE IF EXISTS highlights');
      await db.execute('DROP TABLE IF EXISTS comments');

      // 重新创建表
      await _createTables(db, newVersion);
    }
    print('数据库从版本$oldVersion升级到版本$newVersion成功');
  }

  // 用法
  // Future<String> function() async {

  // 定义 Future 数据库连接
  // final Future<Database> _database = DatabaseManager().database;

  // 查询数据
  // await db.query('表名',
  // columns: ['字段A', '字段B'], // 仅获取某字段，若不写则为全部字段
  // where: '字段C = ? AND 字段D = ?', // 条件：字段等于指定值
  // whereArgs: [参数,参数]); // 绑定参数，防止SQL注入

  // 插入数据
  // await db.insert('表名', {
  //   '列名': 值
  // }, conflictAlgorithm: ConflictAlgorithm.replace); // 插入策略：若重复则替换

  // 更新数据
  //   await db.update(
  //   '表名',
  //   {'字段A': 值, '字段B': 值,'字段C': 值}, // 需要更新的字段
  //   where: '字段D = ?', // 条件：字段等于指定值
  //   whereArgs: [参数], // 绑定参数，防止SQL注入
  // );

  // 删除数据
  // await db.delete('表名',
  //   where: '字段 = ?', // 条件：字段等于指定值
  //   whereArgs: [参数]); // 绑定参数，防止SQL注入
  // }
}
