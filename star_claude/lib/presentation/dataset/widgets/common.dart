import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_claude/data/repository/common_db_data_repository.dart';
import 'package:star_claude/data/repository/succ_db_data_repository.dart';
import 'package:star_claude/data/repository/user_db_repository.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:star_claude/presentation/dataset/utils/data_utils.dart';

import 'package:star_claude/core/configs/__init__.dart';
import 'package:star_claude/domain/__init__.dart';
import 'package:star_claude/common/__init__.dart';

// 端口类型枚举
enum PortType {
  all, // 全部
  ll, // 流量端
  cj, // 承接端
  zx, // 直销端
  zh, // 转化端
}

class CommonPage extends StatefulWidget {
  const CommonPage({super.key});

  @override
  State<CommonPage> createState() => _CommonPStateState();
  
  // 静态方法：计算用户数据，供其他页面调用 - 支持日期范围
  static Future<List<int>> userDataSum(
    UserEntity targetUser,
    String portType,
    String rankingFactor,
    String selectedDate,
    DateTime rangeStart,
    DateTime rangeEnd,
    CommonDbDataRepository commonDbDataRepository,
    SuccDbDataRepository succDbDataRepository,
  ) async {
    try {
      int sumZero = 0;
      int sumOne = 0;
      
      if (portType == '流量端') {
        if (rankingFactor == '推流') {
          // 查询推流数据
          final dataList = await commonDbDataRepository.queryCommonData(
            'from_ll = ?', 
            [targetUser.fullName]
          ).then((list) => list.where((data) {
            DateTime dataDate = data.date;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd);
          }).toList());
          sumZero = dataList.fold(0, (acc, data) => acc + data.value);
        } else if (rankingFactor == '加粉') {
          // 查询加粉数据
          final dataList = await commonDbDataRepository.queryCommonData(
            'to_ll = ?', 
            [targetUser.fullName]
          ).then((list) => list.where((data) {
            DateTime dataDate = data.date;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd);
          }).toList());
          sumZero = dataList.fold(0, (acc, data) => acc + data.value);
        }
      } else if (portType == '承接端') {
        if (rankingFactor == '加粉') {
          // 查询加粉数据
          final dataList = await commonDbDataRepository.queryCommonData(
            'from_cj = ?', 
            [targetUser.fullName]
          ).then((list) => list.where((data) {
            DateTime dataDate = data.date;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd);
          }).toList());
          sumZero = dataList.fold(0, (acc, data) => acc + data.value);
        } else if (rankingFactor == '推微') {
          // 查询推微数据
          final dataList = await commonDbDataRepository.queryCommonData(
            'to_cj = ?', 
            [targetUser.fullName]
          ).then((list) => list.where((data) {
            DateTime dataDate = data.date;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd);
          }).toList());
          sumZero = dataList.fold(0, (acc, data) => acc + data.value);
        }
      } else if (portType == '直销端') {
        // 查询直销数据
        final succDataList = await succDbDataRepository.querySuccData(
          'succ_zx = ?', 
          [targetUser.fullName]
        ).then((list) => list.where((data) {
          DateTime dataDate = data.succDate;
          print(dataDate);
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd);
        }).toList());
        sumZero = succDataList.length;
      } else if (portType == '转化端') {
        if (rankingFactor == '中级班' || rankingFactor == '中级班/C1') {
          // 查询中级班数据
          final succDataList = await succDbDataRepository.querySuccData(
            'succ_zh = ? AND class_type = ?', 
            [targetUser.fullName, '中级班']
          ).then((list) => list.where((data) {
            DateTime dataDate = data.classDate;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd);
          }).toList());
          sumZero = succDataList.length;
        } else if (rankingFactor == '月训班' || rankingFactor == '月训班/C0') {
          // 查询月训班数据
          final succDataList = await succDbDataRepository.querySuccData(
            'succ_zh = ? AND class_type = ?', 
            [targetUser.fullName, '月训班']
          ).then((list) => list.where((data) {
            DateTime dataDate = data.classDate;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd);
          }).toList());
          sumZero = succDataList.length;
        }
      }
      
      return [sumZero, sumOne];
    } catch (e) {
      print('计算用户数据失败: $e');
      return [0, 0];
    }
  }
  
  // 静态方法：获取总数据，供其他页面调用
  static Future<void> getTotalData(
    UserEntity currentUser,
    String portType,
    String rankingFactor,
    String selectedDate,
    CommonDbDataRepository commonDbDataRepository,
    SuccDbDataRepository succDbDataRepository,
    CommonDataProvider commonDataProvider,
  ) async {
    try {
      int sumZero = 0;
      
      if (portType == '流量端') {
        if (rankingFactor == '推流') {
          final dataList = await commonDbDataRepository.queryCommonData(
            'date = ?', 
            [selectedDate]
          );
          sumZero = dataList.fold(0, (acc, data) => acc + data.value);
        } else if (rankingFactor == '加粉') {
          final dataList = await commonDbDataRepository.queryCommonData(
            'date = ?', 
            [selectedDate]
          );
          sumZero = dataList.fold(0, (acc, data) => acc + data.value);
        }
      } else if (portType == '承接端') {
        final dataList = await commonDbDataRepository.queryCommonData(
          'date = ?', 
          [selectedDate]
        );
        sumZero = dataList.fold(0, (acc, data) => acc + data.value);
      } else if (portType == '直销端') {
        final succDataList = await succDbDataRepository.querySuccData(
          'succ_date = ?', 
          [selectedDate]
        );
        sumZero = succDataList.length;
      } else if (portType == '转化端') {
        if (rankingFactor == '中级班' || rankingFactor == '中级班/C1') {
          final succDataList = await succDbDataRepository.querySuccData(
            'class_type = ? AND base_class_date = ?', 
            ['中级班', selectedDate]
          );
          sumZero = succDataList.length;
        } else if (rankingFactor == '月训班' || rankingFactor == '月训班/C0') {
          final succDataList = await succDbDataRepository.querySuccData(
            'class_type = ? AND base_class_date = ?', 
            ['月训班', selectedDate]
          );
          sumZero = succDataList.length;
        }
      }
      
      // 更新总数据
      commonDataProvider.totalData['总体'] = [sumZero, 0, 0];
    } catch (e) {
      print('获取总数据失败: $e');
    }
  }
  
  // 静态方法：构建副标题，供其他页面调用
  static Widget buildSubtitle(
    UserEntity user,
    String portType,
    String rankingFactor,
    Map<String, List<int>> itemDataMap,
  ) {
    List<int> userData = itemDataMap[user.fullName] ?? [0, 0, 0];
    
    return Row(
      children: [
        SizedBox(width: 35),
        Expanded(
          child: Text(
            '${userData[0]}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white30,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

}

class _CommonPStateState extends State<CommonPage> {
  // ====================== 私有变量定义 ==============================
  // =========== 共享变量 ===========
  UserProvider get userProvider =>
      Provider.of<UserProvider>(context, listen: false);
  UserEntity get currentUser => userProvider.currentUser;

  DateProvider get dateProvider =>
      Provider.of<DateProvider>(context, listen: false);

  /// 通用数据提供器实例
  CommonDataProvider get commonDataProvider =>
      Provider.of<CommonDataProvider>(context, listen: false);

  /// 通用数据列表
  List<CommonData> get commonDataList => commonDataProvider.commonDataList;

  /// 整体总数据
  Map<String, List<int>> get totalData => commonDataProvider.totalData;

  // =========== 简单变量 ===========
  bool _isLoading = false;
  bool _isDataLoading = false;
  String _errorMessage = '';

  /// 是否显示身份错误提示
  bool _showIdError = false;

  /// 当前选择的端口类型（数据端专用）
  PortType _selectedPortType = PortType.all;

  // =========== 核心变量 ===========

  /// 本地用户数据仓库实例
  final DbUserRepository _dbUserRepository = DbUserRepository();

  /// 通用数据存储库实例
  final CommonDbDataRepository _commonDbDataRepository =
      CommonDbDataRepository();

  /// 成功存储库实例
  final SuccDbDataRepository _succDbDataRepository = SuccDbDataRepository();

  // ====================== 私有函数定义 ==============================

  /// 端口类型选择器构建方法
  Widget _buildPortSelector() {
    if (currentUser.job != '数据端') {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('选择端口：', style: TextStyle(color: Colors.white, fontSize: 14)),
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
    );
  }

  /// 从本地数据库加载当前用户对应职业的数据
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final currentUser = userProvider.currentUser;
      final userJob = currentUser.job;
      // 根据职业名称确定要查询的字段
      if (userJob!.contains('数据')) {
        // 如果是数据端, 获取所有用户
        await _dbUserRepository.getAllUsers();

        // 从本地数据库获取通用数据
        final selectedDate = dateProvider.selectedDateStr;
        final result = await _commonDbDataRepository.queryCommonData(
          'date = ?',
          [selectedDate],
        );
        commonDataProvider.setCommonDataList(result);

        // 更新到组件内部状态
        if (mounted) {
          setState(() {
            _isLoading = false;
            _getTotalData('总体');
          });
        }
        return;
      }

      // 非数据端用户的处理 - 直接从本地数据库获取用户数据
      if (mounted) {
        // 更新头顶文字数据
        // 格式化日期为YYYY-MM-DD格式
        final selectedDate = dateProvider.selectedDateStr;

        // 构建本地数据库查询条件
        String whereClause = '';
        List<String> whereArgs = [];

        if (currentUser.job == '流量端') {
          whereClause = 'from_ll = ? OR to_ll = ?';
          whereArgs = [currentUser.fullName, currentUser.fullName];
        } else if (currentUser.job == '承接端') {
          whereClause = 'from_cj = ? OR to_cj = ?';
          whereArgs = [currentUser.fullName, currentUser.fullName];
        } else if (currentUser.job == '直销端') {
          whereClause = 'from_zx = ? OR to_zx = ?';
          whereArgs = [currentUser.fullName, currentUser.fullName];
        } else if (currentUser.job == '转化端') {
          whereClause = 'from_zh = ? OR to_zh = ?';
          whereArgs = [currentUser.fullName, currentUser.fullName];
        }

        // 添加日期过滤条件
        whereClause += ' AND date = ?';
        whereArgs.add(selectedDate);

        final result = await _commonDbDataRepository.queryCommonData(
          whereClause,
          whereArgs,
        );
        commonDataProvider.setCommonDataList(result);

        // 更新到组件内部状态
        setState(() {
          _isLoading = false;
          _getTotalData('总体');
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

  /// 单个数据项副文字
  Widget _subtitle(UserEntity user) {
    String sub = '';
    if (currentUser.job == '数据端') {
      for (var entry in user.allowJob.entries) {
        if (entry.value == 1) {
          sub += '${entry.key.substring(0, 2)} ';
        }
      }
    } else {
      if (user.allowJob['流量端'] == 1 && currentUser.job == '承接端') {
        sub += '流量 ';
      }
      if (user.allowJob['承接端'] == 1 && currentUser.job == '流量端') {
        sub += '承接 ';
      }
      if (user.allowJob['直销端'] == 1 && currentUser.job == '承接端') {
        sub += '直销 ';
      }
      if (user.allowJob['转化端'] == 1 && currentUser.job == '直销端') {
        sub += '转化 ';
      }
      if (user.allowJob['承接端'] == 1 && currentUser.job == '直销端') {
        sub += '承接 ';
      }
    }
    return Text(
      sub,
      style: TextStyle(fontSize: 12, height: 2),
      textAlign: TextAlign.left,
    );
  }

  /// 添加用户通用数据
  void _addUserCommonData(UserEntity targetUser) {
    // 调用DataUtils的添加功能
    DataUtils.showAddCommonDataDialog(context, currentUser, targetUser, (
      newData,
    ) {
      // 更新数据到数据库
      _commonDbDataRepository.addCommonData(newData);
      setState(() {
        // 重新计算数据
        _getTotalData('总体');
      });
    });
  }

  /// 计算指定用户的总数据值 - 直接从数据库获取，支持日期范围
  Future<List<int>> _userDataSum(
    UserEntity currentUser,
    UserEntity targetUser,
  ) async {
    try {
      /// 求和
      int sumZero = 0;
      int sumOne = 0;
      
      // 获取日期范围
      DateTime rangeStart = DateTime.parse(dateProvider.startedDateStr);
      DateTime rangeEnd = DateTime.parse(dateProvider.endDateStr);

      if (currentUser.job == '流量端') {
        // 流量端：推流（from me -> to 承接）和加粉（from 承接 -> to me）
        // 从本地数据库获取推流数据
        final flowData = await _commonDbDataRepository.queryCommonData(
          'from_ll = ? AND to_cj = ?',
          [
            currentUser.fullName,
            targetUser.fullName,
          ],
        ).then((list) => list.where((data) {
          DateTime dataDate = data.date;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());
        sumZero = flowData.fold(0, (acc, data) => acc + data.value);

        // 从本地数据库获取加粉数据
        final powderData = await _commonDbDataRepository.queryCommonData(
          'from_cj = ? AND to_ll = ?',
          [
            targetUser.fullName,
            currentUser.fullName,
          ],
        ).then((list) => list.where((data) {
          DateTime dataDate = data.date;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());
        sumOne = powderData.fold(0, (acc, data) => acc + data.value);
      } else if (currentUser.job == '承接端') {
        // 承接端：推微（from me -> to 直销）和加粉（from 流量 -> to me）
        // 从本地数据库获取推微数据
        final pushData = await _commonDbDataRepository.queryCommonData(
          'from_cj = ? AND to_zx = ?',
          [
            currentUser.fullName,
            targetUser.fullName,
          ],
        ).then((list) => list.where((data) {
          DateTime dataDate = data.date;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());
        sumZero = pushData.fold(0, (acc, data) => acc + data.value);

        // 从本地数据库获取加粉数据
        final powderData = await _commonDbDataRepository.queryCommonData(
          'from_cj = ? AND to_ll = ?',
          [
            currentUser.fullName,
            targetUser.fullName,
          ],
        ).then((list) => list.where((data) {
          DateTime dataDate = data.date;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());
        sumOne = powderData.fold(0, (acc, data) => acc + data.value);
      } else if (currentUser.job == '直销端') {
        // 格式化日期为YYYY-MM-DD格式
        final selectedDate = dateProvider.selectedDateStr;

        // 查询talk数据
        final talkData = await _commonDbDataRepository.queryCommonData(
          'from_cj = ? AND to_zx = ?',
          [targetUser.fullName, currentUser.fullName],
        ).then((list) => list.where((data) {
          DateTime dataDate = data.date;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());
        sumZero = talkData.fold(0, (acc, data) => acc + data.value);

        // 查询直销数据
        final directData = await _succDbDataRepository.querySuccData(
          'succ_zx = ? AND succ_cj = ?',
          [currentUser.fullName, targetUser.fullName],
        ).then((list) => list.where((data) {
          DateTime dataDate = data.classDate;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());
        sumOne = directData.length;
      } else if (currentUser.job == '转化端') {
        // 转化端：总带读和月训班
        final selectedDate = dateProvider.selectedDateStr;

        // 查询带读数据
        final readData = await _succDbDataRepository.querySuccData(
          'succ_zh = ?',
          [currentUser.fullName],
        ).then((list) => list.where((data) {
          DateTime dataDate = data.succDate;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());
        sumZero = readData.length;

        // 查询月训班数据
        final c0Data = await _succDbDataRepository.querySuccData(
          'succ_zh = ? AND class_type = ?',
          [currentUser.fullName, '月训班'],
        ).then((list) => list.where((data) {
          DateTime dataDate = data.classDate;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());
        sumOne = c0Data.length;
        // 查询中级班数据
        final c1Data = await _succDbDataRepository.querySuccData(
          'succ_zh = ? AND class_type = ?',
          [currentUser.fullName, '中级班'],
        ).then((list) => list.where((data) {
          DateTime dataDate = data.classDate;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());
        sumOne = c1Data.length;
      }

      return [sumZero, sumOne];
    } catch (e) {
      print('计算用户数据失败: $e');
      return [0, 0];
    }
  }

  /// 从数据库检查用户在日期范围内是否有填数据 - 支持日期范围
  Future<bool> _hasDataToday(String userName) async {
    try {
      final selectedDate = dateProvider.selectedDateStr;
      
      // 获取日期范围
      DateTime rangeStart = DateTime.parse(dateProvider.startedDateStr);
      DateTime rangeEnd = DateTime.parse(dateProvider.endDateStr);

      bool hasData = false;

      // 分别处理不同端口类型的数据查询
      switch (_selectedPortType) {
        case PortType.all:
          // 全部：分别查询common和succ表
          // 查询common表(流量端和承接端)
          final commonWhereClause = '(from_ll = ? OR from_cj = ?)';
          final commonWhereArgs = [userName, userName];
          final commonDataList = await _commonDbDataRepository.queryCommonData(
            commonWhereClause,
            commonWhereArgs,
          ).then((list) => list.where((data) {
            DateTime dataDate = data.date;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
          }).toList());

          // 查询succ表(直销端和转化端)
          final succWhereClause =
              '(succ_zx = ? OR succ_zh = ?)';
          final succWhereArgs = [userName, userName];
          final succDataList = await _succDbDataRepository.querySuccData(
            succWhereClause,
            succWhereArgs,
          ).then((list) => list.where((data) {
            DateTime dataDate = data.succDate;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
          }).toList());

          // 任一表有数据即认为用户已填写
          hasData = commonDataList.isNotEmpty || succDataList.isNotEmpty;
          break;

        case PortType.ll:
          // 流量端：从common表查询
          final llDataList = await _commonDbDataRepository.queryCommonData(
            'from_ll = ?',
            [userName],
          ).then((list) => list.where((data) {
            DateTime dataDate = data.date;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
          }).toList());
          hasData = llDataList.isNotEmpty;
          break;

        case PortType.cj:
          // 承接端：从common表查询
          final cjDataList = await _commonDbDataRepository.queryCommonData(
            'from_cj = ?',
            [userName],
          ).then((list) => list.where((data) {
            DateTime dataDate = data.date;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
          }).toList());
          hasData = cjDataList.isNotEmpty;
          break;

        case PortType.zx:
          // 直销端：从succ表查询
          final zxDataList = await _succDbDataRepository.querySuccData(
            'succ_zx = ?',
            [userName],
          ).then((list) => list.where((data) {
            DateTime dataDate = data.succDate;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
          }).toList());
          hasData = zxDataList.isNotEmpty;
          break;

        case PortType.zh:
          // 转化端：从succ表查询
          final zhDataList = await _succDbDataRepository.querySuccData(
            'succ_zh = ?',
            [userName],
          ).then((list) => list.where((data) {
            DateTime dataDate = data.succDate;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
          }).toList());
          hasData = zhDataList.isNotEmpty;
          break;
      }

      // 如果有数据，说明用户今天已填写
      return hasData;
    } catch (e) {
      print('检查用户数据失败: $e');
      // 发生错误时默认为未填写
      return false;
    }
  }

  /// 单个数据项主文字
  Widget _title(UserEntity user) {
    return Row(
      children: [
        Text(
          user.fullName.length < 3 ? user.fullName.padRight(4) : user.fullName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: 4,
          ),
        ),
        SizedBox(width: 35),
        // 1号
        Expanded(
          child: FutureBuilder<List<int>>(
            future: _userDataSum(currentUser, user),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  '错误',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                );
              } else {
                // 数据端特殊处理：显示已填/未填状态
                if (currentUser.job == '数据端') {
                  return FutureBuilder<bool>(
                    future: _hasDataToday(user.fullName),
                    builder: (context, filledSnapshot) {
                      // 等待状态直接返回空容器，避免UI闪烁
                      if (!filledSnapshot.hasData) {
                        return Container();
                      }

                      bool hasFilled = filledSnapshot.data ?? false;
                      return Row(
                        children: [
                          SizedBox(width: 24),
                          Text(
                            '状态: ',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            hasFilled ? '已填' : '未填',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: hasFilled
                                  ? AppColors.primary
                                  : Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }

                // 其他端口显示数值
                return Row(
                  children: [
                    Text(
                      '${JobUtils.job2Common(currentUser.job!)[0]} ',
                      style: TextStyle(
                        fontSize: 11,
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
        // 对于数据端用户，只显示1号词条，不显示2号词条，所以不需要这个间距
        currentUser.job == '数据端' ? Container() : SizedBox(width: 30),
        // 2 号
        // 对于数据端用户，不显示2号词条，使用占位符
        currentUser.job == '数据端'
            ? Container()
            : Expanded(
                child: FutureBuilder<List<int>>(
                  future: _userDataSum(currentUser, user),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        '错误',
                        style: TextStyle(fontSize: 11, color: Colors.red),
                      );
                    } else {
                      return Row(
                        children: [
                          Text(
                            '${JobUtils.job2Common(currentUser.job!)[1]} ',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${snapshot.data?[1] ?? 0}',
                            style: TextStyle(
                              fontSize: snapshot.data?[1] != 0 ? 14 : 12,
                              fontWeight: snapshot.data?[1] != 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: snapshot.data?[1] != 0
                                  ? AppColors.primary
                                  : Colors.white.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
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

  /// 单个数据项
  Widget _buildUserItem(UserEntity user, int index) {
    return Slidable(
      endActionPane: ActionPane(
        motion: StretchMotion(),
        extentRatio: 0.3, // 减小整体宽度，让图标更紧凑
        children: [
          SlidableAction(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            onPressed: (context) {
              userProvider.currentUser.job != '数据端'
                  ? _addUserCommonData(user)
                  : setState(() {
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
            },
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            icon: Icons.add,
          ),
        ],
      ),
      child: Container(
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
          title: _title(user),
          subtitle: _subtitle(user),
          // 右侧操作按钮
          trailing: null,
        ),
      ),
    );
  }

  /// 重构UI
  Widget _loadContent() {
    // 直接显示数据列表，不显示加载动画
    return FutureBuilder(
      future: _buildContent(),
      builder: (context, snapshot) {
        return snapshot.data ?? SizedBox.shrink();
      },
    );
  }

  /// 正常UI - 仅显示数据内容
  Future<Widget> _buildContent() async {
    // 显示空数据提示
    final users = await _dbUserRepository.getAllUsers();

    // 根据选择的端口类型筛选用户
    List<UserEntity> filteredUsers = List.from(users);
    
    filteredUsers = filteredUsers.where((user) {
      return switch (currentUser.job) {
        '流量端' => user.allowJob['承接端'] == 1,
        '承接端' => user.allowJob['流量端'] == 1 || user.allowJob['直销端'] == 1,
        '直销端' => user.allowJob['承接端'] == 1 || user.allowJob['转化端'] == 1, //统计talk数
        '转化端' => user.allowJob['转化端'] == 2, //等于2是不可能的，就是希望转化端不要看日常数据
        '数据端' => switch (_selectedPortType) {
          PortType.ll => user.allowJob['流量端'] == 1,
          PortType.cj => user.allowJob['承接端'] == 1,
          PortType.zx => user.allowJob['直销端'] == 1,
          PortType.zh => user.allowJob['转化端'] == 1,
          _ => true
        },
        _ => true // 默认情况下显示所有用户
      };
    }).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 48, color: Colors.white30),
            SizedBox(height: 16),
            Text(
              '你的团队伙伴还没有注册',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 检查当前用户是否是数据端
    final isDataPortUser = currentUser.job == '数据端';

    // 创建用户列表副本并进行排序
    List<UserEntity> sortedUserList = List.from(filteredUsers);

    if (isDataPortUser) {
      // 数据端用户：预加载已筛选用户的填写状态
      Map<String, bool> userDataStatus = {};
      for (var user in filteredUsers) {
        userDataStatus[user.fullName] = await _hasDataToday(user.fullName);
      }

      // 使用预加载的状态进行排序
      sortedUserList.sort((a, b) {
        bool aHasData = userDataStatus[a.fullName] ?? false;
        bool bHasData = userDataStatus[b.fullName] ?? false;

        // 未填写的排在前面
        if (!aHasData && bHasData) return -1;
        if (aHasData && !bHasData) return 1;

        // 如果填写状态相同，则按姓名排序
        return a.fullName.compareTo(b.fullName);
      });
    } else {
      // 非数据端保持原有排序逻辑
      sortedUserList.sort((a, b) {
        // 获取每个用户的数据列表
        List<int> aData = [0, 0, 0];
        List<int> bData = [0, 0, 0];

        // 计算数值之和
        int aSum = aData.fold(0, (sum, value) => sum + value);
        int bSum = bData.fold(0, (sum, value) => sum + value);

        // 从大到小排序
        return bSum.compareTo(aSum);
      });
    }

    // 构建内容
    Widget content = RefreshIndicator(
      onRefresh: () async {
        await _loadData();
      },
      child: ListView.separated(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sortedUserList.length,
        separatorBuilder: (context, index) => DataUtils.buildSeparator(),
        itemBuilder: (context, index) {
          return _buildUserItem(sortedUserList[index], index);
        },
      ),
    );

    // 如果是数据端用户，添加端口选择器
    if (isDataPortUser) {
      content = Column(
        children: [
          // 端口选择器
          _buildPortSelector(),
          Expanded(child: content),
        ],
      );
    }
    return content;
  }

  /// 整体总数据计算 - 直接从数据库获取
  Future<List<int>> _getTotalData(String dk) async {
    try {
      double sumZero = 0; // 已填数量
      double sumOne = 0; // 未填数量
      
      // 获取日期范围
      DateTime rangeStart = dateProvider.rangeStart;
      DateTime rangeEnd = dateProvider.rangeEnd;

      if (currentUser.job != '数据端') {
        // 查询日期范围内的数据
        final dataList = await _commonDbDataRepository.getAllCommonData().
        then((list) => list.where((data) {
          DateTime dataDate = data.date;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());

        // 根据用户角色和端口类型计算相应的总和
        if (currentUser.job == '流量端') {
          // 流量端：推流和加粉总数
          sumZero = dataList
              .where((data) => data.fromLL == currentUser.fullName)
              .fold(0, (sum, var data) => sum + (data.value));
          sumOne = dataList
              .where((data) => data.toLL == currentUser.fullName)
              .fold(0, (sum, var data) => sum + (data.value));
        } else if (currentUser.job == '承接端') {
          // 承接端：加粉和推微总数
          sumOne = dataList
              .where(
                (data) =>
                    data.fromCj == currentUser.fullName && data.toLL != '',
              )
              .fold(0, (sum, var data) => sum + (data.value));
          sumZero = dataList
              .where(
                (data) =>
                    data.fromCj == currentUser.fullName && data.toZx != '',
              )
              .fold(0, (sum, var data) => sum + (data.value));
        } else if (currentUser.job == '直销端') {
          // 直销端：总talk和总直销
          sumZero = dataList
              .where((data) => data.fromZx == currentUser.fullName)
              .fold(0, (sum, var data) => sum + (data.value));
          // 查询直销数据
          final succDataList = await _succDbDataRepository.querySuccData(
            'succ_zx = ? ',
            [currentUser.fullName],
          ).then((list) => list.where((data) {
            DateTime dataDate = data.classDate;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
          }).toList());
          sumOne = succDataList.length.toDouble();
        } else if (currentUser.job == '转化端') {
          // 查询转化数据
          final succDataList = await _succDbDataRepository.querySuccData(
            'succ_zh = ? AND c0 = 1 ',
            [currentUser.fullName],
          ).then((list) => list.where((data) {
            DateTime dataDate = data.classDate;
            return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                   dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
          }).toList());
          // 转化端：总带读和月训班
          sumZero = succDataList.length.toDouble();
          sumOne = succDataList.length.toDouble();
        }
      } else {
        // 数据端特殊处理：根据端口选择器筛选用户并计算已填写和未填写的用户数量
        // 使用本地数据库获取用户数据
        final allUsers = await _dbUserRepository.getAllUsers();

        // 根据选择的端口类型筛选用户
        List<UserEntity> filteredUsers = allUsers;
        if (_selectedPortType != PortType.all) {
          filteredUsers = allUsers.where((user) {
            switch (_selectedPortType) {
              case PortType.ll:
                return user.allowJob['流量端'] == 1;
              case PortType.cj:
                return user.allowJob['承接端'] == 1;
              case PortType.zx:
                return user.allowJob['直销端'] == 1;
              case PortType.zh:
                return user.allowJob['转化端'] == 1;
              default:
                return true;
            }
          }).toList();
        }

        // 根据端口类型查询已填写数据的用户
        Set<String> filledUsers = {};

        if (_selectedPortType == PortType.all ||
            _selectedPortType == PortType.ll ||
            _selectedPortType == PortType.cj) {
          // 查询common表数据(流量端和承接端)
        final commonDataList = await _commonDbDataRepository.queryCommonData(
          'date = ?',
          [dateProvider.selectedDateStr],
        ).then((list) => list.where((data) {
          DateTime dataDate = data.date;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());

          for (var data in commonDataList) {
            if ((_selectedPortType == PortType.all ||
                    _selectedPortType == PortType.ll) &&
                data.fromLL.isNotEmpty) {
              filledUsers.add(data.fromLL);
            }
            if ((_selectedPortType == PortType.all ||
                    _selectedPortType == PortType.cj) &&
                data.fromCj.isNotEmpty) {
              filledUsers.add(data.fromCj);
            }
          }
        }

        if (_selectedPortType == PortType.all ||
            _selectedPortType == PortType.zx ||
            _selectedPortType == PortType.zh) {
          // 查询succ表数据(直销端和转化端)
        final succDataList = await _succDbDataRepository.querySuccData(
          'succ_date = ?',
          [dateProvider.selectedDateStr],
        ).then((list) => list.where((data) {
          DateTime dataDate = data.succDate;
          return dataDate.isAfter(rangeStart.subtract(Duration(days: 1))) && 
                 dataDate.isBefore(rangeEnd.add(Duration(days: 1)));
        }).toList());

          for (var data in succDataList) {
            if ((_selectedPortType == PortType.all ||
                    _selectedPortType == PortType.zx) &&
                data.succZx.isNotEmpty) {
              filledUsers.add(data.succZx);
            }
            if ((_selectedPortType == PortType.all ||
                    _selectedPortType == PortType.zh) &&
                data.succZh.isNotEmpty) {
              filledUsers.add(data.succZh);
            }
          }
        }

        // 获取已筛选用户中的已填写用户数量
        Set<String> filteredFilledUsers = {};
        for (var user in filteredUsers) {
          if (filledUsers.contains(user.fullName)) {
            filteredFilledUsers.add(user.fullName);
          }
        }

        // 计算已填写和未填写的数量
        sumZero = filteredFilledUsers.length.toDouble();
        sumOne = (filteredUsers.length - sumZero).toDouble();

        // 确保未填数量不为负数
        if (sumOne < 0) {
          sumOne = 0;
        }
      }

      final result = [sumZero, sumOne, 0];
      return result.map((e) => e.toInt()).toList();
    } catch (e) {
      print('获取总数据失败: $e');
      return [0, 0, 0];
    }
  }

  /// 总数据显示
  Widget _allData(UserEntity user) {
    return Container(
      padding: EdgeInsets.only(left: 50, right: 45, top: 12, bottom: 12),
      child: FutureBuilder<List<int>>(
        future: _getTotalData('总体'),
        builder: (context, snapshot) {
          final data = snapshot.data ?? [0, 0, 0];
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 12),
              // 1号
              Row(
                children: [
                  Text(
                    switch (user.job) {
                      '流量端' => '总推流: ',
                      '承接端' => '总推微: ',
                      '直销端' => '总talk: ',
                      '转化端' => '总带读: ',
                      '数据端' => '已填写: ',
                      _ => '',
                    },
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    data[0].toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 30),
              // 2号
              Row(
                children: [
                  Text(
                    switch (user.job) {
                      '流量端' => '总加粉: ',
                      '承接端' => '总加粉: ',
                      '直销端' => '总直销: ',
                      '转化端' => '月训班: ',
                      '数据端' => '未填写: ',
                      _ => '',
                    },
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    data[1].toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 30),
              // 3号
              Text(
                currentUser.job ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ====================== 核心构建逻辑 ===============================
  @override
  void initState() {
    super.initState();
    _isLoading = false;
    // 使用异步方式调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getTotalData('总体');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _allData(currentUser),
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
