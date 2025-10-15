# 飞书多维表格集成指南

## 🎯 功能概述

本指南详细说明如何将star_claude应用的注册页面与飞书多维表格进行集成，实现用户注册数据的自动存储。

## 📋 前置条件

1. **飞书开放平台账号**
2. **已创建的多维表格**
3. **Flutter开发环境**

## 🛠️ 配置步骤

### 1. 获取飞书API凭证

#### 获取 App Token
1. 登录[飞书开放平台](https://open.feishu.cn/)
2. 进入你的应用管理页面
3. 在"凭证与基础信息"中获取 App ID

#### 获取 Personal Base Token
1. 打开你的飞书多维表格
2. 点击右上角"..." -> "生成API token"
3. 复制生成的token

#### 获取 Table ID
1. 打开你的多维表格
2. 在浏览器地址栏中查看URL，格式类似：
   `https://example.feishu.cn/base/{appToken}?table={tableId}`
3. 复制 `{tableId}` 部分

### 2. 配置应用信息

打开 `lib/core/configs/feishu_config.dart` 文件，替换以下常量：

```dart
static const String appToken = '你的AppToken';
static const String personalBaseToken = '你的PersonalBaseToken';
static const String tableId = '你的TableId';
```

### 3. 创建多维表格结构

在你的飞书多维表格中创建以下字段：

| 字段名 | 类型 | 说明 |
|--------|------|------|
| 姓名 | 文本 | 用户全名 |
| 手机号 | 文本 | 用户手机号码 |
| 密码 | 文本 | 用户密码（建议加密存储） |
| 注册时间 | 日期时间 | 用户注册时间 |

### 4. 运行应用

```bash
flutter pub get
flutter run
```

## 📁 文件结构

```
lib/
├── data/
│   ├── models/
│   │   └── user_model.dart          # 用户数据模型
│   ├── repository/
│   │   └── user_repository.dart     # 用户仓库
│   └── sources/
│       └── feishu_api_service.dart  # 飞书API服务
├── core/
│   └── configs/
│       └── feishu_config.dart      # 飞书配置
└── presentation/
    └── auth/
        └── pages/
            └── signup.dart          # 注册页面（已集成）
```

## 🔧 核心功能

### 1. 用户注册
- 收集用户信息（姓名、手机号、密码）
- 验证手机号是否已注册
- 将数据存储到飞书多维表格
- 提供实时反馈和错误处理

### 2. 数据查询
- 支持按手机号查询用户
- 支持批量查询所有用户
- 支持条件过滤和排序

### 3. 错误处理
- 网络请求异常处理
- API响应错误处理
- 用户输入验证

## 🚀 使用示例

### 基本注册
```dart
final user = UserModel(
  fullName: '张三',
  phoneNumber: '13800138000', 
  password: 'password123',
);

final result = await userRepository.registerUser(user);
if (result['success']) {
  print('注册成功');
} else {
  print('注册失败: ${result['message']}');
}
```

### 检查手机号
```dart
final isRegistered = await userRepository.isPhoneNumberRegistered('13800138000');
print('手机号已注册: $isRegistered');
```

## ⚠️ 注意事项

1. **安全性**：在实际生产环境中，密码应该加密存储
2. **网络连接**：确保设备有稳定的网络连接
3. **API限制**：注意飞书API的调用频率限制
4. **错误处理**：妥善处理各种异常情况
5. **用户体验**：提供适当的加载状态和反馈

## 🔍 故障排除

### 常见问题

1. **HTTP 401错误**：检查API token是否正确
2. **HTTP 403错误**：检查应用权限设置
3. **HTTP 404错误**：检查appToken和tableId是否正确
4. **网络连接错误**：检查设备网络连接

### 调试建议

1. 启用Flutter的调试模式
2. 查看控制台输出的详细错误信息
3. 使用Postman测试飞书API接口
4. 检查飞书开放平台的API调用日志

## 📈 扩展功能

### 批量操作
支持批量注册用户和批量查询用户信息

### 数据同步
可以实现本地缓存和远程同步机制

### 统计分析
基于多维表格的数据进行用户行为分析

## 📞 支持

如遇到问题，请参考：
- [飞书开放平台文档](https://open.feishu.cn/document/ukTMukTMukTM/uETMzUjLxEzM14SMxMTN)
- [Flutter HTTP文档](https://pub.dev/packages/http)
- [多维表格API文档](https://open.feishu.cn/document/server-docs/docs/bitable-v1)

## 📄 许可证

本项目采用MIT许可证。