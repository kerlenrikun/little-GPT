import 'package:flutter/material.dart';

/// 悬停效果工具类 - 提供悬停交互效果
class HoverUtils {
  /// 单个控件的悬停效果组件
  /// [child] 要添加悬停效果的子组件
  /// [onHover] 悬停状态改变时的回调函数
  /// [hoverColor] 悬停时的背景颜色
  /// [hoverShadow] 悬停时的阴影
  /// [padding] 可选的内边距
  /// [borderRadius] 可选的圆角半径
  static Widget singleHoverWrapper({
    required Widget child,
    void Function(bool)? onHover,
    Color? hoverColor,
    BoxShadow? hoverShadow,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
  }) {
    return HoverWrapper(
      child: child,
      onHover: onHover,
      hoverColor: hoverColor,
      hoverShadow: hoverShadow,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
    );
  }

  /// 多个相似模块的悬停效果组件
  /// [children] 要添加悬停效果的子组件列表
  /// [onHoverChange] 悬停状态改变时的回调函数
  /// [hoverColor] 悬停时的背景颜色
  /// [hoverShadow] 悬停时的阴影
  /// [padding] 可选的内边距
  /// [borderRadius] 可选的圆角半径
  static List<Widget> multiHoverWrapper({
    required List<Widget> children,
    void Function(int, bool)? onHoverChange,
    Color? hoverColor,
    BoxShadow? hoverShadow,
    EdgeInsets? padding,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
  }) {
    return children.asMap().entries.map((entry) {
      int index = entry.key;
      Widget child = entry.value;
      
      return HoverWrapper(
        child: child,
        onHover: (hovering) {
          if (onHoverChange != null) {
            onHoverChange(index, hovering);
          }
        },
        hoverColor: hoverColor,
        hoverShadow: hoverShadow,
        margin: margin,
        padding: padding,
        borderRadius: borderRadius,
      );
    }).toList();
  }

  /// 创建带文本颜色变化的悬停文本
  /// [text] 文本内容
  /// [isHovering] 当前是否处于悬停状态
  /// [normalStyle] 正常状态下的文本样式
  /// [hoverStyle] 悬停状态下的文本样式
  static Widget hoverText({
    required String text,
    required bool isHovering,
    required TextStyle normalStyle,
    required TextStyle hoverStyle,
  }) {
    return Text(
      text,
      style: isHovering ? hoverStyle : normalStyle,
    );
  }
}

/// 悬停效果包装器组件
class HoverWrapper extends StatefulWidget {
  final Widget child;
  final void Function(bool)? onHover;
  final Color? hoverColor;
  final BoxShadow? hoverShadow;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;

  const HoverWrapper({
    Key? key,
    required this.child,
    this.onHover,
    this.hoverColor,
    this.hoverShadow,
    this.padding,
    this.margin,
    this.borderRadius,
  }) : super(key: key);

  @override
  _HoverWrapperState createState() => _HoverWrapperState();
}

class _HoverWrapperState extends State<HoverWrapper> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) {
        setState(() {
          _isHovering = true;
        });
        if (widget.onHover != null) {
          widget.onHover!(true);
        }
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
        if (widget.onHover != null) {
          widget.onHover!(false);
        }
      },
      child: Container(
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.hoverColor != null 
              ? (_isHovering ? widget.hoverColor : Colors.transparent) 
              : null,
          boxShadow: widget.hoverShadow != null && _isHovering
              ? [widget.hoverShadow!]
              : [],
          borderRadius: widget.borderRadius,
        ),
        child: widget.child,
      ),
    );
  }
}