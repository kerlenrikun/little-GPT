// 飞书多维表格配置类
class FeishuConfig {
  // 飞书开放平台应用配置
  static const String appId = 'cli_a8465bc6b0ff500b';
  static const String appSecret = 'LE9HY48ZsSGDxyaSOX8o7eMMdBNzDTN3';

  // 基础API配置
  static const String baseApiUrl = 'https://open.feishu.cn/open-apis';

  // 表格配置 - 应用内所有数据表的配置集合
  static final Map<String, FeishuTableConfig> tables = {
    // 用户表配置
    'users': FeishuTableConfig(
      baseUrl: 'https://ecnas327e0p0.feishu.cn/base/Eq2QbQd8GadLUxslEc4c9VDPnzg',
      tableId: 'tblgi7vdCzX5agp9',
      viewId: 'vewy352eFk',
    ),
    
    // 成功数据表配置
    'succData': FeishuTableConfig(
      baseUrl: 'https://ecnas327e0p0.feishu.cn/base/RdjUbTOZBasYlAsD5IZcJFrwnqg',
      tableId: 'tblNDRS778EFeQf5', // 可以是同一个多维表格中的不同数据表
      viewId: 'vew5Dm09Vs',
    ),
    
    // 可以根据需要添加更多的数据表配置
    'commonData': FeishuTableConfig(
      baseUrl: 'https://ecnas327e0p0.feishu.cn/base/Pm5JbLDvAaerT3seHOKcKJscn9b',
      tableId: 'tblWxeC9SABXh7QC',
      viewId: 'vewtkycqiN',
    ),
    
    // 账号数据表配置
    'accountData': FeishuTableConfig(
      baseUrl: 'https://ecnas327e0p0.feishu.cn/base/ENCwbz1xdaeHLisVcoOcQnzanXc',
      tableId: 'tblIsT008N5LZ55l',
      viewId: 'vewdhTUFyI',
    ),
  };

  // 获取指定表的完整URL
  static String getTableUrl(String tableKey) {
    final tableConfig = tables[tableKey];
    if (tableConfig == null) return '';
    
    return '${tableConfig.baseUrl}?table=${tableConfig.tableId}${tableConfig.viewId.isNotEmpty ? '&view=${tableConfig.viewId}' : ''}';
  }

  // 从基础URL中提取appToken
  static String getAppTokenFromBaseUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final pathSegments = uri.pathSegments;
    // URL格式: https://example.feishu.cn/base/{appToken}
    if (pathSegments.length >= 2 && pathSegments[0] == 'base') {
      return pathSegments[1];
    }
    return '';
  }

  // 获取指定表的appToken
  static String getAppToken(String tableKey) {
    final tableConfig = tables[tableKey];
    if (tableConfig == null) return '';
    return getAppTokenFromBaseUrl(tableConfig.baseUrl);
  }

  // 获取指定表的tableId
  static String getTableId(String tableKey) {
    final tableConfig = tables[tableKey];
    return tableConfig?.tableId ?? '';
  }

  // 获取指定表的viewId
  static String getViewId(String tableKey) {
    final tableConfig = tables[tableKey];
    return tableConfig?.viewId ?? '';
  }

  // 验证指定表配置是否完整
  static bool isTableConfigValid(String tableKey) {
    final tableConfig = tables[tableKey];
    if (tableConfig == null) return false;
    final appToken = getAppTokenFromBaseUrl(tableConfig.baseUrl);
    return tableConfig.baseUrl.isNotEmpty &&
           tableConfig.tableId.isNotEmpty &&
           appToken.isNotEmpty;
  }

  // 验证全局配置是否完整
  static bool get isConfigValid {
    bool appIdValid = appId.isNotEmpty && appId != 'YOUR_APP_ID_HERE';
    bool appSecretValid = appSecret.isNotEmpty && appSecret != 'YOUR_APP_SECRET_HERE';
    bool tablesValid = tables.isNotEmpty;
    
    if (!appIdValid) {
      print('飞书配置验证失败：appId 为空或未替换默认值');
    }
    if (!appSecretValid) {
      print('飞书配置验证失败：appSecret 为空或未替换默认值');
    }
    if (!tablesValid) {
      print('飞书配置验证失败：表格配置为空');
    }
    
    final isValid = appIdValid && appSecretValid && tablesValid;
    return isValid;
  }

  // 获取配置说明
  static String get configInstructions {
    return '''
飞书多维表格配置说明：

请提供以下信息：

1. App ID:
   - 在飞书开放平台"凭证与基础信息"中获取

2. App Secret:
   - 在飞书开放平台"凭证与基础信息"中获取

3. 表格配置：
   - baseUrl: 多维表格的基础URL (如：https://example.feishu.cn/base/{appToken})
   - tableId: 数据表ID (从URL的table参数获取)
   - viewId: 视图ID (可选，从URL的view参数获取)

配置示例：
- App ID: cli_xxxxxxxxxxxx
- App Secret: xxxxxxxxxxxxxxxxxxxx  
- 表格配置: 在tables映射中添加各数据表的配置

请将上述信息替换到对应的常量中。
''';
  }
}

/// 飞书数据表配置类
class FeishuTableConfig {
  final String baseUrl; // 多维表格基础URL
  final String tableId; // 数据表ID
  final String viewId; // 视图ID（可选）

  const FeishuTableConfig({
    required this.baseUrl,
    required this.tableId,
    this.viewId = '',
  });

  // 从完整URL创建表格配置
  factory FeishuTableConfig.fromUrl(String tableUrl) {
    final uri = Uri.parse(tableUrl);
    final pathSegments = uri.pathSegments;
    
    // 构建基础URL (不含查询参数)
    String baseUrl = '${uri.scheme}://${uri.host}';
    for (int i = 0; i < pathSegments.length; i++) {
      baseUrl += '/${pathSegments[i]}';
    }
    
    return FeishuTableConfig(
      baseUrl: baseUrl,
      tableId: uri.queryParameters['table'] ?? '',
      viewId: uri.queryParameters['view'] ?? '',
    );
  }

  // 获取完整的表格URL
  String get fullUrl {
    return '$baseUrl?table=$tableId${viewId.isNotEmpty ? '&view=$viewId' : ''}';
  }

  // 提取appToken
  String get appToken {
    final uri = Uri.parse(baseUrl);
    final pathSegments = uri.pathSegments;
    if (pathSegments.length >= 2 && pathSegments[0] == 'base') {
      return pathSegments[1];
    }
    return '';
  }
}