import 'package:ssr/domain/entity/user.dart';
import 'package:ssr/domain/repository/base_repository.dart';

class UserRepository extends BaseRepository<UserEntity> {
  UserRepository() : super('users');

  @override
  UserEntity fromFeishuMap(Map<String, dynamic> map) {
    return UserEntity.fromFeishuMap(map);
  }

  @override
  Map<String, dynamic> toFeishuMap(UserEntity entity) {
    return entity.toFeishuMap();
  }
  // 当前用户信息同步
  /// 用户信息
  // 注册用户信息到飞书
  Future<Map<String, dynamic>> registerUser(UserEntity user) async {
    try {
      final result = await addData(user);
      
      if (result['success'] == true) {
        // 登入

        // 将用户信息转换为Map格式返回
      return {
        'success': true,
        'message': '用户注册成功',
        'data': {
          'fullName': user.fullName,
          'phoneNumber': user.phoneNumber,
          'password': user.password,
          'createdTime': user.createdTime.toIso8601String(),
        },
      };
      } else {
        return {
          'success': false,
          'message': '注册失败: ${result['message']}',
          'error': result['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '注册过程中发生错误',
        'error': e.toString(),
      };
    }
  }
  
  // 检查手机号是否已注册
  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      final results = await queryData('CurrentValue.[手机号] = "$phoneNumber"');
      print('手机号存在: ${results.isNotEmpty}');
      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // 获取所有用户
  Future<List<UserEntity>> getAllUsers() async {
    return getAllData();
  }
  
  // 用户登录
  Future<Map<String, dynamic>> loginUser(String phoneNumber, String password, String job) async {
    try {
      // 根据手机号查询用户
      final results = await queryData('CurrentValue.[手机号] = "$phoneNumber"');
      
      // 检查用户是否存在
      if (results.isEmpty) {
        return {
          'success': false,
          'message': '用户不存在',
          'error': '未找到该手机号对应的用户',
        };
      }
      
      // 找到用户记录
      final user = results.first;
      
      // 验证密码
      if (user.password != password) {
        return {
          'success': false,
          'message': '密码错误',
          'error': '密码不匹配',
        };
      }
      
      // 验证岗位是否在允许的列表中，且对应值是否为1
      if (!user.allowJob.containsKey(job) || user.allowJob[job] != 1) {
        return {
          'success': false,
          'message': '岗位不允许',
          'error': '该岗位不在用户允许的岗位列表中或未被允许',
        };
      }
      
      // 检查recordId是否为空
      if (user.recordId == null) {
        return {
          'success': false,
          'message': '用户记录ID为空，无法更新岗位信息',
          'error': '记录ID为空',
        };
      }
      
      // 更新用户岗位信息
      final updatedUser = user.copyWith(job: job);
      await updateData(user.recordId!, updatedUser);
      
      return {
        'success': true,
        'message': '登录成功',
        'entity':updatedUser,
        'data': {
          'fullName': user.fullName,
          'phoneNumber': user.phoneNumber,
          'password': user.password,
          'createdTime': user.createdTime.toIso8601String(),
          'job': updatedUser.job,
        },
      };
    } catch (e) {
      print('登录过程中发生错误: $e');
      return {
        'success': false,
        'message': '登录过程中发生错误',
        'error': e.toString(),
      };
    }
  }
  
  // 根据ID获取用户
  Future<UserEntity?> getUserById(String recordId) async {
    final results = await getDataById(recordId);
    return results;
  }

  // 根据自定义过滤器查询成功数据记录
  /// 返回[UserEntity]对象列表
  Future<List<UserEntity>> queryUsers(String filter) async {
    return queryData(filter);
  }
}