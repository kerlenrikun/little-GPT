import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:star_claude/__init__.dart';
import 'package:star_claude/common/widgets/button/basic_app_button.dart';
import 'package:star_claude/core/configs/assets/app_vector.dart';
import 'package:star_claude/data/db/database_manager.dart';

import 'package:star_claude/domain/__init__.dart';

import 'dart:developer' as developer;
import 'dart:ui';
import 'package:star_claude/core/configs/theme/app_colors.dart';
import 'package:star_claude/core/configs/feishu/feishu_config.dart';

/// 数据操作工具类
/// 封装了数据编辑、删除等通用操作
class DataUtils {
  /// 数据库管理器实例
  static final DatabaseManager dbManager = DatabaseManager();

  /// 数据仓库实例
  static final SuccDataRepository _succDataRepository = SuccDataRepository();
  static final CommonDataRepository _commonDataRepository =
      CommonDataRepository();
  static final CommonDbDataRepository _commonDbDataRepository =
      CommonDbDataRepository();
  static final AccountDataRepository _accountDataRepository =
      AccountDataRepository();

  // ====================== 私有函数定义 ======================

  //=========== 动画 ===========
  /// 渐变分割线
  static Container _buildGradientDivider(int width) {
    try {
      return Container(
        height: 1,
        width: width.toDouble(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.8),
              Colors.white.withOpacity(0.3),
              Colors.transparent,
            ],
            stops: [0.0, 0.1, 0.5, 0.9, 1.0],
          ),
        ),
      );
    } catch (e) {
      print('创建渐变分割线失败: $e');
      return Container(height: 1, width: width.toDouble(), color: Colors.grey);
    }
  }

  /// 分隔线
  static Widget buildSeparator() {
    try {
      return Stack(
        children: [
          Container(height: 9, color: Colors.black.withOpacity(0.3)),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      print('创建分隔线失败: $e');
      return Container(height: 9, color: Colors.black.withOpacity(0.3));
    }
  }

  /// 加载动画指示器
  static Widget buildLoadingIndicator(String? message) {
    try {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              message ?? 'waiting...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    } catch (e) {
      print('创建加载指示器失败: $e');
      return Center(
        child: Text(message ?? '加载中...', style: TextStyle(color: Colors.white)),
      );
    }
  }

  /// 执行带加载动画的异步操作
  static Future<T> executeWithLoading<T>(
    BuildContext context,
    Future<T> Function() asyncOperation,
    Widget loadingIndicator,
  ) async {
    // 显示加载动画对话框
    showDialog(
      context: context,
      barrierDismissible: false, // 不可点击背景关闭
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black87.withOpacity(0.7),
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: EdgeInsets.all(24),
          child: loadingIndicator,
        ),
      ),
    );

    try {
      // 执行异步操作
      final result = await asyncOperation();
      return result;
    } finally {
      // 无论成功失败，都关闭加载对话框
      Navigator.pop(context);
    }
  }

  // =========== 功能 =================
  /// 解析数值字符串为整数
  static int _parseValue(String valueText) {
    try {
      return int.tryParse(valueText) ?? 0;
    } catch (e) {
      print('解析数值失败: $e');
      return 0;
    }
  }

  /// 显示消息提示
  static void _showMessage(BuildContext context, String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.all(12),
          content: Text(
            message,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.black.withOpacity(0.6),
        ),
      );
    } catch (e) {
      print('显示消息失败: $e');
      // 失败时静默处理，不抛出异常
    }
  }

  // =========== 流量端相关功能 =================
  /// 显示流量端列表对话框
  /// [context] 上下文
  /// [trafficSources] 流量端列表
  /// [currentAccount] 当前账号实体
  /// [userProvider] 用户信息提供者
  /// [accountRepository] 账号数据仓库
  /// [onRefreshData] 刷新数据的回调函数
  static Future<void> showTrafficSourcesDialog(
    BuildContext context,
    List<String> trafficSources,
    AccountDataEntity currentAccount,
    UserProvider userProvider,
    AccountDataRepository accountRepository,
    Function() onRefreshData,
  ) async {
    // 检查当前用户是否为流量端
    final isTrafficSourceUser = userProvider.currentUser.job == '流量端';

    // 显示对话框
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.white24, width: 1.0),
          ),
          title: Column(
            children: [
              Text(
                '流量端列表',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              _buildGradientDivider(800),
            ],
          ),

          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trafficSources.isEmpty)
                  Text(
                    '暂无人推流',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 2,
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: trafficSources.map((source) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24, width: 1.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              source,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 2,
                              ),
                            ),
                            if (isTrafficSourceUser &&
                                source == userProvider.currentUser.fullName)
                              TextButton(
                                onPressed: () async {
                                  try {
                                    // 显示加载状态
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black87.withOpacity(
                                              0.7,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4.0,
                                            ),
                                          ),
                                          padding: EdgeInsets.all(24),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              backgroundColor:
                                                  Colors.transparent,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.primary,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );

                                    // 调用移除流量端的方法
                                    await accountRepository
                                        .removeTrafficSourceFromAccount(
                                          currentAccount.recordId ?? '',
                                          currentAccount.trafficSources,
                                          userProvider.currentUser.fullName,
                                        );

                                    // 关闭加载对话框
                                    Navigator.of(context).pop();

                                    // 显示成功提示
                                    _showMessage(context, '移除流量端成功');

                                    // 刷新数据
                                    onRefreshData();

                                    // 关闭流量端列表对话框
                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    // 关闭加载对话框
                                    Navigator.of(context).pop();

                                    // 显示错误提示
                                    _showMessage(
                                      context,
                                      '移除失败：${e.toString()}',
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '移除',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red[300],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                if (isTrafficSourceUser &&
                    !trafficSources.contains(
                      userProvider.currentUser.fullName,
                    ) &&
                    currentAccount.canAcceptTraffic)
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // 显示加载状态
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black87.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );

                          // 调用添加流量端的方法
                          await accountRepository.addTrafficSourceToAccount(
                            currentAccount.recordId ?? '',
                            currentAccount.trafficSources,
                            userProvider.currentUser.fullName,
                          );

                          // 关闭加载对话框
                          Navigator.of(context).pop();

                          // 显示成功提示
                          _showMessage(context, '添加流量端成功');

                          // 刷新数据
                          onRefreshData();

                          // 关闭对话框
                          Navigator.of(context).pop();
                        } catch (e) {
                          // 关闭加载对话框
                          Navigator.of(context).pop();

                          // 显示错误提示
                          _showMessage(context, '添加失败：${e.toString()}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '添 加 我 为 流 量 端',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                if (!isTrafficSourceUser)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '只有流量端可以编辑流量端信息',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '关 闭',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========== 后端 =================
  /// 删除记录
  /// 删除记录，支持多种实体类型
  /// [dataEntity] 要删除的实体，需要有 name 属性
  /// [repository] 对应的仓库实例
  /// [context] 上下文
  /// [onSuccess] 成功回调
  static Future<void> _deleteRecord<T, R extends Object>(
    T entity,
    BuildContext context,
    Function() onSuccess,
    R repository,
    Future<Map<String, dynamic>> Function(R, T) deleteRecordFunction,
  ) async {
    try {
      // 调用仓库方法删除记录
      final Map<String, dynamic> deleteResult = await deleteRecordFunction(
        repository,
        entity,
      );
      developer.log('上传结果: $deleteResult');

      if (deleteResult['success'] == true) {
        // 显示成功提示
        _showMessage(context, '已在飞书中删除');
        // 调用成功回调，传递删除的实体
        onSuccess();
      } else {
        throw Exception(deleteResult['message'] ?? '删除失败');
      }
    } catch (e) {
      // 错误处理
      _showMessage(context, '删除失败: ${e.toString()}');
    }
  }

  // =========== 表单与输入框 ===========
  /// 创建统一的表单输入装饰器
  /// 创建统一的表单输入装饰器
  /// [labelText] 输入框的标签文本
  static InputDecoration _createInputDecoration(String labelText) {
    return InputDecoration(
      // 设置输入框的标签文本
      labelText: labelText,
      // 设置标签文本的样式，字体大小为14，颜色为灰色
      labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      // 设置输入框内容的内边距，水平方向12.0，垂直方向2.0
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 2.0,
      ),
      // 设置输入框启用状态下的边框样式，圆角半径为4.0，边框颜色为半透明灰色，宽度为0.4
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.8), width: 0.5),
      ),
    );
  }

  /// 创建统一的表单输入框
  static TextFormField _createFormField({
    required TextEditingController controller,
    required String labelText,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: _createInputDecoration(labelText),
      validator: validator,
      keyboardType: keyboardType,
    );
  }

  /// 创建年月日输入框
  static TextFormField _createYearMonthDayFormField({
    required TextEditingController controller,
    required int maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelStyle: const TextStyle(fontSize: 10, color: Colors.transparent),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 2.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 0.4,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      validator: validator,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: maxLength,
      style: TextStyle(fontSize: 14, color: Colors.white),
      // 添加固定宽度约束
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
    );
  }

  /// 年
  static TextFormField _createYear({
    required TextEditingController controller,
  }) {
    return _createYearMonthDayFormField(
      controller: controller,
      maxLength: 4,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '年份不能为空';
        }
        final year = int.tryParse(value);
        if (year == null || year < 2000 || year > 2100) {
          return '请输入有效的年份';
        }
        return null;
      },
    );
  }

  /// 月
  static TextFormField _createMonth({
    required TextEditingController controller,
  }) {
    return _createYearMonthDayFormField(
      controller: controller,
      maxLength: 2,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '月份不能为空';
        }
        final month = int.tryParse(value);
        if (month == null || month < 1 || month > 12) {
          return '请输入有效的月份';
        }
        return null;
      },
    );
  }

  /// 日
  static TextFormField _createDay({
    required TextEditingController controller,
    required TextEditingController yearController,
    required TextEditingController monthController,
  }) {
    return _createYearMonthDayFormField(
      controller: controller,
      maxLength: 2,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '日期不能为空';
        }
        final day = int.tryParse(value);
        if (day == null || day < 1 || day > 31) {
          return '请输入有效的日期';
        }
        // 简单校验日期有效性
        try {
          final year = int.parse(yearController.text);
          final month = int.parse(monthController.text);
          DateTime(year, month, day);
        } catch (e) {
          return '请输入有效的日期';
        }
        return null;
      },
    );
  }

  /// 显示添加新数据对话框
  static Future<bool> _showAddNewDialog(
    BuildContext context,
    UserEntity user,
    TextEditingController nameController,
    TextEditingController c0Controller,
    TextEditingController c1Controller,
    TextEditingController succLlController,
    TextEditingController succCjController,
    TextEditingController succZxController,
    TextEditingController succZhController,
    TextEditingController yearController,
    TextEditingController monthController,
    TextEditingController dayController,
  ) async {
    // 创建表单状态键
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // 根据用户的selectedId设置对应的输入框
    switch (user.job) {
      case '直销端':
        succZxController.text = user.fullName;
        break;
      case '转化端':
        succZhController.text = user.fullName;
        break;
    }

    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            // 透明背景
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                // 半透明背景色
                color: Colors.black87,
                // 圆角边框
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 姓名输入
                        _createFormField(
                          controller: nameController,
                          labelText: '姓名',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入姓名';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 5),
                        // LL输入
                        user.job == '直销端' || user.job == '数据端'
                            ? _createFormField(
                                controller: succLlController,
                                labelText: '流 量',
                              )
                            : SizedBox(height: 10),
                        SizedBox(height: 5),
                        // CJ输入
                        user.job == '直销端' || user.job == '数据端'
                            ? _createFormField(
                                controller: succCjController,
                                labelText: '承 接',
                              )
                            : SizedBox(height: 10),
                        SizedBox(height: 5),
                        // ZX输入
                        user.job == '直销端' || user.job == '数据端'
                            ? _createFormField(
                                controller: succZxController,
                                labelText: '直 销',
                              )
                            : SizedBox(height: 10),
                        SizedBox(height: 5),
                        // 交付时间输入 - 年月日三框并排
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '上课时间',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 为每个输入框添加固定宽度
                                SizedBox(
                                  width: 60,
                                  child: _createYear(
                                    controller: yearController,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text('年', style: TextStyle(color: Colors.grey)),
                                SizedBox(width: 6),

                                // 月份输入框
                                SizedBox(
                                  width: 45,
                                  child: _createMonth(
                                    controller: monthController,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text('月', style: TextStyle(color: Colors.grey)),
                                SizedBox(width: 6),

                                // 日期输入框
                                SizedBox(
                                  width: 45,
                                  child: _createDay(
                                    controller: dayController,
                                    yearController: yearController,
                                    monthController: monthController,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text('日', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 取消按钮
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          'No',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff38B432),
                          ),
                        ),
                      ),
                      Text(
                        '/',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      // 上传按钮
                      TextButton(
                        onPressed: () {
                          // 验证表单
                          if (formKey.currentState?.validate() ?? false) {
                            Navigator.pop(context, true);
                          } else {
                            // 表单验证失败，显示提示
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('请输入有效的数据')),
                            );
                          }
                        },
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff38B432),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  /// 显示编辑数据--输入框
  static Future<bool> _showEditDialog(
    BuildContext context,
    UserEntity user,
    TextEditingController nameController,
    TextEditingController c0Controller,
    TextEditingController c1Controller,
    TextEditingController yearController,
    TextEditingController monthController,
    TextEditingController dayController,
    TextEditingController succZhController,
  ) async {
    // 创建表单状态键
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            // 透明背景
            backgroundColor: Colors.transparent,
            child: BackdropFilter(
              // 添加毛玻璃效果
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  // 半透明背景色
                  color: Colors.black87,
                  // 圆角边框
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 名称输入
                          _createFormField(
                            controller: nameController,
                            labelText: '姓名',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入姓名';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 8),
                          // 交付时间输入 - 年月日三框并排
                          user.job == '直销端' ||
                                  user.job == '转化端' ||
                                  user.job == '数据端'
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '上课时间',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 为每个输入框添加固定宽度
                                        SizedBox(
                                          width: 60,
                                          child: _createYear(
                                            controller: yearController,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '年',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(width: 6),

                                        // 月份输入框
                                        SizedBox(
                                          width: 45,
                                          child: _createMonth(
                                            controller: monthController,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '月',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(width: 6),

                                        // 日期输入框
                                        SizedBox(
                                          width: 45,
                                          child: _createDay(
                                            controller: dayController,
                                            yearController: yearController,
                                            monthController: monthController,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '日',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : SizedBox(height: 2),
                          SizedBox(height: 8),
                          // c0输入
                          user.job == '转化' || user.job == '数据端'
                              ? _createFormField(
                                  controller: c0Controller,
                                  labelText: 'C0',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    // 不能都填1
                                    if (value != null && value.isNotEmpty) {
                                      if (int.tryParse(value) == null) {
                                        return '请输入有效的C0值';
                                      }
                                      if (int.tryParse(value) == 1 &&
                                          int.tryParse(c1Controller.text) ==
                                              1) {
                                        return 'C0和C1不能都填1';
                                      }
                                    }
                                    return null;
                                  },
                                )
                              : SizedBox(height: 2),
                          SizedBox(height: 8),
                          // c1输入
                          user.job == '转化' || user.job == '数据端'
                              ? _createFormField(
                                  controller: c1Controller,
                                  labelText: 'C1',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    // 非转化角色不强制要求
                                    if (user.job != '转化') {
                                      if (value != null &&
                                          value.isNotEmpty &&
                                          int.tryParse(value) == null) {
                                        return '请输入有效的C1值';
                                      }
                                      return null;
                                    }
                                    // 转化角色要求至少填写C0或C1
                                    if (value == null || value.isEmpty) {
                                      if (c0Controller.text.isEmpty) {
                                        return '转化角色必须填写C0或C1值';
                                      }
                                    } else if (int.tryParse(value) == null) {
                                      return '请输入有效的C1值';
                                    }
                                    return null;
                                  },
                                )
                              : SizedBox(height: 2),
                          SizedBox(height: 8),
                          // 转化输入
                          user.job == '直销端' || user.job == '数据端'
                              ? _createFormField(
                                  controller: succZhController,
                                  labelText: '分配给转化端',
                                )
                              : SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Edit The Item',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        // 取消按钮
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff38B432),
                            ),
                          ),
                        ),
                        Text(
                          ' / ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        // 确定按钮
                        TextButton(
                          onPressed: () {
                            // 验证表单
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.pop(context, true);
                            } else {
                              // 表单验证失败，显示提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('请输入有效的数据')),
                              );
                            }
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff38B432),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;
  }

  /// 上传数据记录到飞书
  /// [T] 数据实体类型
  /// [R] 数据仓库类型，需包含 addRecord 方法
  static Future<void> _uploadRecord<T, R extends Object>(
    T entity,
    BuildContext context,
    Function(T) onSuccess,
    R repository,
    Future<Map<String, dynamic>> Function(R, T) addRecordFunction,
  ) async {
    try {
      // 执行飞书表格数据上传
      final Map<String, dynamic> uploadResult = await addRecordFunction(
        repository,
        entity,
      );
      developer.log('上传结果: $uploadResult');

      if (uploadResult['success'] == true) {
        // 显示成功提示
        _showMessage(context, '🎉数据已成功上传至飞书');
        // 调用成功回调 - 更新本地数据
        onSuccess(entity);
      } else {
        throw Exception(uploadResult['message'] ?? '上传失败');
      }
    } catch (e) {
      // 错误处理
      _showMessage(context, '上传失败: ${e.toString()}');
    }
  }

  /// 显示添加通用数据--输入框
  static Future<bool> _showAddCommonDataDialog(
    BuildContext context,
    UserEntity currentUser,
    UserEntity targetUser,
    TextEditingController valueController,
    TextEditingController cjController,

  ) async {
    //默认值
    valueController.text = '0';
    cjController.text = '0';
    // 创建表单状态键
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final String _toJob =
        targetUser.allowJob['承接端'] == 1 && currentUser.job == '承接端'
        ? '流量端'
        : targetUser.allowJob['流量端'] == 1 && currentUser.job == '流量端'
        ? '承接端'
        : targetUser.allowJob['直销端'] == 1 && currentUser.job == '承接端'
        ? '直销端'
        : '';
    final labelText = currentUser.job == '流量端'
        ? ['推流']
        : targetUser.allowJob['流量端'] == 1 &&
              targetUser.allowJob['直销端'] == 1 &&
              currentUser.job == '承接端'
        ? ['推微', '加粉']
        : targetUser.allowJob['流量端'] == 1 &&
              targetUser.allowJob['直销端'] == 0 &&
              currentUser.job == '承接端'
        ? ['加粉']
        : targetUser.allowJob['流量端'] == 0 &&
              targetUser.allowJob['直销端'] == 1 &&
              currentUser.job == '承接端'
        ? ['推微']
        : [''];

    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            // 透明背景
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                // 半透明背景色
                color: Colors.black.withOpacity(0.8),
                // 圆角边框
                borderRadius: BorderRadius.circular(4.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '添 加   数 据',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 显示当前用户和目标用户信息
                        Text(
                          'From: ${currentUser.job} - ${currentUser.fullName}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'To: $_toJob - ${targetUser.fullName}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        // 数值输入框
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              // 正常情况只有一个框
                              _createFormField(
                                controller: valueController,
                                labelText: labelText[0],
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null; // 不输入时默认值为0，验证通过
                                  }
                                  if (int.tryParse(value) == null) {
                                    return '请输入有效的数字';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 8),
                              // 如果承接遇到了又干流量又干直销的
                              targetUser.allowJob['流量端'] == 1 &&
                                      targetUser.allowJob['直销端'] == 1 &&
                                      currentUser.job == '承接端'
                                  ? _createFormField(
                                      controller: cjController,
                                      labelText: labelText[1],
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return null; // 允许不输入，直接返回 null 表示验证通过
                                        }
                                        if (int.tryParse(value) == null) {
                                          return '请输入有效的数字';
                                        }
                                        return null;
                                      },
                                    )
                                  : SizedBox(height: 5),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // 按钮组
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 确认按钮
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  Navigator.pop(context, true);
                                }
                              },
                              child: Text(
                                '确认',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 32),
                            // 取消按钮
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.transparent,
                              ),
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  /// 显示添加或编辑账号数据--输入框
  static Future<bool> _showAddOrEditAccountDataDialog(
    BuildContext context,
    UserEntity user,
    TextEditingController cJController,
    TextEditingController sMController,
    TextEditingController wXController,
    AccountDataEntity? accountData,
  ) async {
    // 创建表单状态键
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            //---------ui----------//
            backgroundColor: Colors.transparent,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                //------------ui----------//
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 持号承接端输入
                          _createFormField(
                            controller: cJController
                              ..text = user.job == '承接端' ? user.fullName : '',
                            labelText: '承接人员',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入姓名';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 8),
                          // 实名人输入
                          _createFormField(
                            controller: sMController
                              ..text = accountData?.accountRealName ?? '',
                            labelText: '实名人',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入实名人';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 8),
                          // Vx号输入
                          _createFormField(
                            controller: wXController
                              ..text = accountData?.wechatId ?? '',
                            labelText: '微信号',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '请输入微信号';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Are You Sure ?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        // 取消按钮
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff38B432),
                            ),
                          ),
                        ),
                        Text(
                          '/',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        // 确定按钮
                        TextButton(
                          onPressed: () {
                            // 验证表单
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.pop(context, true);
                            } else {
                              // 表单验证失败，显示提示
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('请输入有效的数据')),
                              );
                            }
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff38B432),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;
  }

  // ====================== 核心构建逻辑 =================================

  /// 显示删除确认对话框并执行删除操作
  /// [context]: 上下文
  /// [succData]: 要删除的数据实体
  /// [onSuccess]: 删除成功后的回调函数
  static Future<void> showDeleteSuccData(
    BuildContext context,
    SuccDataEntity succData,
    Function() onSuccess,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            // 透明背景
            backgroundColor: Colors.transparent,
            // 边框
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            child: BackdropFilter(
              // 添加毛玻璃效果
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  // 半透明背景色
                  color: Colors.black87.withOpacity(0.5),
                  // 圆角边框
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Delete  This  Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    // 渐变分割线
                    _buildGradientDivider(350),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 取消按钮
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff38B432),
                            ),
                          ),
                        ),
                        Text(
                          '/',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        // 删除按钮
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xffE03131),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;

    if (shouldDelete) {
      // 使用加载动画执行删除操作
      await executeWithLoading<void>(context, () async {
        // 前端 -> 飞书云
        await _deleteRecord(
          succData,
          context,
          onSuccess,
          _succDataRepository,
          (repo, entity) => repo.deleteSuccDataRecord(entity),
        );
        // 飞书云端 -> 数据库
        await dbManager.importSuccDataFromFeishu();
      }, buildLoadingIndicator('删除中...'));
      onSuccess();
    }
  }

  /// 删除账号数据
  static Future<void> showDeleteAccountData(
    BuildContext context,
    AccountDataEntity accountData,
    Function() onSuccess,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            // 透明背景
            backgroundColor: Colors.transparent,
            // 边框
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            child: BackdropFilter(
              // 添加毛玻璃效果
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  // 半透明背景色
                  color: Colors.black87.withOpacity(0.5),
                  // 圆角边框
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Delete  This  Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    // 渐变分割线
                    _buildGradientDivider(350),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 取消按钮
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff38B432),
                            ),
                          ),
                        ),
                        Text(
                          '/',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        // 删除按钮
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xffE03131),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;

    if (shouldDelete) {
      try {
        // 使用加载动画执行删除操作
        await executeWithLoading<void>(context, () async {
          await _deleteRecord(
            accountData,
            context,
            onSuccess,
            _accountDataRepository,
            (repo, entity) => repo.deleteAccountDataRecord(entity),
          );
        }, buildLoadingIndicator('删除中...'));
        // 删除成功后调用回调
        onSuccess();
      } catch (e) {
        // 错误已在_deleteRecord中处理
      }
    }
  }

  /// 数据编辑操作 包含表单验证、飞书表格同步及状态更新
  ///
  /// 参数说明:
  /// - [context]: 上下文环境，用于显示UI组件
  /// - [succData]: 待编辑的数据实体对象
  /// - [onSuccess]: 编辑成功后的回调函数，返回更新后的实体
  static Future<void> showEditDialogAndEdit(
    BuildContext context,
    UserEntity user,
    SuccDataEntity succData,
    Function(SuccDataEntity) onSuccess,
  ) async {
    // 初始化表单控制器 - 预填充当前数据
    final TextEditingController editNameController = TextEditingController(
      text: succData.studentName,
    );
    final TextEditingController editC0Controller = TextEditingController(
      text: succData.c0.toString(),
    );
    final TextEditingController editC1Controller = TextEditingController(
      text: succData.c1.toString(),
    );
    // 年月日控制器
    final TextEditingController yearController = TextEditingController(
      text: DateTime.now().year.toString().padLeft(4, '0'),
    );
    final TextEditingController monthController = TextEditingController(
      text: DateTime.now().month.toString().padLeft(2, '0'),
    );
    final TextEditingController dayController = TextEditingController(
      text: DateTime.now().day.toString().padLeft(2, '0'),
    );
    // 转化输入
    final TextEditingController succZhController = TextEditingController(
      text: succData.succZh.toString(),
    );

    // 显示dataset风格的编辑对话框
    final shouldUpdate = await _showEditDialog(
      context,
      user,
      editNameController,
      editC0Controller,
      editC1Controller,
      yearController,
      monthController,
      dayController,
      succZhController,
    );

    if (shouldUpdate) {
      try {
        // 使用加载动画执行编辑操作
        await executeWithLoading<void>(context, () async {
          // 提取并验证表单数据
          final String newName = editNameController.text;
          final int newC0 = _parseValue(editC0Controller.text);
          final int newC1 = _parseValue(editC1Controller.text);
          final int newYear = _parseValue(yearController.text);
          final int newMonth = _parseValue(monthController.text);
          final int newDay = _parseValue(dayController.text);
          // 转化输入
          final String newSuccZh = succZhController.text;

          // 通过姓名查询飞书表格记录ID
          final String recordId = succData.recordId;
          developer.log(
            '✨ 准备更新记录 - ID: $recordId, 姓名: ${succData.studentName}',
          );

          // 构建更新后的数据集实体
          final SuccDataEntity updatedSuccData = SuccDataEntity(
            studentName: newName,
            succLl: succData.succLl,
            succCj: succData.succCj,
            succZx: succData.succZx,
            succZh: newSuccZh,
            succDate: succData.succDate,
            classDate: DateTime(newYear, newMonth, newDay),
            updateDate: succData.updateDate,
            c0: newC0,
            c1: newC1,
          );

          // 执行飞书表格数据同步
          final Map<String, dynamic> updateResult = await _succDataRepository
              .updateSuccDataRecord(recordId, updatedSuccData);

          developer.log('🌌 更新结果: $updateResult');

          // 处理同步结果 - 成功或失败反馈
          if (updateResult['success'] == true) {
            // 显示dataset主题风格的成功提示
            _showMessage(context, '🎉数据已成功更新至飞书');
            //  飞书 -> 本地
            await dbManager.importSuccDataFromFeishu();
            // 通知UI层更新状态
            onSuccess(updatedSuccData);
          } else {
            // 显示详细的错误信息
            _showMessage(
              context,
              '飞书数据更新失败: ${updateResult['message'] ?? '未知错误'}',
            );
          }
        }, buildLoadingIndicator('更新中...'));
      } finally {
        // 确保资源释放，避免内存泄漏
        editNameController.dispose();
        editC0Controller.dispose();
        editC1Controller.dispose();
        yearController.dispose();
        monthController.dispose();
        dayController.dispose();
        succZhController.dispose();
      }
    }
  }

  /// 添加common data
  /// 根据用户职位设置输入框
  /// 打开之后填 [数字]-<确认>
  /// 添加该条记录到飞书 添加的记录为:
  /// 'From'+currentUser.job: currentUser.fullname ; 'To'+该条目对应的UserEntity.job:该条目对应的UserEntity.fullName ; '数据值': 输入框中的数据
  static Future<void> showAddCommonDataDialog(
    BuildContext context,
    UserEntity currentUser,
    UserEntity targetUser,
    Function(CommonData) onAdd,
  ) async {
    // 创建控制器
    final TextEditingController valueController = TextEditingController();
    final TextEditingController cjController = TextEditingController();

    try {
      // 显示添加通用数据对话框
      final shouldAdd = await _showAddCommonDataDialog(
        context,
        currentUser,
        targetUser,
        valueController,
        cjController,
      );

      if (shouldAdd) {
        // 执行飞书表格数据同步（带加载动画）
        await executeWithLoading<void>(context, () async {
          // 提取并验证表单数据
          final String valueText = valueController.text;
          final int value = _parseValue(valueText);
          final DateProvider dateProvider = Provider.of<DateProvider>(
            context,
            listen: false,
          );
          // 辅助方法：统一添加数据到存储
          Future<Map<String, dynamic>> _addCommonDataToStorage(
            CommonData data,
            ) async {
            final Map<String, dynamic> addResult = await _commonDataRepository
                .addCommonData(data);
            developer.log('🌌 添加通用数据结果: $addResult');
            await _commonDbDataRepository.addCommonData(data);
            return addResult;
          }

          // 构建基础通用数据实体
          final CommonData baseCommonData = CommonData(
            fromLL: currentUser.job == '流量端' ? currentUser.fullName : '',
            fromCj: currentUser.job == '承接端' ? currentUser.fullName : '',
            fromZx: currentUser.job == '直销端' ? currentUser.fullName : '',
            fromZh: currentUser.job == '转化端' ? currentUser.fullName : '',
            toLL:
                targetUser.allowJob['流量端'] == 1 &&
                    currentUser.job == '承接端' &&
                    targetUser.allowJob['直销端'] == 0
                ? targetUser.fullName
                : '',
            toCj: targetUser.allowJob['承接端'] == 1 && currentUser.job == '流量端'
                ? targetUser.fullName
                : '',
            toZx: targetUser.allowJob['直销端'] == 1 && currentUser.job == '承接端'
                ? targetUser.fullName
                : '',
            toZh: '',
            value: value,
            date: dateProvider.selectedDate,
          );

          // 又干流量又干直销的抽象哥 - 使用copyWith简化
          if (targetUser.allowJob['流量端'] == 1 &&
              targetUser.allowJob['直销端'] == 1 &&
              currentUser.job == '承接端') {
            // 仅复制并修改不同的字段
            final CommonData cjCommonData = baseCommonData.copyWith(
              toLL: targetUser.allowJob['流量端'] == 1 && currentUser.job == '承接端'
                  ? targetUser.fullName
                  : '',
              toZx:
                  targetUser.allowJob['直销端'] == 1 &&
                      currentUser.job == '承接端' &&
                      targetUser.allowJob['流量端'] == 0
                  ? targetUser.fullName
                  : '',
              value: _parseValue(cjController.text),
            );

            // 添加到远程和本地数据库
            await _addCommonDataToStorage(cjCommonData);
          } else {
            print('一切正常');
          }
          
          final Map<String, dynamic> addResult = await _commonDataRepository.addCommonData(baseCommonData);
          // 处理同步结果 - 成功或失败反馈
          if (addResult['success'] == true) {
            _showMessage(context, '🎉成功添加至飞书');
            onAdd(baseCommonData);
          } else {
            // 显示详细的错误信息
            _showMessage(
              context,
              '飞书数据添加失败: ${addResult['message'] ?? '未知错误'}',
            );
          }
        }, buildLoadingIndicator('添加中...'));
      }
    } finally {
      // 确保资源释放，避免内存泄漏
      valueController.dispose();
    }
  }

  /// 添加succ data
  /// [context]: 上下文
  /// [userProvider]: 用户信息提供者，用于设置默认值
  /// [onSuccess]: 添加成功后的回调函数
  static Future<void> showAddNewDialog(
    BuildContext context,
    UserEntity user,
    Function(SuccDataEntity) onSuccess,
    String? selectedDateStr,
  ) async {
    // 初始化表单控制器
    final TextEditingController nameController = TextEditingController();
    final TextEditingController c0Controller = TextEditingController();
    final TextEditingController c1Controller = TextEditingController();
    final TextEditingController succLlController = TextEditingController();
    final TextEditingController succCjController = TextEditingController();
    final TextEditingController succZxController = TextEditingController();
    final TextEditingController succZhController = TextEditingController();
    final TextEditingController classDateController = TextEditingController();
    // 年月日控制器
    final TextEditingController yearController = TextEditingController(
      text: DateTime.now().year.toString().padLeft(4, '0'),
    );
    final TextEditingController monthController = TextEditingController(
      text: DateTime.now().month.toString().padLeft(2, '0'),
    );
    final TextEditingController dayController = TextEditingController(
      text: DateTime.now().day.toString().padLeft(2, '0'),
    );

    try {
      // 显示添加新数据对话框
      final shouldUpload = await _showAddNewDialog(
        context,
        user,
        nameController,
        c0Controller,
        c1Controller,

        succLlController,
        succCjController,
        succZxController,
        succZhController,

        yearController,
        monthController,
        dayController,
      );

      if (shouldUpload) {
        // 提取并验证表单数据
        final String name = nameController.text;
        final int c0 = _parseValue(c0Controller.text);
        final int c1 = _parseValue(c1Controller.text);
        final String succLl = succLlController.text;
        final String succCj = succCjController.text;
        final String succZx = succZxController.text;
        final String succZh = succZhController.text;
        final year = yearController.text.padLeft(4, '0');
        final month = monthController.text.padLeft(2, '0');
        final day = dayController.text.padLeft(2, '0');

        // 构建新的数据集实体
        final DateProvider dateProvider = Provider.of<DateProvider>(
          context,
          listen: false,
        );
        final SuccDataEntity newSuccData = SuccDataEntity(
          studentName: name,
          succLl: succLl,
          succCj: succCj,
          succZx: succZx,
          succZh: succZh,
          succDate: dateProvider.selectedDate,
          classDate: DateTime(
            int.parse(year),
            int.parse(month),
            int.parse(day),
          ),
          updateDate: DateTime.now(),
          c0: c0,
          c1: c1,
        );

        // 执行上传操作（带加载动画）
        print('🌌 上传数据: $newSuccData');
        await executeWithLoading<void>(context, () async {
          // 前端 -> 飞书云端
          await _uploadRecord(
            newSuccData,
            context,
            onSuccess,
            _succDataRepository,
            (repo, entity) => repo.addSuccDataRecord(entity),
          );
          // 飞书云端 -> 数据库
          await dbManager.importSuccDataFromFeishu();
        }, buildLoadingIndicator('上传中...'));
      }
    } finally {
      // 确保资源释放，避免内存泄漏
      nameController.dispose();
      c0Controller.dispose();
      c1Controller.dispose();
      succLlController.dispose();
      succCjController.dispose();
      succZxController.dispose();
      succZhController.dispose();
      classDateController.dispose();
      yearController.dispose();
      monthController.dispose();
      dayController.dispose();
    }
  }

  /// 添加新账号对话框并执行上传操作
  /// [context]: 上下文
  /// [userProvider]: 用户信息提供者，用于设置默认值
  /// [onSuccess]: 添加成功后的回调函数
  static Future<void> showAddOrEditAccountDialog(
    /// [isEdit]: 是否为编辑操作
    bool isEdit,
    AccountDataEntity? account,
    BuildContext context,
    UserEntity user,
    Function(AccountDataEntity) onSuccess,
  ) async {
    // 初始化表单控制器
    final TextEditingController cJController = TextEditingController();
    final TextEditingController sMController = TextEditingController();
    final TextEditingController wXController = TextEditingController();

    try {
      // 显示添加新账号对话框
      final shouldUpload = await _showAddOrEditAccountDataDialog(
        context,
        user,
        cJController,
        sMController,
        wXController,
        account,
      );

      if (shouldUpload) {
        // 提取并验证表单数据
        final String cJ = cJController.text;
        final String sM = sMController.text;
        final String wX = wXController.text;

        // 构建新的账号实体
        final AccountDataEntity newAccount = AccountDataEntity(
          recordId: account?.recordId ?? '',
          accountRealName: sM,
          accountHandler: cJ,
          wechatId: wX,
          loadStatus: '可接流',
          trafficSources: '',
        );

        // 执行上传操作（带加载动画）
        await executeWithLoading<void>(context, () async {
          if (isEdit) {
            // 编辑操作，调用更新方法
            await _uploadRecord(
              newAccount,
              context,
              onSuccess,
              _accountDataRepository,
              (repo, entity) => repo.updateAccountDataRecord(entity),
            );
          } else {
            // 添加操作，调用添加方法
            await _uploadRecord(
              newAccount,
              context,
              onSuccess,
              _accountDataRepository,
              (repo, entity) => repo.addAccountDataRecord(entity),
            );
          }
        }, buildLoadingIndicator('上传中...'));
      }
    } finally {
      // 确保资源释放，避免内存泄漏
      cJController.dispose();
      sMController.dispose();
      wXController.dispose();
    }
  }
}
