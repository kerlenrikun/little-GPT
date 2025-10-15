// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:star_claude/common/widgets/error/id_error.dart';
import 'package:star_claude/core/configs/theme/app_colors.dart';
import 'package:star_claude/domain/entities/data/account_data.dart';
import 'package:star_claude/domain/provider/account_data_provider.dart';
import 'package:star_claude/domain/provider/user_provider.dart';
import 'package:star_claude/domain/repository/account_data_repository.dart';
import 'package:star_claude/presentation/dataset/utils/operate.dart';
import 'package:star_claude/presentation/dataset/widgets/base_data_page.dart';
import 'package:star_claude/presentation/dataset/utils/data_utils.dart';

/// 账号数据展示页面
/// 负责展示账号数据列表，并处理加载状态、错误状态和空数据状态
class AccountDataPage extends StatefulWidget {
  const AccountDataPage({super.key});

  @override
  State<AccountDataPage> createState() => _AccountDataPageState();
}

class _AccountDataPageState extends State<AccountDataPage> {
  // 【====================== 状态变量 ======================】
  /// 账号数据列表
  List<AccountDataEntity> _accountDataList = [];

  /// 加载状态
  bool _isLoading = false;

  /// 错误信息
  String? _errorMessage;

  /// 身份限制
  bool _idError = false;

  // 【====================== getter ======================】
  ///刷新
  /// 刷新账号数据列表
  void refreshAccountDataList() {
    _loadData();
  }

  /// 获取账号数据列表
  List<AccountDataEntity> get accountDataList => _accountDataList;

  // 【====================== 共享数据 ======================】
  /// 账号数据存储库实例
  final AccountDataRepository accountRepository = AccountDataRepository();

  /// 账号数据提供者实例
  AccountDataProvider get accountProvider =>
      Provider.of<AccountDataProvider>(context, listen: false);

  /// 用户提供者实例
  UserProvider get userProvider =>
      Provider.of<UserProvider>(context, listen: false);

  // 【====================== 生命周期 ======================】
  @override
  void initState() {
    super.initState();
    // 初始化时加载数据
    _loadData();
  }

  @override
  void dispose() {
    // 确保在组件被销毁时释放资源
    super.dispose();
  }

  // 《================================== 内置函数区 =====================================》
  /// 加载账号数据
  /// 从仓库获取数据并更新状态
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 获取当前用户信息
      final currentUser = userProvider.currentUser;
      List<AccountDataEntity> data;
      
      // 检查用户是否是承接端
      if (currentUser.job=='承接端') {
        // 承接端只获取accountHandler为自己的账号数据
        data = await accountRepository.getAccountsByHandler(currentUser.fullName);
      } else {
        // 非承接端获取所有账号数据
        data = await accountRepository.getAllAccounts();
      }

      // 检查组件是否仍然挂载
      if (!mounted) return;

      // 更新provider中的数据
      accountProvider.setAccountList(data);

      // 更新本地列表
      setState(() {
        _accountDataList = data;
        // 重排账号列表
        _sortAccountList();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = '加载数据失败：${e.toString()}';
      });
      // 显示错误提示
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载数据失败：${e.toString()}')));
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 重排账号列表
  /// 流量端看列表时：我在推流放顶端，可接流但我没有推流其次，不可接流的放最后
  void _sortAccountList() {
    if (_accountDataList.isEmpty) return;

    // 自定义排序规则
    _accountDataList.sort((a, b) {
      // 先按是否在推流放排序（可接流在顶部）
      int loadStatusCompare = b.loadStatus.compareTo(a.loadStatus);
      if (loadStatusCompare != 0) return loadStatusCompare;

      // 再按流量端是否包含当前用户全名排序（包含的排在前面）
      final userName = userProvider.currentUser.fullName;
      bool aContainsUser = a.trafficSources.contains(userName);
      bool bContainsUser = b.trafficSources.contains(userName);
      if (aContainsUser != bContainsUser) {
        return bContainsUser ? 1 : -1;
      }

      // 最后按记录ID排序（保持原有顺序）
      return a.recordId?.compareTo(b.recordId ?? '') ?? 0;
    });
  }

