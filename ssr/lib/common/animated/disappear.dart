import 'package:flutter/material.dart';

/// 可复用的组件消失动画Widget
/// 接收一个child Widget，为其提供平滑消失并显示加载动画的效果
class Disappear extends StatefulWidget {
  /// 要应用消失动画的子组件
  final Widget child;
  
  /// 加载状态下显示的组件（可选，默认为CircularProgressIndicator）
  final Widget? loadingWidget;
  
  /// 动画控制器（可选，外部提供以实现更复杂的控制）
  final AnimationController? controller;
  
  /// 动画时长（毫秒）
  final int durationMs;
  
  /// 当动画完成时的回调
  final VoidCallback? onAnimationComplete;

  const Disappear({
    super.key,
    required this.child,
    this.loadingWidget,
    this.controller,
    this.durationMs = 500,
    this.onAnimationComplete,
  });

  @override
  State<Disappear> createState() => _AnimatedDisappearWidgetState();
}

class _AnimatedDisappearWidgetState extends State<sDisappear>
    with SingleTickerProviderStateMixin {
  /// 动画控制器
  late final AnimationController _animationController;
  
  /// 子组件淡出动画
  late final Animation<double> _childOpacity;
  
  /// 子组件缩放动画
  late final Animation<double> _childScale;
  
  /// 加载组件淡入动画
  late final Animation<double> _loadingOpacity;
  
  /// 加载组件缩放动画
  late final Animation<double> _loadingScale;

  @override
  void initState() {
    super.initState();
    
    // 使用外部提供的控制器或创建新的控制器
    _animationController = widget.controller ??
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.durationMs),
        );

    // 配置子组件消失动画
    _configureAnimations();
  }

  void _configureAnimations() {
    // 子组件淡出动画 - 从1.0到0.0
    _childOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInBack),
      ),
    );

    // 子组件缩小动画 - 从1.0到0.9
    _childScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInBack),
      ),
    );

    // 加载组件淡入动画 - 从0.0到1.0
    _loadingOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // 加载组件放大动画 - 从0.5到1.0
    _loadingScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // 监听动画状态变化
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
  }

  /// 开始消失动画
  void startAnimation() {
    _animationController.forward();
  }

  /// 重置动画到初始状态
  void resetAnimation() {
    _animationController.reset();
  }

  /// 反向播放动画
  void reverseAnimation() {
    _animationController.reverse();
  }

  @override
  void dispose() {
    // 只有在内部创建的控制器才需要在这里dispose
    if (widget.controller == null) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 子组件（淡出动画）
            Opacity(
              opacity: _childOpacity.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: _childScale.value,
                child: widget.child,
              ),
            ),
            
            // 加载组件（淡入动画）
            Opacity(
              opacity: _loadingOpacity.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: _loadingScale.value,
                child: widget.loadingWidget ??
                    const CircularProgressIndicator(
                      strokeWidth: 5,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}