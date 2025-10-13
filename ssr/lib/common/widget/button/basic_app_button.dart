import 'package:flutter/material.dart';

import 'package:ssr/core/config/theme/app_colors.dart';

/// 基于主题的基础按钮组件
///
/// 提供应用中统一风格的基础按钮，支持自定义高度和圆角
///
/// [参数说明]:
/// - [onPressed]: 点击按钮时的回调函数
/// - [title]: 按钮显示的文字内容
/// - [height]: 按钮高度，默认值为80
/// - [key]: 组件唯一标识
class BasicAppButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String title;
  final double? height;
  final double? width;
  final double? fontsize;
  final double? letterspacing;
  final Color? color;
  final Color? backgroundColor;
  final double? borderRadius;
  const BasicAppButton({
    required this.onPressed,
    required this.title,
    this.height,
    this.width,
    this.fontsize,
    this.letterspacing,
    this.color,
    this.borderRadius,
    this.backgroundColor,
    super.key,
  });

  @override
  State<BasicAppButton> createState() => _BasicAppButtonState();
}

class _BasicAppButtonState extends State<BasicAppButton> {
  bool _isHovered = false;
  void _onHoverChange(bool value) {
    setState(() {
      _isHovered = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // 按钮回调
      onPressed: widget.onPressed,
      // 鼠标悬停事件
      onHover: _onHoverChange,
      // 按钮装饰
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor ?? AppColors.primary,
        minimumSize: Size(widget.width ?? 279, widget.height ?? 85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.borderRadius ?? 28)),
      ),
      // 按钮文字
      child: Text(
        widget.title,
        style: TextStyle(
          color: _isHovered
              ? Colors.white
              : widget.color ?? Color(0xffe6f9e5),
          letterSpacing: widget.letterspacing ?? 2,
          fontWeight: FontWeight.w700,
          fontSize: widget.fontsize ?? 24,
          fontFamily: 'Satoshi'
        ),
      ),
    );
  }
}