  /// 添加条目
  void _onAdd(context) {
    // 处理上传操作
    DataUtils.showAddOrEditAccountDialog(
      false,
      null,
      context,
      userProvider.currentUser,
      (newItem) {
        if (mounted) {
          _loadData();
        }
      },
    );
  }

  /// 编辑条目
  void _onEdit(AccountDataEntity account) {
    // 处理上传操作
    DataUtils.showAddOrEditAccountDialog(
      true,
      account,
      context,
      userProvider.currentUser,
      (newItem) {
        // 更新
        if (mounted) {
          _loadData();
        }
      },
    );
  }

  /// 删除条目
  void _onDelete(AccountDataEntity account) {
    // 处理上传操作
    DataUtils.showDeleteAccountData(context, account, () {
      // 更新
      if (mounted) {
        _loadData();
      }
    });
  }

  // 《================================== 核心构建区 =====================================》
  /// 切换账号负荷状态并同步到飞书
  Future<void> _toggleLoadStatus(AccountDataEntity accountData) async {
    if (!mounted) return;

    try {
      // 显示加载状态
      setState(() {
        _isLoading = true;
      });

      // 同步更新到飞书平台
      if (accountData.loadStatus == '可接流') {
        // 切换为不可接流状态（同时清空流量端）
        await accountRepository.setAccountToUnavailable(accountData.recordId ?? '');
      } else {
        // 切换为可接流状态
        await accountRepository.setAccountToAvailable(accountData.recordId ?? '');
      }

      // 检查组件是否仍然挂载
      if (!mounted) return;

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉状态更新成功',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.transparent,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '💢更新失败：${e.toString()}',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.transparent,
        ),
      );
    } finally {
      if (!mounted) return;

      // 刷新数据
      _loadData();

      // 隐藏加载状态
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 【====================== UI组件构建 ======================】

  /// 刷新或上传组件
  Widget _upAndAddText(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'You Can:',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xff9e9e9e),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _loadData();
            });
          },
          child: const Text(
            'Update',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff38B432),
            ),
          ),
        ),
        Text(
          'Or',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xff9e9e9e),
          ),
        ),
        TextButton(
          onPressed: () {
            if (userProvider.currentUser.job == '数据端' ||
                userProvider.currentUser.job == '承接端') {
              _onAdd(context);
            } else {
              if (mounted) {
                setState(() {
                  _idError = true;
                });
                // 1秒后自动隐藏错误提示
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _idError = false;
                    });
                  }
                });
              }
            }
          },
          child: const Text(
            'Add New',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff38B432),
            ),
          ),
        ),
      ],
    );
  }

  /// 获取副标题文本
  Widget _getSubtitle(dynamic data) {
    if (data is AccountDataEntity) {
      // 分割流量端数据
      final List<String> trafficSources = data.trafficSources.isNotEmpty
          ? data.trafficSources.split('-')
          : [];

      return Column(
        children: [
          Row(
            children: [
              Text(
                '实名人: ',
                style: TextStyle(
                  fontSize: 13,
                  height: 2,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                data.accountRealName,
                style: TextStyle(
                  fontSize: 13,
                  height: 2,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                '  |  ',
                style: TextStyle(
                  fontSize: 13,
                  height: 2,
                  color: Colors.white70,
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (userProvider.currentUser.job == '数据端' ||
                      userProvider.currentUser.job == '承接端') {
                    await _toggleLoadStatus(data);
                  } else {
                    setState(() {
                      _idError = true;
                    });
                    // 1秒后自动隐藏错误提示
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) {
                        setState(() {
                          _idError = false;
                        });
                      }
                    });
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  data.loadStatus,
                  style: TextStyle(
                    fontSize: 13,
                    height: 2,
                    color: data.loadStatus == '可接流'
                        ? AppColors.primary
                        : Colors.red,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // 展示流量端列表
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: TextButton(
                  onPressed: () {
                    DataUtils.showTrafficSourcesDialog(
                      context,
                      trafficSources,
                      data,
                      userProvider,
                      accountRepository,
                      refreshAccountDataList,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size(0, 0),
                    textStyle: TextStyle(
                      fontSize: 14,
                      height: 2,
                      color: Colors.white,
                    ),
                  ),
                  child: Text(
                    '流量端:  ',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 13,
                      height: 2,
                      color: Color(0xff00a1d6),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: trafficSources.isNotEmpty
                    ? Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: trafficSources.map((source) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: source == userProvider.currentUser.fullName
                                  ? const Color(0xffca865d).withOpacity(0.2)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              source,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    source == userProvider.currentUser.fullName
                                    ? Colors.white70
                                    : Colors.white70,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Text(
                        '暂无流量端',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  /// 获取主标题文本
  Widget _getTitle(dynamic data) {
    if (data is AccountDataEntity) {
      return Row(
        children: [
          Text(
            data.accountHandler,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              letterSpacing: 4,
            ),
            textAlign: TextAlign.left,
          ),
          SizedBox(width: 24),
          GestureDetector(
            onTap: () {
              // 复制Vx号到剪贴板
              Clipboard.setData(ClipboardData(text: data.wechatId));
              // 显示复制成功的提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Vx号已复制: ${data.wechatId}',
                    style: TextStyle(height: 2, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.black.withOpacity(0.5),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🌐Vx: ${data.wechatId}',
                  style: TextStyle(
                    fontSize: 12,
                    height: 2,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(width: 4),
                Icon(Icons.content_copy, size: 12, color: Colors.white38),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  /// 构建单个账号数据项
  Widget _buildAccountItem(AccountDataEntity accountData, int index) {
    return Slidable(
      endActionPane: ActionPane(
        motion: StretchMotion(),
        extentRatio: 0.3, // 减小整体宽度，让图标更紧凑
        children: [
          SlidableAction(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            onPressed: (context) {
              if (userProvider.currentUser.job == '数据端' ||
                  userProvider.currentUser.job == '承接端') {
                _onDelete(accountData);
              } else {
                if (mounted) {
                  setState(() {
                    _idError = true;
                  });
                  // 1秒后自动隐藏错误提示
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      setState(() {
                        _idError = false;
                      });
                    }
                  });
                }
              }
            },
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 4.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: ListTile(
          minTileHeight: 0,
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xffB3B3B3),
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
          title: _getTitle(accountData),
          subtitle: _getSubtitle(accountData),
          trailing: IconButton(
            icon: Icon(Icons.edit_outlined),
            color: Colors.white, // 编辑
            onPressed: () {
              if (userProvider.currentUser.job == '数据端' ||
                  userProvider.currentUser.job == '承接端') {
                _onEdit(accountData);
              } else {
                if (mounted) {
                  setState(() {
                    _idError = true;
                  });
                  // 1秒后自动隐藏错误提示
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      setState(() {
                        _idError = false;
                      });
                    }
                  });
                }
              }
            },
          ),
        ),
      ),
    );
  }

  /// 构建分隔线
  Widget _buildSeparator() {
    return DataUtils.buildSeparator();
  }

  // 【====================== 页面构建 ======================】
  /// 构建整个页面布局
  Widget buildPage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _loadContent()),
              _upAndAddText(context),
            ],
          ),
          if (_idError) IdError(),
        ],
      ),
    );
  }

  /// 构建页面
  @override
  Widget build(BuildContext context) {
    return buildPage();
  }

  /// 刷新数据
  void refreshData() {
    _loadData();
  }

  /// 加载内容，处理不同状态的显示逻辑
  /// - 加载状态：显示加载指示器
  /// - 错误状态：显示错误信息和重试按钮
  /// - 空数据状态：显示空数据提示
  /// - 正常状态：显示数据列表
  Widget _loadContent() {
    // 显示加载指示器
    if (_isLoading) {
      return DataUtils.buildLoadingIndicator('正在加载账号数据...');
    }

    // 显示错误信息
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('重试'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
          ],
        ),
      );
    }

    // 显示空数据提示
    if (_accountDataList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 48, color: Colors.white30),
            SizedBox(height: 16),
            Text(
              '暂无账号数据',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 显示数据列表
    return ListView.separated(
      itemCount: _accountDataList.length,
      separatorBuilder: (context, index) => _buildSeparator(),
      itemBuilder: (context, index) {
        return _buildAccountItem(_accountDataList[index], index + 1);
      },
    );
  }
}
