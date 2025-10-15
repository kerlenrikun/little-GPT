import 'package:flutter/material.dart';
import 'package:star_claude/core/configs/theme/app_colors.dart';

class TopTabs extends StatelessWidget {
  final TabController controller;

  const TopTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      padding: EdgeInsets.only(top: 30, bottom: 15),
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      controller: controller,
      // 选中标签的颜色 - 使用白色
      labelColor: Colors.white,
      // 未选中标签的颜色 - 使用灰色
      unselectedLabelColor: const Color(0xff9e9e9e),
      // 自定义下划线指示器，使其只显示在文字下方
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primary, width: 3.0),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(3.5), bottomRight: Radius.circular(3.5))
      ),
      // 分割线的颜色
      dividerColor: Colors.transparent,
      // 标签内边距
      labelPadding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      // 标签样式
      indicatorPadding: EdgeInsets.symmetric(horizontal: 33.0),
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
      ),
      tabs: [
        Text('日常数据'),
        Text('进阶课'),
        Text('月训'),
        Text('中级'),
        Text('排名')
      ],
    );
  }
}