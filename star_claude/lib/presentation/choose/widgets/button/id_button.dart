// ignore_for_file: unused_element

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:star_claude/core/configs/__init__.dart';

class IdButton extends StatelessWidget {
  final String appIcon;
  final String appText;
  final double scale;
  final bool isSelected; // 添加是否选中的状态
  final bool otherSelected; // 添加其他按钮是否选中的状态
  final VoidCallback onTap; // 添加点击回调

  const IdButton({
    required this.appIcon,
    required this.appText,
    required this.scale,
    required this.isSelected, // 必传参数
    required this.otherSelected, //必传参数
    required this.onTap, // 必传参数
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final childWidget = // 按钮内部
    ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        // 形状
        child: Container(
          // 选中时的大小变化
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 选中时的色调变化
            color: isSelected
                ? Color(0xff00aeec).withOpacity(0.6)
                : Color(0xff30393c).withOpacity(0.6),
          ),
          // 图标
          child: Transform.scale(
            scale: isSelected
                ? scale - 0.05
                :scale ,// 选中时放大,
            child: SvgPicture.asset(appIcon),
          ),
        ),
      ),
    );

    // 按钮边缘羽化
    /// colors数组 : 定义了渐变的颜色序列
    ///   起始颜色：完全透明（Colors.transparent）
    ///   中间颜色：仍然是完全透明（Colors.transparent）
    ///   结束颜色：半透明黑色（Colors.black.withOpacity(0.4)）
    /// stops数组 : 定义了颜色渐变的位置：
    ///   0.0: 渐变的起点（中心位置）
    ///   0.8: 中间点（距离中心80%的位置）
    ///   1.0: 渐变的终点（边缘位置）
    final borderWidget = // 按钮边缘（渐变遮罩）
    ClipOval(
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.transparent,
              Colors.black.withOpacity(0.4),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // 按钮
          Stack(
            children: [
              // 按钮内部
              childWidget,
              // 按钮边缘
              borderWidget,
            ],
          ),
          SizedBox(height: 8),
          // 内容
          Transform.scale(
            scale: isSelected
                ? 1
                : otherSelected
                ? 0.85
                : 0.9,
            child: Container(
              // 添加阴影效果
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: isSelected ? 6 : 5,
                    offset: Offset(0, 4), // 阴影位置
                  ),
                ],
              ),
              child: SvgPicture.asset(
                appText,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
