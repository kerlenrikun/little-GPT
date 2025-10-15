import 'dart:convert';
import 'dart:developer';
import 'package:star_claude/domain/entities/auth/user.dart';
import 'package:star_claude/data/repository/base_repository.dart';

/// 本地用户数据仓库 - 负责处理本地数据库中用户数据相关的操作
class DbUserRepository extends BaseRepository<UserEntity> {
  /// 构造函数
  DbUserRepository() : super('users');

  @override
  UserEntity fromDbMap(Map<String, dynamic> map) {
    return UserEntity.fromMap(map);
  }

  @override
  Map<String, dynamic> toDbMap(UserEntity entity) {
    return entity.toMap();
  }

  /// 注册用户信息到本地数据库
  Future<Map<String, dynamic>> registerUser(UserEntity user) async {
    try {
      final result = await addData(user);
      
      if (result['success'] == true) {
        return {
          'success': true,
          'message': '用户注册成功',
          'data': {
            'fullName': user.fullName,
            'phoneNumber': user.phoneNumber,
            'password': user.password,
            'createdTime': user.createdTime,
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

  /// 检查手机号是否已注册
  Future<bool> isPhoneNumberRegistered(String phoneNumber) async {
    try {
      final results = await queryData('phone_number = ?', [phoneNumber]);
      print('手机号存在: ${results.isNotEmpty}');
      return results.isNotEmpty;
    } catch (e) {
      print('检查手机号是否已注册时发生错误: $e');
      return false;
    }
  }

  /// 获取所有用户
  Future<List<UserEntity>> getAllUsers() async {
    return getAllData();
  }

  /// 用户登录
  Future<Map<String, dynamic>> loginUser(String phoneNumber, String password, String job) async {
    try {
      // 根据手机号查询用户
      final results = await queryData('phone_number = ?', [phoneNumber]);
      
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
      
      // 更新用户登录时间
      final updatedUser = user.copyWith(
        lastLoginTime: DateTime.now(),
        job: job,
      );
      
      final updateResult = await updateData(user.id, updatedUser);
      
      if (updateResult['success']) {
        return {
          'success': true,
          'message': '登录成功',
          'data': {
            'fullName': user.fullName,
            'phoneNumber': user.phoneNumber,
            'password': user.password,
            'createdTime': user.createdTime,
            'job': updatedUser.job,
          },
        };
      } else {
        return {
          'success': false,
          'message': '更新用户信息失败',
          'error': updateResult['message'],
        };
      }
    } catch (e) {
      print('登录过程中发生错误: $e');
      return {
        'success': false,
        'message': '登录过程中发生错误',
        'error': e.toString(),
      };
    }
  }

  /// 根据本地ID获取用户
  Future<UserEntity?> getUserById(int id) async {
    return getDataById(id);
  }

  /// 根据飞书record_id获取用户
  Future<UserEntity?> getUserByRecordId(String recordId) async {
    return getDataByRecordId(recordId);
  }

  /// 根据自定义条件查询用户记录
  Future<List<UserEntity>> queryUsers(String? whereClause, List<dynamic>? whereArgs) async {
    return queryData(whereClause, whereArgs);
  }

  /// 根据姓名查询用户
  Future<List<UserEntity>> getUsersByName(String name) async {
    return queryData('full_name LIKE ?', ['%$name%']);
  }

  /// 更新用户信息
  Future<Map<String, dynamic>> updateUserInfo(int id, UserEntity updatedUser) async {
    return updateData(id, updatedUser);
  }

  /// 删除用户
  Future<Map<String, dynamic>> deleteUser(int id) async {
    return deleteData(id);
  }

  /// 修改用户密码
  Future<Map<String, dynamic>> changePassword(int id, String oldPassword, String newPassword) async {
    try {
      // 先获取用户信息
      final user = await getUserById(id);
      
      if (user == null) {
        return {
          'success': false,
          'message': '用户不存在',
        };
      }
      
      // 验证旧密码
      if (user.password != oldPassword) {
        return {
          'success': false,
          'message': '旧密码错误',
        };
      }
      
      // 更新密码
      final updatedUser = user.copyWith(password: newPassword);
      return await updateData(id, updatedUser);
    } catch (e) {
      return {
        'success': false,
        'message': '修改密码过程中发生错误',
        'error': e.toString(),
      };
    }
  }
}