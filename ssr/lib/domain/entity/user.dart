import 'dart:convert';

/// 用户实体类 - 定义用户数据结构和操作
/// 用于表示和处理用户相关信息
class UserEntity {
  // 核心用户属性
  final String userUid; // 唯一ID
  final String userId; // 登录ID
  final String userName; // 用户全名
  final String permissions; // 权限
  final String department; // 部门
  final String entryTime; // 入职时间
  final String profilePhotoUrl; // 头像URL
  final String token; // 登录令牌
  final bool fullTimeJob; // 是否全职
  final bool isVip; // 是否会员

  /// 构造函数 - 创建用户实体实例
  UserEntity({
    required this.userUid,
    required this.userId,
    required this.userName,
    required this.permissions,
    required this.department,
    required this.entryTime,
    required this.profilePhotoUrl,
    required this.token,
    required this.fullTimeJob,
    required this.isVip,
  });

  /// 创建一个新的用户实体，仅修改指定的属性
  /// 方便在不改变原有实体的情况下更新部分属性
  UserEntity copyWith({
    String? userUid,
    String? userId,
    String? userName,
    String? permissions,
    String? department,
    String? entryTime,
    String? profilePhotoUrl,
    bool? fullTimeJob,
    bool? isVip,
  }) {
    return UserEntity(
      userUid: userUid ?? this.userUid,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      permissions: permissions ?? this.permissions,
      department: department ?? this.department,
      entryTime: entryTime ?? this.entryTime,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      token: token ?? this.token,
      fullTimeJob: fullTimeJob ?? this.fullTimeJob,
      isVip: isVip ?? this.isVip,
    );
  }

  /// 从数据库Map转换为UserEntity
  factory UserEntity.fromLoMap(Map<String, dynamic> map) {
    return UserEntity(
      userUid: map['user_uid'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      userName: map['user_name'] as String? ?? '',
      permissions: map['permissions'] as String? ?? '',
      department: map['department'] as String? ?? '',
      entryTime: map['entry_time'] as String? ?? '',
      profilePhotoUrl: map['profile_photo_url'] as String? ?? '',
      token: map['token'] as String? ?? '',
      fullTimeJob: map['full_time_job'] as bool? ?? false,
      isVip: map['is_vip'] as bool? ?? false,
    );
  }

  /// 转换为数据库Map
  Map<String, dynamic> toLoMap() {
    return {
      'user_uid': userUid,
      'user_openid': userId,
      'user_name': userName,
      'permissions': permissions,
      'department': department,
      'entry_time': entryTime,
      'profile_photo_url': profilePhotoUrl,
      'token': token,
      'full_time_job': fullTimeJob,
      'is_vip': isVip,
    };
  }

  /// 从云端Map转换为UserEntity
  factory UserEntity.fromClMap(Map<String, dynamic> map) {
    return UserEntity(
      userUid: map['user_data']['user_uid'] as String? ?? '',
      userId: map['user_data']['user_openid'] as String? ?? '',
      userName: map['user_data']['user_name'] as String? ?? '',
      permissions: map['user_data']['permissions'] as String? ?? '',
      department: map['user_data']['department'] as String? ?? '',
      entryTime: map['user_data']['entry_time'] as String? ?? '',
      profilePhotoUrl: map['user_data']['profile_photo_url'] as String? ?? '',
      token: map['token'] as String? ?? '',
      fullTimeJob: map['user_data']['full_time_job'] as bool? ?? false,
      isVip: map['user_data']['is_vip'] as bool? ?? false,
    );
  }

  /// 转换为云端Map
  Map<String, dynamic> toClMap() {
    return {
      'fields': {
        '唯一ID': userUid,
        '登录ID': userId,
        '用户全名': userName,
        '权限': permissions,
        '部门': department,
        '入职时间': entryTime,
        '头像URL': profilePhotoUrl,
        '是否全职': fullTimeJob,
        '是否会员': isVip,
      },
    };
  }

  /// 格式化字符串表示 - 向量化专用
  @override
  String toString() {
    return '用户信息：ID：$userUid，登录名：$userId，姓名：$userName，部门：$department，权限：$permissions，入职时间：$entryTime，全职：${fullTimeJob ? '是' : '否'}，会员：${isVip ? '是' : '否'}';
  }

  /// 生成向量化专用文本（更详细的语义描述）
  String toVectorText() {
    return '''
用户档案：
- 唯一ID：$userUid
- 登录ID：$userId
- 用户全名：$userName
- 权限：$permissions
- 部门：$department
- 入职时间：$entryTime
- 头像URL：$profilePhotoUrl
- 是否全职：${fullTimeJob ? '是' : '否'}
- 是否会员：${isVip ? '是' : '否'}
    '''
        .trim();
  }

  /// 比较两个用户实体是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.userUid == userUid &&
        other.userId == userId &&
        other.userName == userName &&
        other.permissions == permissions &&
        other.department == department &&
        other.entryTime == entryTime &&
        other.profilePhotoUrl == profilePhotoUrl &&
        other.fullTimeJob == fullTimeJob &&
        other.isVip == isVip;
  }

  /// 生成哈希码
  @override
  int get hashCode {
    return Object.hash(
      userUid,
      userId,
      userName,
      permissions,
      department,
      entryTime,
      profilePhotoUrl,
      fullTimeJob,
      isVip,
    );
  }
}
