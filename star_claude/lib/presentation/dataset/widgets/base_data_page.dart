import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_claude/domain/provider/date_provider.dart';

import 'package:star_claude/presentation/home/pages/test.dart';
import 'package:star_claude/core/configs/__init__.dart';
import 'package:star_claude/core/configs/theme/app_colors.dart';
import 'package:star_claude/domain/entities/data/succ_data.dart';
import 'package:star_claude/domain/repository/succ_data_repository.dart';
import 'package:star_claude/data/repository/succ_db_data_repository.dart';
import 'package:star_claude/presentation/dataset/utils/operate.dart';
import 'package:star_claude/common/__init__.dart';
import 'package:star_claude/domain/provider/user_provider.dart';
import 'package:star_claude/domain/provider/succ_data_provider.dart';
import 'package:star_claude/presentation/dataset/utils/data_utils.dart';
import 'package:star_claude/common/widgets/error/id_error.dart';

/// 数据展示页面基类
/// 封装了数据集页面的通用逻辑和UI组件
abstract class BaseDataPage<T extends StatefulWidget> extends State<T> {
  // ====================== 私有变量定义 ==============================
  // ============= 共享数据 ================
  /// 用户信息
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);
  /// succ数据信息
  SuccDataProvider get succDataProvider => Provider.of<SuccDataProvider>(context, listen: false);
  /// 日期选择器
  DateProvider get dateProvider => Provider.of<DateProvider>(context, listen: false);
  

  
  /// 从飞书获取的成功数据列表
  List<SuccDataEntity> _succDataList = [];
  
  /// 加载状态标志
  bool _isLoading = false;
  
  /// 错误信息
  String? _errorMessage;

  /// 是否显示身份错误提示
  bool _showIdError = false;

  // ====================== 公共核心变量定义 ==========================

  /// 获取需要展示的数据列表
  List<SuccDataEntity> get dataList => _succDataList;
  
  /// 获取完整数据列表（为子类提供访问原始数据的方式）
  List<SuccDataEntity> get fullDataList => _succDataList;
  
  /// 获取加载状态
  bool get isLoading => _isLoading;
  
  /// 获取错误信息
  String? get errorMessage => _errorMessage;

  // ====================== 私有函数定义 ==============================

  /// 本地数据库仓库实例
  final SuccDbDataRepository _succDbDataRepository = SuccDbDataRepository();
  
  /// 从本地数据库加载当前用户对应职业的数据
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 检查用户是否已登录
      if (!userProvider.isLoggedIn) {
        setState(() {
          _errorMessage = '用户未登录，请先登录';
          _isLoading = false;
        });
        return;
      }

      final currentUser = userProvider.currentUser;
      final userName = currentUser.fullName;
      final jobName = currentUser.job;

      // 根据职业名称确定要查询的字段
      String whereClause = '';
      List<String> whereArgs = [];
      
      // 获取日期范围
      DateTime rangeStart = dateProvider.rangeStart;
      DateTime rangeEnd = dateProvider.rangeEnd;
      
      if (jobName=='流量端') {
        whereClause = 'succ_ll = ?';
        whereArgs = [userName];
      } else if (jobName=='承接端') {
        whereClause = 'succ_cj = ?';
        whereArgs = [userName];
      } else if (jobName=='直销端') {
        whereClause = 'succ_zx = ?';
        whereArgs = [userName];
      } else if (jobName=='转化端') {
        whereClause = 'succ_zh = ?';
        whereArgs = [userName];
      }

      // 从本地数据库获取数据并使用日期范围过滤
      final succDataList = await _succDbDataRepository.querySuccData(whereClause, whereArgs).then((list) => list.where((data) {
        DateTime dataDate = data.classDate;
        return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
               dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
      }).toList());

      if (mounted) {
        // 更新到共享数据提供器，方便其他组件使用
        succDataProvider.setSuccDataList(succDataList);
        // 更新到组件内部状态
        setState(() {
          _succDataList = succDataList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载数据失败：${e.toString()}';
          _isLoading = false;
        });
      }
      print('Failed to load data: $e');
    }
  }

  /// 编辑按钮点击事件
  void _onEditPressed(SuccDataEntity succData) {
    // 使用DataUtils工具类处理编辑操作
    DataUtils.showEditDialogAndEdit(context, userProvider.currentUser, succData, (updatedItem) {
      // 找到被编辑的项目在列表中的索引
      final index = _succDataList.indexWhere((element) => element.studentName == succData.studentName);
      if (index != -1) {
        // 更新本地列表中的数据
        setState(() {
          _succDataList[index] = updatedItem;
          // 同步更新共享数据
          Provider.of<SuccDataProvider>(context, listen: false)
              .setSuccDataList(List.from(_succDataList));
        });
      }
    });
  }

  /// 删除按钮点击事件
  void _onDeletePressed(SuccDataEntity succData) {
    // 使用DataUtils工具类处理删除操作
    DataUtils.showDeleteSuccData(context, succData, () {
      print(succData);
      // 从本地列表中删除数据
      setState(() {
        _succDataList.removeWhere((element) => element.studentName == succData.studentName);
        // 同步更新共享数据
        Provider.of<SuccDataProvider>(context, listen: false)
            .setSuccDataList(List.from(_succDataList));
      });
    });
  }
  
  /// 添加新数据按钮点击事件
  void _onAddNewPressed() {
    // 处理上传操作
    DataUtils.showAddNewDialog(context, userProvider.currentUser, (newItem) {
      // 添加新数据到本地列表
      setState(() {
        _loadData();
      });
    }, dateProvider.selectedDateStr);
  }

  /// 刷新或上传数据按钮点击事件
  Widget _loadText(BuildContext context) {
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
            userProvider.currentUser.job == '数据端'||userProvider.currentUser.job == '直销端' ? 
              _onAddNewPressed() :
              setState(() {_showIdError = true;});
              // 1秒后自动隐藏错误提示
              Future.delayed(const Duration(seconds: 1), (){
                if (mounted) {
                  setState(() {_showIdError = false;});
                }
              }
            );
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

  /// 分隔线 
  Widget _buildSeparator() {
    return Container(
      height: 1, 
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
    );
  }

  /// 单个数据项 -- 删除 和 编辑
  Widget _buildDataItem(SuccDataEntity succData, int index) {
    return Container(
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
        title: Text(
          '${succData.studentName}${succData.c0 == 1 ? ' (C0)' : succData.c1 == 1 ? ' (C1)' : ''}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 4,
          ),
        ),
        subtitle: getSubtitle(succData),

        // 右侧操作按钮
        trailing:OperateButton(actionButtons: [
            IconButton(
              icon: Icon(Icons.edit_outlined),
              color: Colors.white, // 编辑
              onPressed: () => _onEditPressed(succData),
            ),
            IconButton(
              icon: Icon(Icons.delete_outlined),
              color: Colors.white, // 删除
              onPressed: () {
                // 流量端和承接端不能使用删除功能
                if (userProvider.currentUser.job == '流量端' ||
                    userProvider.currentUser.job == '承接端') {
                  if (mounted) {
                    setState(() {
                      _showIdError = true;
                    });
                    // 1秒后自动隐藏错误提示
                    Future.delayed(const Duration(seconds: 1), () {
                      if (mounted) {
                        setState(() {
                          _showIdError = false;
                        });
                      }
                    });
                  }
                } else {
                  _onDeletePressed(succData);
                }
              },
            ),
        ]),
      ),
    );
  }
  
  /// 重构UI - 包含加载状态和错误处理
  Widget _loadContent() {
    // 显示加载指示器
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              '正在加载数据...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }
    
    // 显示错误信息
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent,
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                errorMessage!, 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
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
    
    // 显示数据列表
    return _buildContent();
  }

  /// 正常UI - 仅显示数据内容
  Widget _buildContent() {
    // 显示空数据提示
    if (dataList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 48,
              color: Colors.white30,
            ),
            SizedBox(height: 16),
            Text(
              '暂无相关数据',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    // 显示数据列表
    return ListView.separated(
      itemCount: dataList.length,
      separatorBuilder: (context, index) => _buildSeparator(),
      itemBuilder: (context, index) {
        return _buildDataItem(dataList[index], index);
      },
    );
  }

  // ====================== 核心构建逻辑 ==============================

  /// 生命周期初始化方法
  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _succDataList = Provider.of<SuccDataProvider>(context, listen: false).succDataList;
    // 初始化时不自动加载数据，等待用户手动触发
  }

  /// 依赖项变化时调用
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<UserProvider>(context, listen: false);
    //_loadData();
  }
  
  /// 组件销毁时调用
  @override
  void dispose() {
    super.dispose();
    // 确保资源被正确释放
  }

  /// 获取副标题文本(子类必须实现)
  Widget getSubtitle(SuccDataEntity succData);

  /// 构建页面主体内容
  /// 该方法是页面的主要入口，构建整个页面的布局和内容
  /// 参数: 无参数，但需要子类实现getSubtitle方法来提供副标题文本
  /// 返回: 返回一个Scaffold组件，包含数据列表和底部操作按钮
  Widget buildPage() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _loadContent()),
              _loadText(context),
            ],
          ),
          if (_showIdError) IdError(),
        ],
      ),
    );
  }
}
