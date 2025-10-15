import 'package:ssr/domain/entity/user.dart';
import 'package:ssr/domain/repository/repository.dart';

class UserRepository extends Repository<UserEntity> {
  UserRepository() : super('users','users');

  @override
  UserEntity fromClMap(Map<String, dynamic> map) {
    return UserEntity.fromClMap(map);
  }

  @override
  Map<String, dynamic> toClMap(UserEntity entity) {
    return entity.toClMap();
  }

  @override
  UserEntity fromLoMap(Map<String, dynamic> map) {
    return UserEntity.fromLoMap(map);
  }

  @override
  Map<String, dynamic> toLoMap(UserEntity entity) {
    return entity.toLoMap();
  }

  // 注册用户信息到云端
  Future<Map<String, dynamic>> registerUser(UserEntity user) async {
    try {
      final result = await add(user);
      
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
  Future<bool> isPhoneNumberExist(String phoneNumber) async {
    try {
      // 使用本地数据库查询
      final results = await queryLo('phone_number = ?', [phoneNumber]);
      print('手机号存在: ${results.isNotEmpty}');
      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
   
  // 获取所有用户直接调用父类的getAll

  // 用户登录 - 修改为使用本地数据库
  Future<Map<String, dynamic>> loginUser(String phoneNumber, String password, String job) async {
    try {
      // 使用本地数据库根据手机号查询用户
      final results = await queryLo('phone_number = ?', [phoneNumber]);
      
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
      
      // 更新用户最后登录时间
      final updatedUser = user.copyWith(
        job: job,
        lastLoginTime: DateTime.now(),
      );
      
      // 更新本地数据库中的用户信息
      if (user.id != null) {
        await updateLo(user.id!, updatedUser);
      } else {
        return {
          'success': false,
          'message': '用户ID为空，无法更新',
          'error': '用户记录ID为空',
        };
      }
      
      return {
        'success': true,
        'message': '登录成功',
        'entity': updatedUser,
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

  // 根据自定义过滤器查询成功数据记录
  /// 返回[UserEntity]对象列表
  Future<List<UserEntity>> queryUsers(String filter) async {
    return query(filter);
  }
}
