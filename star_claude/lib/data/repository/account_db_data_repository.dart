import 'package:star_claude/domain/entities/data/account_data.dart';
import 'package:star_claude/data/repository/base_repository.dart';

/// 本地账号数据仓库 - 负责处理本地数据库中账号数据相关的操作
class AccountDbDataRepository extends BaseRepository<AccountDataEntity> {
  /// 构造函数
  AccountDbDataRepository() : super('account_data');

  @override
  AccountDataEntity fromDbMap(Map<String, dynamic> map) {
    return AccountDataEntity.fromMap(map);
  }

  @override
  Map<String, dynamic> toDbMap(AccountDataEntity entity) {
    return entity.toMap();
  }

  /// 获取所有账号数据
  Future<List<AccountDataEntity>> getAllAccounts() async {
    return getAllData();
  }

  /// 根据承接端查询账号数据
  Future<List<AccountDataEntity>> getAccountsByHandler(String handlerName) async {
    return queryData('account_handler = ?', [handlerName]);
  }

  /// 获取可接流的账号数据
  Future<List<AccountDataEntity>> getAvailableAccounts() async {
    return queryData('load_status = ?', ['可接流']);
  }

  /// 根据本地ID获取单个账号数据
  Future<AccountDataEntity?> getAccountById(int id) async {
    return getDataById(id);
  }

  /// 根据飞书record_id获取单个账号数据
  Future<AccountDataEntity?> getAccountByRecordId(String recordId) async {
    return getDataByRecordId(recordId);
  }

  /// 添加新账号数据
  Future<Map<String, dynamic>> addAccountDataRecord(AccountDataEntity account) async {
    return addData(account);
  }

  /// 更新账号条目
  Future<Map<String, dynamic>> updateAccountDataRecord(int? id, AccountDataEntity account) async {
    return updateData(id, account);
  }

  /// 更新账号负荷状态
  Future<AccountDataEntity?> updateAccountLoadStatus(
      int id,
      String loadStatus,
      {String? trafficSources}
  ) async {
    // 先获取当前账号数据
    final account = await getAccountById(id);
    
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
    final result = await updateData(id, updatedAccount);
    
    if (result['success']) {
      return await getAccountById(id);
    } else {
      throw Exception('更新账号负荷状态失败: ${result['message']}');
    }
  }

  /// 为账号添加流量端
  Future<AccountDataEntity?> addTrafficSourceToAccount(
      int id,
      String trafficSources,
      String userName,
  ) async {
    // 先获取当前账号数据
    final account = await getAccountById(id);
    
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
    final result = await updateData(id, updatedAccount);
    
    if (result['success']) {
      return await getAccountById(id);
    } else {
      throw Exception('添加流量端失败: ${result['message']}');
    }
  }

  /// 从账号移除流量端
  Future<AccountDataEntity?> removeTrafficSourceFromAccount(
      int id,
      String trafficSources,
      String userName,
    ) async {
      List<String> names = trafficSources.split('-');
      List<String> filteredNames = names.where((name) => name != userName).toList();
      String newString = filteredNames.join('-');
    
      // 先获取当前账号数据
      final account = await getAccountById(id);
      
      // 检查账号是否存在
      if (account == null) {
        throw Exception('未找到指定的账号数据');
      }
      
      // 创建更新后的实体
      final updatedAccount = account.copyWith(
        trafficSources: newString,
      );
      
      // 更新数据
      final result = await updateData(id, updatedAccount);
      
      if (result['success']) {
        return await getAccountById(id);
      } else {
        throw Exception('移除流量端失败: ${result['message']}');
      }
  }

  /// 清空账号流量端
  Future<AccountDataEntity?> clearTrafficSources(int id) async {
    // 先获取当前账号数据
    final account = await getAccountById(id);
    
    // 检查账号是否存在
    if (account == null) {
      throw Exception('未找到指定的账号数据');
    }
    
    // 创建更新后的实体
    final updatedAccount = account.copyWith(trafficSources: '');
    
    // 更新数据
    final result = await updateData(id, updatedAccount);
    
    if (result['success']) {
      return await getAccountById(id);
    } else {
      throw Exception('清空流量端失败: ${result['message']}');
    }
  }

  /// 删除账号记录
  Future<Map<String, dynamic>> deleteAccountDataRecord(int? id) async {
    return deleteData(id);
  }

  /// 更新账号为不可接流状态（同时清空流量端）
  Future<AccountDataEntity?> setAccountToUnavailable(int id) async {
    // 先获取当前账号数据
    final account = await getAccountById(id);
    
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
    final result = await updateData(id, updatedAccount);
    
    if (result['success']) {
      return await getAccountById(id);
    } else {
      throw Exception('更新账号状态失败: ${result['message']}');
    }
  }

  /// 更新账号为可接流状态
  Future<AccountDataEntity?> setAccountToAvailable(int id) async {
    // 先获取当前账号数据
    final account = await getAccountById(id);
    
    // 检查账号是否存在
    if (account == null) {
      throw Exception('未找到指定的账号数据');
    }
    
    // 创建更新后的实体
    final updatedAccount = account.copyWith(loadStatus: '可接流');
    
    // 更新数据
    final result = await updateData(id, updatedAccount);
    
    if (result['success']) {
      return await getAccountById(id);
    } else {
      throw Exception('更新账号状态失败: ${result['message']}');
    }
  }

  /// 根据实名人查询账号数据
  Future<List<AccountDataEntity>> getAccountsByRealName(String realName) async {
    return queryData('account_real_name = ?', [realName]);
  }

  /// 根据微信号查询账号数据
  Future<AccountDataEntity?> getAccountByWechatId(String wechatId) async {
    final results = await queryData('wechat_id = ?', [wechatId]);
    return results.isNotEmpty ? results.first : null;
  }
}