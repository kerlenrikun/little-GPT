import 'dart:convert';

// 账号数据实体类
class AccountDataEntity {
  // 数据库ID，自增
  final int? id;
  
  // 记录ID
  final String? recordId;
  
  // 账号实名人
  final String accountRealName;
  
  // 持号承接端
  final String accountHandler;
  
  // wx号
  final String wechatId;
  
  // 负荷状态 - '可接流' 或 '不可接流'
  final String loadStatus;
  
  // 流量端 - 格式为 'name1-name2-name3...'
  final String trafficSources;

  // 构造函数
  AccountDataEntity({
    this.id,
    this.recordId,
    required this.accountRealName,
    required this.accountHandler,
    required this.wechatId,
    this.loadStatus = '可接流',
    this.trafficSources = '',
  });

  // 创建副本，用于更新实体属性
  AccountDataEntity copyWith({
    int? id,
    String? recordId,
    String? accountRealName,
    String? accountHandler,
    String? wechatId,
    String? loadStatus,
    String? trafficSources,
  }) {
    return AccountDataEntity(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      accountRealName: accountRealName ?? this.accountRealName,
      accountHandler: accountHandler ?? this.accountHandler,
      wechatId: wechatId ?? this.wechatId,
      loadStatus: loadStatus ?? this.loadStatus,
      trafficSources: trafficSources ?? this.trafficSources,
    );
  }

  // 转换为JSON字符串
  String toJson() {
    return jsonEncode({
      'id': id,
      'recordId': recordId,
      'accountRealName': accountRealName,
      'accountHandler': accountHandler,
      'wechatId': wechatId,
      'loadStatus': loadStatus,
      'trafficSources': trafficSources,
    });
  }

  // 从JSON字符串创建实体
  factory AccountDataEntity.fromJson(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return AccountDataEntity(
      id: map['id'] as int?,
      recordId: map['recordId'] as String?,
      accountRealName: map['accountRealName'] as String? ?? '',
      accountHandler: map['accountHandler'] as String? ?? '',
      wechatId: map['wechatId'] as String? ?? '',
      loadStatus: map['loadStatus'] as String? ?? '可接流',
      trafficSources: map['trafficSources'] as String? ?? '',
    );
  }

  // 从数据库Map转换为实体
  factory AccountDataEntity.fromMap(Map<String, dynamic> map) {
    return AccountDataEntity(
      id: map['id'] as int?,
      recordId: map['record_id'] as String?,
      accountRealName: map['account_real_name'] as String? ?? '',
      accountHandler: map['account_handler'] as String? ?? '',
      wechatId: map['wechat_id'] as String? ?? '',
      loadStatus: map['load_status'] as String? ?? '可接流',
      trafficSources: map['traffic_sources'] as String? ?? '',
    );
  }

  // 转换为数据库Map
  Map<String, dynamic> toMap() {
    return {
      'record_id': recordId,
      'account_real_name': accountRealName,
      'account_handler': accountHandler,
      'wechat_id': wechatId,
      'load_status': loadStatus,
      'traffic_sources': trafficSources,
    };
  }

  // 从飞书Map转换为实体
  factory AccountDataEntity.fromFeishuMap(Map<String, dynamic> map) {
    return AccountDataEntity(
      recordId: map['record_id'] as String?,
      accountRealName: map['fields']['账号实名人'] as String? ?? '',
      accountHandler: map['fields']['持号承接端'] as String? ?? '',
      wechatId: map['fields']['wx号'] as String? ?? '',
      loadStatus: map['fields']['负荷状态'] as String? ?? '可接流',
      trafficSources: map['fields']['流量端'] as String? ?? '',
    );
  }

  // 转换为飞书Map
  Map<String, dynamic> toFeishuMap() {
    return {
      'id': id,
      'record_id': recordId,
      'fields': {
        '账号实名人': accountRealName,
        '持号承接端': accountHandler,
        'wx号': wechatId,
        '负荷状态': loadStatus,
        '流量端': trafficSources,
      },
    };
  }

  // 检查是否可以接流
  bool get canAcceptTraffic => loadStatus == '可接流';

  // 获取流量端列表
  List<String> get trafficSourcesList {
    if (trafficSources.isEmpty) {
      return [];
    }
    return trafficSources.split('-');
  }

  // 检查用户是否在当前流量端中
  bool isUserInTrafficSources(String userName) {
    return trafficSourcesList.contains(userName);
  }

  // 添加流量端
  AccountDataEntity addTrafficSource(String userName) {
    print(trafficSourcesList);
    if (isUserInTrafficSources(userName)) {
      return this; // 用户已在流量端中，无需添加
    }
    
    final newTrafficSources = trafficSources.isEmpty
        ? userName
        : '$trafficSources-$userName';
    
    return copyWith(trafficSources: newTrafficSources);
  }

  // 移除流量端
  AccountDataEntity removeTrafficSource(String userName) {
    
    if (!isUserInTrafficSources(userName)) {
      return this;
    }
    
    final newSourcesList = trafficSourcesList
        .where((source) => source != userName)
        .toList();
    
    final newTrafficSources = newSourcesList.join('-');
    
    return copyWith(trafficSources: newTrafficSources);
  }

  // 清空流量端
  AccountDataEntity clearTrafficSources() {
    return copyWith(trafficSources: '');
  }

  // 设置为不可接流状态（同时清空流量端）
  AccountDataEntity setToUnavailable() {
    return copyWith(
      loadStatus: '不可接流',
      trafficSources: '',
    );
  }

  // 设置为可接流状态
  AccountDataEntity setToAvailable() {
    return copyWith(loadStatus: '可接流');
  }

  @override
  String toString() {
    return 'AccountDataEntity(recordId: $recordId, accountRealName: $accountRealName, accountHandler: $accountHandler, loadStatus: $loadStatus, trafficSources: $trafficSources)';
  }
}