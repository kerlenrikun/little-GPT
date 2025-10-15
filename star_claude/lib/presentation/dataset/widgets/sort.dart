import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import 'package:star_claude/core/configs/__init__.dart';
import 'package:star_claude/data/repository/common_db_data_repository.dart';
import 'package:star_claude/data/repository/succ_db_data_repository.dart';
import 'package:star_claude/data/repository/user_db_repository.dart';
import 'package:star_claude/presentation/dataset/utils/data_utils.dart';

import 'package:star_claude/domain/__init__.dart';
import 'package:star_claude/common/__init__.dart';
import 'common.dart';

// =========== 状态管理 ===========
enum LoadingState {
    idle,
    loading,
    loaded,
    error
  }

class SortPage extends StatefulWidget {
  const SortPage({super.key});
  
  @override
  State<SortPage> createState() => _SortPageState();
  
}

class _SortPageState extends State<SortPage> {
  // =========== 共享变量 ===========
  UserProvider get userProvider =>
      Provider.of<UserProvider>(context, listen: false);
  UserEntity get currentUser => userProvider.currentUser;

  DateProvider get dateProvider =>
      Provider.of<DateProvider>(context, listen: false);

  CommonDataProvider get commonDataProvider =>
      Provider.of<CommonDataProvider>(context, listen: false);

  LoadingState _loadingState = LoadingState.idle;
  String _errorMessage = '';

  // =========== 核心变量 ===========
  final DbUserRepository _dbUserRepository = DbUserRepository();
  final CommonDbDataRepository _commonDbDataRepository = CommonDbDataRepository();
  final SuccDbDataRepository _succDbDataRepository = SuccDbDataRepository();

  // 端口和排名相关变量
  PortType _selectedPortType = PortType.all;
  String _selectedRankingFactor = '推流';

  // 数据缓存
  List<UserEntity> _userList = [];
  Map<String, List<int>> _userDataMap = {};

