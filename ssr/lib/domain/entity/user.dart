import 'dart:convert';

/// 用户实体类 - 定义用户数据结构和操作
/// 用于表示和处理用户相关信息
class UserEntity {
  // 核心用户属性
  final int? id; // 数据库ID，自增
  final String? recordId; // 记录ID
  final String fullName; // 用户全名
  final String phoneNumber; // 手机号码
  final String password; // 密码
  final DateTime createdTime; // 创建时间
  final DateTime lastLoginTime; // 最后登录时间
  final Map<String, int> allowJob; // 允许的工作权限，Map格式
  String? job; // 当前岗位

  /// 构造函数 - 创建用户实体实例
  UserEntity({
    this.id,
    this.recordId,
    required this.fullName,
    required this.phoneNumber,
    required this.password,
    DateTime? createdTime,
    DateTime? lastLoginTime,
    Map<String, int>? allowJob,
    this.job,
  }) : createdTime = createdTime ?? DateTime.now(),
       lastLoginTime = lastLoginTime ?? DateTime.now(),
       allowJob =
           allowJob ?? {'流量端': 0, '承接端': 0, '直销端': 0, '转化端': 0, '数据端': 0};

  /// 创建一个新的用户实体，仅修改指定的属性
  /// 方便在不改变原有实体的情况下更新部分属性
  UserEntity copyWith({
    int? id,
    String? recordId,
    String? fullName,
    String? phoneNumber,
    String? password,
    DateTime? createdTime,
    DateTime? lastLoginTime,
    Map<String, int>? allowJob,
    String? job,
  }) {
    return UserEntity(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      createdTime: createdTime ?? this.createdTime,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      job: job ?? this.job,
      allowJob: allowJob ?? this.allowJob,
    );
  }

  /// 从数据库Map转换为UserEntity
  factory UserEntity.fromLoMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map['id'] as int?,
      recordId: map['record_id'] as String?,
      fullName: map['full_name'] as String? ?? '',
      phoneNumber: map['phone_number'] as String? ?? '',
      password: map['password'] as String? ?? '',
      createdTime: DateTime.parse(map['created_time']),
      lastLoginTime: DateTime.parse(map['last_login_time']),
      allowJob: _parseAllowJob(map['allow_job']),
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toLoMap() {
    return {
      'record_id': recordId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'password': password,
      'created_time': createdTime.toIso8601String(),
      'last_login_time': lastLoginTime.toIso8601String(),
      'allow_job': jsonEncode(allowJob),
    };
  }

  /// 从云端Map转换为UserEntity
  factory UserEntity.fromClMap(Map<String, dynamic> map) {
    return UserEntity(
      recordId: map['record_id'] as String?,
      fullName: map['fields']['姓名'] as String? ?? '',
      phoneNumber: map['fields']['手机号'] as String? ?? '',
      password: map['fields']['密码'] as String? ?? '',
      createdTime: DateTime.parse(
        map['fields']['注册时间'] as String? ?? DateTime.now().toIso8601String(),
      ),
      lastLoginTime: DateTime.parse(
        map['fields']['登录时间'] as String? ?? DateTime.now().toIso8601String(),
      ),
      allowJob: _parseAllowJob(map['fields']),
    );
  }

  /// 转换为云端Map
  Map<String, dynamic> toClMap() {
    return {
      'id': id,
      'record_id': recordId,
      'fields': {
        '姓名': fullName,
        '手机号': phoneNumber,
        '密码': password,
        '注册时间': createdTime.toIso8601String().split('T').first,
        '登录时间': lastLoginTime.toIso8601String().split('T').first,
        ...allowJob,
      },
    };
  }

  /// 格式化字符串表示 - 向量化专用
  @override
  String toString() {
    // 构建权限描述
    final activeJobs = allowJob.entries
        .where((entry) => entry.value == 1)
        .map((entry) => entry.key)
        .join('、');
    
    return '用户信息：姓名：$fullName，手机号：$phoneNumber，注册时间：${createdTime.year}年${createdTime.month}月${createdTime.day}日，最后登录：${lastLoginTime.year}年${lastLoginTime.month}月${lastLoginTime.day}日，可用岗位：${activeJobs.isNotEmpty ? activeJobs : '无'}，当前岗位：${job ?? '未设置'}';
  }

  /// 生成向量化专用文本（更详细的语义描述）
  String toVectorText() {
    final activeJobs = allowJob.entries
        .where((entry) => entry.value == 1)
        .map((entry) => entry.key)
        .join('、');
    
    return '''
用户档案：
- 姓名：$fullName
- 联系方式：$phoneNumber  
- 注册时间：${createdTime.toLocal()}
- 最后登录：${lastLoginTime.toLocal()}
- 可用工作权限：${activeJobs.isNotEmpty ? activeJobs : '无'}
- 当前岗位：${job ?? '未分配'}
- 用户ID：${id ?? '新用户'}
- 记录ID：${recordId ?? '无'}
    '''.trim();
  }

  /// 比较两个用户实体是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.toString() == toString();
  }

  /// 生成哈希码
  @override
  int get hashCode {
    return Object.hash(
      fullName,
      phoneNumber,
      password,
      createdTime,
      lastLoginTime,
      allowJob,
    );
  }

  // 私有辅助方法：解析allowJob字段
  static Map<String, int> _parseAllowJob(dynamic map) {
    // 如果map是字符串，先解析为JSON对象
    if (map is String) {
      try {
        final decodedMap = jsonDecode(map);
        if (decodedMap is Map) {
          map = decodedMap;
        }
      } catch (e) {
        print('解析allowJob JSON字符串失败: $e');
        return {'流量端': 0, '承接端': 0, '直销端': 0, '转化端': 0, '数据端': 0};
      }
    }

    // 如果map不是Map类型，返回默认值
    if (map is! Map) {
      return {'流量端': 0, '承接端': 0, '直销端': 0, '转化端': 0, '数据端': 0};
    }

    Map<String, int> result = Map<String, int>.fromEntries(
      map.entries
          .where((entry) {
            final value = int.tryParse(entry.value.toString());
            return value == 0 || value == 1;
          })
          .map(
            (entry) => MapEntry(
              entry.key.toString(),
              int.tryParse(entry.value.toString()) ?? 0,
            ),
          ),
    );
    return result;
  }
}
