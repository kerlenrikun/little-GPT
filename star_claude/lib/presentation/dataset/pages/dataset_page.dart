import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:star_claude/presentation/dataset/utils/top_date.dart';
import 'package:star_claude/presentation/dataset/utils/top_tabs.dart';
import 'package:star_claude/presentation/dataset/widgets/advance.dart';
import 'package:star_claude/presentation/dataset/widgets/common.dart';
import 'package:star_claude/domain/provider/succ_data_provider.dart';
import 'package:star_claude/domain/entities/data/succ_data.dart';
import 'package:star_claude/domain/provider/date_provider.dart';

import 'package:star_claude/common/__init__.dart';
import 'package:star_claude/core/configs/__init__.dart';
import 'package:star_claude/presentation/dataset/widgets/c0.dart';
import 'package:star_claude/presentation/dataset/widgets/c1.dart';
import 'package:star_claude/presentation/dataset/widgets/sort.dart';

class DatasetPage extends StatefulWidget {
  const DatasetPage({super.key});
  
  @override
  State<DatasetPage> createState() => _DatasetPageState();
}


class _DatasetPageState extends State<DatasetPage> with SingleTickerProviderStateMixin {
  // 初始化TabController为null，然后在initState中创建
  TabController? _tabController;

  // 处理日期选择变化的回调函数
  void _handleDateSelected(DateTime selectedDay) {
    setState(() {
      // 将选中的日期存储到DateProvider中
    Provider.of<DateProvider>(context, listen: false).setSelectedDate(selectedDay);
    });
  }
  
  // 处理范围选择变化的回调函数
  void _handleRangeSelected(DateTime start, DateTime end) {
    setState(() {
      // 将选中的日期范围存储到DateProvider中
      Provider.of<DateProvider>(context, listen: false).setDateRange(start, end);
    });
  }


  @override
  void initState() {
    super.initState();
    // 确保在initState中正确初始化TabController
    _tabController = TabController(length: 5, vsync: this);
  }
  
  @override
  void dispose() {
    // 在组件销毁时释放TabController资源
    _tabController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // 顶部
      appBar: BasicAppBar(
        title: Transform.scale(
          scale: 0.58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(AppImages.logo),
              SizedBox(width: 15),
              SvgPicture.asset(AppVectors.logo),
            ],
          ),
        ),
      ),
      // 枝干
      body: Stack(
        children: [
          // 背景
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(AppVectors.homeTopPattern,),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SvgPicture.asset(AppVectors.homeBottomPattern),
          ),
          
          // 内容
          Column(
          children: [
            TopDate(onDateSelected: _handleDateSelected, onRangeSelected: _handleRangeSelected),
            
            // 顶部Tab
            SingleChildScrollView(
              child: Column(
                children: [
                    // 确保TabController不为空时再使用
                    _tabController != null ? TopTabs(controller: _tabController!) : Container(),
                  ],
              ),
            ),
            
            // Tab内容区域
            Expanded(
              child: _tabController != null ? TabBarView(
                controller: _tabController,
                children: [
                  // Common 标签页
                  CommonPage(),
                  // Advance 标签页 - 显示学生列表
                  AdvancePage(),
                  // C 0 标签页
                  C0Page(),
                  // C 1 标签页
                  C1Page(),
                  // 排名页
                  SortPage(),
                ],
              ) : Container(),
            ),
          ],
        ),
      ]),
    );
  }
}