  @override
  void initState() {
    super.initState();
    // 确保在initState完成后再加载数据，避免访问继承widget过早的问题
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  // 加载数据并计算
  Future<void> _loadData() async {
    if (_loadingState == LoadingState.loading) return;

    setState(() {
      _loadingState = LoadingState.loading;
      _errorMessage = '';
    });

    try {
      // 使用DataUtils提供的带加载状态的执行方法
      await DataUtils.executeWithLoading(
        context, 
        () async {
          // 1. 加载用户列表
          _userList = await _dbUserRepository.getAllUsers();
          // 2. 根据当前选择的端口类型和排名要素重新计算数据
          await _recalculateDataByFactor();
          // 3. 获取总体数据
          await CommonPage.getTotalData(
            currentUser,
            _getPortTypeString(_selectedPortType),
            _selectedRankingFactor,
            dateProvider.selectedDateStr,
            _commonDbDataRepository,
            _succDbDataRepository,
            commonDataProvider,
          );
        },
        // 自定义加载指示器
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );

      if (mounted) {
        setState(() {
          _loadingState = LoadingState.loaded;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载数据失败：${e.toString()}';
          _loadingState = LoadingState.error;
        });
      }
      print('Failed to load data: $e');
    }
  }

  // 根据排名要素重新计算数据
  Future<void> _recalculateDataByFactor() async {
    final selectedPortType = _getPortTypeString(_selectedPortType);
    final selectedDate = dateProvider.selectedDateStr;
    final Map<String, List<int>> tempDataMap = {};

    // 过滤用户列表
    final filteredUsers = _filterUsers(_userList, _selectedPortType);

    // 逐个计算用户数据
    for (var user in filteredUsers) {
      final userData = await CommonPage.userDataSum(
        user,
        selectedPortType,
        _selectedRankingFactor,
        selectedDate,
        dateProvider.rangeStart,
        dateProvider.rangeEnd,
        _commonDbDataRepository,
        _succDbDataRepository,
      );
      tempDataMap[user.fullName] = [userData[0], userData[1], 0];
    }

    setState(() {
      _userDataMap = tempDataMap;
    });
  }

  // 根据端口类型过滤用户列表
  List<UserEntity> _filterUsers(List<UserEntity> users, PortType portType) {
    if (portType == PortType.all) {
      return users;
    }

    final portTypeStr = _getPortTypeString(portType);
    return users.where((user) => user.allowJob[portTypeStr] == 1).toList();
  }

  // 将PortType枚举转换为字符串
  String _getPortTypeString(PortType portType) {
    switch (portType) {
      case PortType.all:
        return '全部';
      case PortType.ll:
        return '流量端';
      case PortType.cj:
        return '承接端';
      case PortType.zx:
        return '直销端';
      case PortType.zh:
        return '转化端';
    }
  }

  // 获取指定端口类型的排名要素列表
  List<String> _getRankingFactorsForPortType(PortType portType) {
    switch (portType) {
      case PortType.ll:
        return ['推流', '加粉'];
      case PortType.cj:
        return ['加粉', '推微'];
      case PortType.zx:
        return ['直销'];
      case PortType.zh:
        return ['中级班', '月训班'];
      default:
        return ['推流', '加粉', '推微', '直销', '中级班', '月训班'];
    }
  }

  /// 单个数据项主文字
  Widget _title(UserEntity user) {
    return Row(
      children: [
        // name
        Text(
          user.fullName.length < 3 ? user.fullName.padRight(4) : user.fullName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 4,
          ),
        ),
        SizedBox(width: 30),
        // 1号
        Expanded(
          child: FutureBuilder<List<int>>(
            future: CommonPage.userDataSum(
              user,
              _getPortTypeString(_selectedPortType),
              _selectedRankingFactor,
              dateProvider.selectedDateStr,
              dateProvider.rangeStart,
              dateProvider.rangeEnd,
              _commonDbDataRepository,
              _succDbDataRepository,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  '错误',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                );
              } else {
                // 其他端口显示数值
                return Row(
                  children: [
                    Text(
                      '$_selectedRankingFactor:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${snapshot.data?[0] ?? 0}',
                      style: TextStyle(
                        fontSize: snapshot.data?[0] != 0 ? 14 : 12,
                        fontWeight: snapshot.data?[0] != 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: snapshot.data?[0] != 0
                            ? AppColors.primary
                            : Colors.grey,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
  
  /// 单个数据项副文字
  Widget _subtitle(UserEntity user) {
    String sub = '';
    if (currentUser.job == '数据端') {
      for (var entry in user.allowJob.entries) {
        if (entry.value == 1) {sub += '${entry.key.substring(0, 2)} ';}}
    } else {
      if (user.allowJob['流量端'] == 1 && _selectedPortType == PortType.ll) {
        sub += '流量 ';
      }
      if (user.allowJob['承接端'] == 1 && _selectedPortType == PortType.cj) {
        sub += '承接 ';
      }
      if (user.allowJob['直销端'] == 1 && _selectedPortType == PortType.zx) {
        sub += '直销 ';
      }
      if (user.allowJob['转化端'] == 1 && _selectedPortType == PortType.zh) {
        sub += '转化 ';
      }
    }
    return Text(
      sub,
      style: TextStyle(fontSize: 12, height: 2),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildUserItem(UserEntity user, int index) {
    final portTypeStr = _getPortTypeString(_selectedPortType);
    if (_selectedPortType != PortType.all && user.allowJob[portTypeStr] != 1) {
      return Container();
    }

    return Container(
      padding: const EdgeInsets.only(top: 4.0),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
      child: ListTile(
        minTileHeight: 0,
        leading: Container(
          width: 30,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xffB3B3B3),
                letterSpacing: 4,
              ),
            ),
          ),
        ),
        title: _title(user),
        subtitle: _subtitle(user),
        // 右侧操作按钮
        trailing: null,
      ),
    );
  }

  // 构建端口类型选择器
  Widget _buildPortTypeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 端口类型选择器（与common.dart一致）
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('端口：', style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(width: 8),
              DropdownButton<PortType>(
                value: _selectedPortType,
                dropdownColor: Colors.black87,
                iconEnabledColor: Colors.white,
                style: TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (PortType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPortType = newValue;
                      // 获取新端口类型的默认排名要素
                      final rankingFactors = _getRankingFactorsForPortType(newValue);
                      _selectedRankingFactor = rankingFactors.isNotEmpty ? rankingFactors[0] : '推流';
                      // 直接重新加载数据
                      _loadData();
                    });
                  }
                },
                items: PortType.values.map((PortType type) {
                  String displayText = '';
                  switch (type) {
                    case PortType.all:
                      displayText = '全部';
                      break;
                    case PortType.ll:
                      displayText = '流量端';
                      break;
                    case PortType.cj:
                      displayText = '承接端';
                      break;
                    case PortType.zx:
                      displayText = '直销端';
                      break;
                    case PortType.zh:
                      displayText = '转化端';
                      break;
                  }
                  return DropdownMenuItem<PortType>(
                    value: type,
                    child: Text(displayText),
                  );
                }).toList(),
              ),
            ],
          ),
          SizedBox(width: 35,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('要素：', style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedRankingFactor,
                dropdownColor: Colors.black87,
                iconEnabledColor: Colors.white,
                style: TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRankingFactor = newValue;
                      _recalculateDataByFactor();
                    });
                  }
                },
                items: _getRankingFactorsForPortType(_selectedPortType).map((String factor) {
                  return DropdownMenuItem<String>(
                    value: factor,
                    child: Text(factor),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建内容区域
  Widget _buildContent() {
    // 过滤用户列表
    final filteredUsers = _filterUsers(_userList, _selectedPortType);
    
    // 按数据值排序
    filteredUsers.sort((a, b) {
      final dataA = _userDataMap[a.fullName]?[0] ?? 0;
      final dataB = _userDataMap[b.fullName]?[0] ?? 0;
      return dataB.compareTo(dataA); // 降序排列
    });

    // 检查是否有数据
    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 48, color: Colors.white30),
            SizedBox(height: 16),
            Text(
              '没有找到符合条件的用户数据',
              style: TextStyle(color: Colors.white54, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '请尝试切换端口类型或排名要素',
              style: TextStyle(color: Colors.white30, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        
        // 列表头部
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              SizedBox(width: 35),
            ],
          ),
        ),

        // 用户列表
        Expanded(
          child: ListView.separated(
            itemCount: filteredUsers.length,
            separatorBuilder: (context, index) => DataUtils.buildSeparator(),
            itemBuilder: (context, index) {
              return _buildUserItem(filteredUsers[index], index);
            },
          ),
        ),
      ],
    );
  }

  // 构建加载状态显示
  Widget _buildLoadingState() {
    switch (_loadingState) {
      case LoadingState.loading:
        return DataUtils.buildLoadingIndicator('加载中...');
      case LoadingState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              SizedBox(height: 16),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: _loadData,
                child: Text('重试', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        );
      case LoadingState.loaded:
        return _buildContent();
      default:
        return Container();
    }
  }

  /// 刷新数据按钮点击事件
  Widget _loadText(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You  Can:',
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 端口类型和排名要素选择器
            _buildPortTypeSelector(),
            // 内容区域
            Expanded(child: _buildLoadingState()),
            // 刷新数据按钮
            _loadText(context),
          ],
        ),
      ),
    );
  }
}
