import 'dart:convert';
import '../entities/data/account_data.dart';
import 'package:star_claude/domain/repository/base_repository.dart';

// 账号数据仓库类 - 实现与飞书API的交互逻辑
class AccountDataRepository extends BaseRepository<AccountDataEntity> {
  // 构造函数
  AccountDataRepository() : super('accountData');
  
  @override
  AccountDataEntity fromFeishuMap(Map<String, dynamic> map) {
    return AccountDataEntity.fromFeishuMap(map);
  }

  @override
  Map<String, dynamic> toFeishuMap(AccountDataEntity entity) {
    return entity.toFeishuMap();
  }

  // 获取所有账号数据
  Future<List<AccountDataEntity>> getAllAccounts() async {
    return getAllData();
  }

  // 根据承接端查询账号数据
  Future<List<AccountDataEntity>> getAccountsByHandler(String handlerName) async {
    // 使用飞书filter语法构建查询条件
    final filter = 'CurrentValue.[持号承接端] = "$handlerName"';
    return queryData(filter);
  }

  // 获取可接流的账号数据
  Future<List<AccountDataEntity>> getAvailableAccounts() async {
    // 使用飞书filter语法构建查询条件
    final filter = 'CurrentValue.[负荷状态] = "可接流"';
    return queryData(filter);
  }

  // 根据recordId获取单个账号数据
  Future<AccountDataEntity?> getAccountById(String recordId) async {
    return getDataById(recordId);
  }

  // 添加新账号数据
  Future<Map<String, dynamic>> addAccountDataRecord(AccountDataEntity account) async {
    return addData(account);
  }

  // 更新账号条目
  Future<Map<String, dynamic>> updateAccountDataRecord(AccountDataEntity account) async {
    if (account.recordId == null || account.recordId!.isEmpty) {
      return {
        'success': false,
        'message': '记录ID为空，无法更新',
      };
    }
    return updateData(account.recordId!, account);
  }

  // 更新账号负荷状态
  Future<AccountDataEntity?> updateAccountLoadStatus(
      String recordId, 
      String loadStatus, 
      {String? trafficSources}
  ) async {
    // 先获取当前账号数据
    final account = await getAccountById(recordId);
    
    // 检查账号是否存在
    if (account == null) {
      throw Exception('未找到指定的账号数据');
    }
    
    // 创建更新后的实体
    final updatedAccount = account.copyWith(
      loadStatus: loadStatus,
      trafficSources: trafficSources ?? account.trafficSources,
    );
    
    // 更新数据
    final result = await updateData(recordId, updatedAccount);
    
    if (result['success']) {
      return await getAccountById(recordId);
    } else {
      throw Exception('更新账号负荷状态失败: ${result['message']}');
    }
  }

  // 为账号添加流量端
  Future<AccountDataEntity?> addTrafficSourceToAccount(
      String recordId, 
      String trafficSources,
      String userName,
  ) async {
    // 先获取当前账号数据
    final account = await getAccountById(recordId);
    
    // 检查账号是否存在
    if (account == null) {
      throw Exception('未找到指定的账号数据');
    }
    
    // 检查账号是否可接流
    if (!account.canAcceptTraffic) {
      throw Exception('账号当前不可接流，无法添加流量端');
    }
    
    // 创建更新后的实体
    final updatedAccount = account.copyWith(
      trafficSources: trafficSources.isEmpty ? userName : '$trafficSources-$userName',
    );
    
    // 更新数据
    final result = await updateData(recordId, updatedAccount);
    
    if (result['success']) {
      return await getAccountById(recordId);
    } else {
      throw Exception('添加流量端失败: ${result['message']}');
    }
  }

  // 从账号移除流量端
  Future<AccountDataEntity?> removeTrafficSourceFromAccount(
      String recordId, 
      String trafficSources,
      String userName,
    ) async {
      List<String> names = trafficSources.split('-');
      List<String> filteredNames = names.where((name) => name != userName).toList();
      String newString = filteredNames.join('-');
    
      // 先获取当前账号数据
      final account = await getAccountById(recordId);
      
      // 检查账号是否存在
      if (account == null) {
        throw Exception('未找到指定的账号数据');
      }
      
      // 创建更新后的实体
      final updatedAccount = account.copyWith(
        trafficSources: newString,
      );
      
      // 更新数据
      final result = await updateData(recordId, updatedAccount);
      
      if (result['success']) {
        return await getAccountById(recordId);
      } else {
        throw Exception('移除流量端失败: ${result['message']}');
      }
  }

  // 清空账号流量端
  Future<AccountDataEntity?> clearTrafficSources(String recordId) async {
    // 先获取当前账号数据
    final account = await getAccountById(recordId);
    
    // 检查账号是否存在
    if (account == null) {
      throw Exception('未找到指定的账号数据');
    }
    
    // 创建更新后的实体
    final updatedAccount = account.copyWith(trafficSources: '');
    
    // 更新数据
    final result = await updateData(recordId, updatedAccount);
    
    if (result['success']) {
      return await getAccountById(recordId);
    } else {
      throw Exception('清空流量端失败: ${result['message']}');
    }
  }

  // 删除账号记录
  Future<Map<String, dynamic>> deleteAccountDataRecord(AccountDataEntity account) async {
    if (account.recordId == null || account.recordId!.isEmpty) {
      return {
        'success': false,
        'message': '记录ID为空，无法删除',
      };
    }
    return deleteData(account.recordId!);
  }

  // 更新账号为不可接流状态（同时清空流量端）
  Future<AccountDataEntity?> setAccountToUnavailable(String recordId) async {
    // 先获取当前账号数据
    final account = await getAccountById(recordId);
    
    // 检查账号是否存在
    if (account == null) {
      throw Exception('未找到指定的账号数据');
    }
    
    // 创建更新后的实体
    final updatedAccount = account.copyWith(
      loadStatus: '不可接流',
      trafficSources: '', // 同时清空流量端
    );
    
    // 更新数据
    final result = await updateData(recordId, updatedAccount);
    
    if (result['success']) {
      return await getAccountById(recordId);
    } else {
      throw Exception('更新账号状态失败: ${result['message']}');
    }
  }

  // 更新账号为可接流状态
  Future<AccountDataEntity?> setAccountToAvailable(String recordId) async {
    // 先获取当前账号数据
    final account = await getAccountById(recordId);
    
    // 检查账号是否存在
    if (account == null) {
      throw Exception('未找到指定的账号数据');
    }
    
    // 创建更新后的实体
    final updatedAccount = account.copyWith(loadStatus: '可接流');
    
    // 更新数据
    final result = await updateData(recordId, updatedAccount);
    
    if (result['success']) {
      return await getAccountById(recordId);
    } else {
      throw Exception('更新账号状态失败: ${result['message']}');
    }
  }
}
