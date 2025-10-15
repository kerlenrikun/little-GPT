import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:star_claude/core/configs/theme/app_colors.dart';

class CloudAnimation extends StatefulWidget {
  const CloudAnimation({
    Key? key,
    this.size = 160.0,
    this.color = AppColors.primary,
    this.duration = const Duration(milliseconds: 1600),
  }) : super(key: key);

  final double size;
  final Color color;
  final Duration duration;

  @override
  State<CloudAnimation> createState() => _CloudAnimationState();
}

class _CloudAnimationState extends State<CloudAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation1;
  late Animation<double> _scaleAnimation2;
  late Animation<double> _scaleAnimation3;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // 为三个球创建顺序变小的缩放动画
    // 使用TweenSequence替代chain方法，这是Flutter中正确的动画序列实现方式
    
    // 第一个球先变小再变大
    _scaleAnimation1 = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.4),
        weight: 30.0, // 30% of the animation duration
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.4, end: 1.0),
        weight: 30.0, // 30% of the animation duration
      ),
      // 保持1.0直到动画结束
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40.0, // 40% of the animation duration
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    // 第二个球在第一个球开始变大时变小，然后变大
    _scaleAnimation2 = TweenSequence<double>([
      // 保持1.0直到第一个球开始变大
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 30.0, // 30% of the animation duration
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.3),
        weight: 30.0, // 30% of the animation duration
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 1.0),
        weight: 40.0, // 40% of the animation duration
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    // 第三个球在第二个球开始变大时变小，然后变大
    _scaleAnimation3 = TweenSequence<double>([
      // 保持1.0直到第二个球开始变大
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60.0, // 60% of the animation duration
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.4),
        weight: 30.0, // 30% of the animation duration
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.4, end: 1.0),
        weight: 10.0, // 10% of the animation duration
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    // 透明度动画简化，保持一致
    _opacityAnimation = Tween<double>(begin: 1, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // 开始动画并设置为自动循环
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 计算总宽度，确保三个球平行放置有足够空间
    final totalWidth = widget.size;
    final ballSize = widget.size / 4;
    
    return SizedBox(
      width: totalWidth,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 第一个球 - 左侧
              Positioned(
                left: 5,
                child: Transform.scale(
                  scale: _scaleAnimation1.value,
                  child: CloudPart(
                    size: ballSize,
                    color: widget.color,
                    opacity: _opacityAnimation.value,
                    borderRadius: BorderRadius.circular(ballSize),
                  ),
                ),
              ),
              // 第二个球 - 中间
              Positioned(
                top:  3,
                child: Transform.scale(
                  scale: _scaleAnimation3.value,
                  child: CloudPart(
                    size: ballSize,
                    color: widget.color,
                    opacity: _opacityAnimation.value,
                    borderRadius: BorderRadius.circular(ballSize),
                  ),
                ),
              ),
              // 第三个球 - 右侧
              Positioned(
                right: 5,
                child: Transform.scale(
                  scale: _scaleAnimation2.value,
                  child: CloudPart(
                    size: ballSize,
                    color: widget.color,
                    opacity: _opacityAnimation.value,
                    borderRadius: BorderRadius.circular(ballSize),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CloudPart extends StatelessWidget {
  const CloudPart({
    Key? key,
    required this.size,
    required this.color,
    required this.opacity,
    required this.borderRadius,
  }) : super(key: key);

  final double size;
  final Color color;
  final double opacity;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    // 确保size和opacity值有效
    final validSize = size > 0 ? size : 10.0;
    final validOpacity = opacity.clamp(0.0, 1.0);
    
    return Container(
      width: validSize,
      height: validSize,
      decoration: BoxDecoration(
        color: color.withOpacity(validOpacity),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}