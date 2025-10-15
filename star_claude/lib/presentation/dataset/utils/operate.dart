import 'package:flutter/material.dart';

/// 可展开操作按钮组件
/// 
/// 这是一个自定义的Flutter组件，用于创建一个可展开的按钮组。
/// 点击主按钮后，会向右横向展开一组操作按钮，并带有平滑的动画效果。
/// 适用于需要紧凑展示多个操作选项的场景，如列表项的快捷操作菜单。
/// 
/// 主要特性：
/// - 可自定义展开的按钮列表
/// - 平滑的展开/收起动画效果
/// - 可控制按钮之间的间距
/// - 自适应宽度，仅在展开时占用必要空间
/// - 按钮展开时带有位置和透明度动画
class OperateButton extends StatefulWidget {
  /// 展开的按钮列表
  final List<Widget> actionButtons;
  
  /// 按钮间距，默认为12.0
  final double buttonSpacing;

  // 固定按钮尺寸
  final double buttonSize;

  /// 构造函数
  const OperateButton({
    this.buttonSize = 32.0,
    Key? key,
    required this.actionButtons,
    this.buttonSpacing = 6.0,
  }) : super(key: key);

  @override
  State<OperateButton> createState() => _OperateButtonState();
}

/// OperateButton的状态管理类
/// 
/// 负责处理按钮组的展开/收起状态管理、动画控制以及按钮的布局计算。
/// 使用SingleTickerProviderStateMixin来提供动画控制所需的帧回调。
class _OperateButtonState extends State<OperateButton> with SingleTickerProviderStateMixin {
  /// 展开状态标志
  bool _isExpanded = false;
  
  /// 动画控制器，用于控制按钮展开/收起的动画
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    // 初始化动画控制器
    // vsync参数绑定到当前State对象，确保动画在界面可见时才运行
    // duration设置为200毫秒，提供流畅的展开/收起动画
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }
  
  @override
  void dispose() {
    // 释放动画控制器资源，防止内存泄漏
    _controller.dispose();
    super.dispose();
  }
  
  /// 切换展开/收起状态
  /// 
  /// 点击主按钮时触发，会切换_isExpanded状态并相应地启动或反向动画
  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // 固定按钮尺寸
    final double buttonSize = widget.buttonSize;
    
    // 计算展开后的宽度，确保不会占用过多空间
    // 宽度 = 按钮数量 × (按钮尺寸 + 间距) + 主按钮尺寸
    final double expandedWidth = widget.actionButtons.length * (buttonSize + widget.buttonSpacing) + buttonSize;
    
    // 创建按钮列表
    final List<Widget> buttons = [];
    
    // 根据按钮数量创建相应的按钮
    for (int i = 0; i < widget.actionButtons.length; i++) {
      // 计算每个按钮的位置动画
      // 根据按钮索引和间距计算每个按钮的最终位置
      final Animation<double> positionAnimation = Tween<double>(
        begin: buttonSize,
        // 位置 = 主按钮尺寸 + (按钮索引+1) × (按钮尺寸 + 间距)
        end: (i + 1) * (buttonSize + widget.buttonSpacing),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.8, curve: Curves.easeOut),
      ));
      
      // 计算每个按钮的透明度动画
      final Animation<double> opacityAnimation = Tween<double>(
        begin: 0.0,
        end: 0.8,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 0.8, curve: Curves.easeOut),
      ));
      
      buttons.add(
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              right: positionAnimation.value,
              child: Opacity(
                opacity: opacityAnimation.value,
                child: Container(
                  width: buttonSize+5,
                  height: buttonSize+10,
                  color: Colors.transparent,
                  child: Center(
                    child: widget.actionButtons[i],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    // 添加主按钮（放在最后确保它显示在最上层）
    buttons.add(
      Positioned(
        right: 0,
        child: IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _controller,
            color: Colors.white,
          ),
          onPressed: _toggleExpand,
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: buttonSize,
            minHeight: buttonSize,
          ),
        ),
      ),
    );

    // 返回一个自适应宽度的容器
    // 仅在展开状态下使用完整宽度，收起状态下仅使用主按钮宽度
    return SizedBox(
      width: _isExpanded ? expandedWidth : buttonSize,
      height: buttonSize,
      // 使用Stack布局来叠加按钮，实现展开效果
      child: Stack(
        alignment: Alignment.centerRight,
        children: buttons,
      ),
    );
  }
}