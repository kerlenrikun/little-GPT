// ignore_for_file: must_be_immutable, prefer_final_fields, unused_field, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:star_claude/core/configs/theme/app_colors.dart';
import 'package:star_claude/core/configs/assets/app_vector.dart';

class ButtonNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabChange;

  ButtonNavBar({super.key, required this.onTabChange, this.currentIndex = 0});

  @override
  State<ButtonNavBar> createState() => _ButtonNavBarState();
}

class _ButtonNavBarState extends State<ButtonNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onTabChange(int index){
    setState(() {
      _selectedIndex = index;
    });
    widget.onTabChange(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: GNav(
        onTabChange: _onTabChange,
        // 默认颜色
        color: Colors.grey[400]?.withOpacity(0.5), 
        // 选中的图标和文字颜色
        activeColor: Colors.white.withOpacity(0.9), 
        // 选中的边框颜色
        //tabActiveBorder: Border.all(color: AppColors.primary), 
        // 选中的背景色
        tabBackgroundColor: AppColors.primary, // Colors.transparent, 
        // 圆角
        tabBorderRadius: 12, 
        // 对齐方式
        mainAxisAlignment: MainAxisAlignment.center, 
        // 内边距
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
        tabs: [
          // 主页导航项
          GButton(
            icon: Icons.home, 
            text: ' 数据',
          ),
          // 选择ID导航项
          GButton(
            icon: Icons.auto_awesome, 
            text: ' 私域',
          ),
          // 个人资料导航项
          GButton(
            icon: Icons.person, 
            text: ' 我的',
          ),
        ],
      ),
    );
  }
}
