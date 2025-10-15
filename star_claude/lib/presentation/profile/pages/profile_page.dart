import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:star_claude/common/__init__.dart';
import 'package:star_claude/core/configs/theme/app_colors.dart';
import 'package:star_claude/data/db/database_manager.dart';
import 'package:star_claude/domain/provider/user_provider.dart';
import 'package:star_claude/presentation/auth/utils/animated_disappear_widget.dart';
import 'package:star_claude/presentation/profile/utils/cloud_animation.dart';
import 'package:star_claude/domain/usecases/job_resources.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final GlobalKey<State<AnimatedDisappearWidget>> _animatedButtonKey =
      GlobalKey();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('个人资料'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // 检查用户是否已登录
          if (!userProvider.isLoggedIn) {
            return const Center(child: Text('请先登录'));
          }

          // 获取当前登录用户信息
          final user = userProvider.currentUser;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 60, color: Colors.grey),
                SizedBox(height: 20),
                const Text('用  户  信  息', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 5),
                _infoRow('姓名:', user.fullName),
                _infoRow('手机号:', user.phoneNumber),
                _infoRow('当前职业:', user.job ?? ''),
                _infoRow('可选职业:', () {
                  String result = '';
                  List<String> selectedJobs = [];
                  for (var entry in user.allowJob.entries) {
                    if (entry.value == 1) {
                      selectedJobs.add(entry.key.substring(0, 2));
                    }
                  }
                  result = selectedJobs.join(' | ');
                  return result;
                }()),

                // 快捷切换职业按钮
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: TextButton(
                    onPressed: () => _switchJob(context, userProvider),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '切换职业',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // 这里可以添加其他基于用户信息的UI组件
                const SizedBox(height: 80),
                _buildSyncButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  // 构建同步按钮，根据加载状态显示不同内容
  Widget _buildSyncButton() {
    if (_isLoading) {
      // 加载中：显示透明背景的云朵动画
      return Container(
        width: 100,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: CloudAnimation(size: 45, color: AppColors.primary), // 增大动画尺寸
        ),
      );
    } else {
      // 非加载中：显示正常的同步按钮
      return AnimatedDisappearWidget(
        key: _animatedButtonKey,
        loadingWidget: Container(
          width: 150,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CloudAnimation(color: AppColors.primary), // 增大动画尺寸
          ),
        ),
        child: IconButton(
          icon: const Icon(Icons.cloud_download, color: Colors.white, size: 36),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          ),
          onPressed: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);

            // 触发按钮消失动画
            final animatedState = _animatedButtonKey.currentState;
            if (animatedState != null) {
              (animatedState as dynamic).startAnimation();
            }

            try {
              // 等待动画完成后再执行数据同步
              await Future.delayed(const Duration(milliseconds: 200));

              // 执行数据同步操作
              await DatabaseManager().importAllDataFromFeishu();
            } catch (e) {
              // 显示失败提示
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('同步失败：$e'), backgroundColor: Colors.red),
              );
            } finally {
              // 无论成功失败，都要重置加载状态和动画
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });

                // 重置动画
                final animatedState = _animatedButtonKey.currentState;
                if (animatedState != null) {
                  (animatedState as dynamic).resetAnimation();
                }
              }
            }
          },
        ),
      );
    }
  }

  // 信息行组件
  Widget _infoRow(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // 切换职业的方法
  void _switchJob(BuildContext context, UserProvider userProvider) {
    final user = userProvider.currentUser;

    // 获取用户允许的职业列表
    List<String> allowedJobs = [];
    for (var entry in user.allowJob.entries) {
      if (entry.value == 1) {
        allowedJobs.add(entry.key);
      }
    }

    if (allowedJobs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('您没有可用的职业权限')));
      return;
    }

    // 找到当前职业在允许列表中的索引
    int currentIndex = allowedJobs.indexOf(user.job ?? allowedJobs.first);

    // 如果当前职业不在允许列表中，默认使用第一个
    if (currentIndex == -1) {
      currentIndex = 0;
    }

    // 计算下一个职业的索引（循环切换）
    int nextIndex = (currentIndex + 1) % allowedJobs.length;
    String nextJob = allowedJobs[nextIndex];

    // 获取下一个职业的ID
    int nextJobId = JobUtils.stringToId(nextJob);

    // 更新用户职业
    userProvider.updateUserInfo(selectedId: nextJobId);

    // 显示切换成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚔️已切换至：$nextJob', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.only(left: MediaQuery.of(context).size.width / 2 - 80),
        duration: Duration(milliseconds: 500),
      ),
    );
  }
}
