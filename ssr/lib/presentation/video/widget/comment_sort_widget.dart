import 'package:flutter/material.dart';

class SortWidget extends StatefulWidget {
  const SortWidget({super.key});

  @override
  State<SortWidget> createState() => _SortWidgetState();
}

class _SortWidgetState extends State<SortWidget>
    with SingleTickerProviderStateMixin {
  bool sortSwitch = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleSort() {
    // 重置动画并重新开始
    _controller.reset();
    setState(() {
      sortSwitch = !sortSwitch;
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: toggleSort,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                // 创建翻页效果
                double angle = _animation.value * 3.14159 * 2; // 从0到π
                double scale = 1.0;

                // 在翻转过程中稍微缩小再放大，模拟3D效果
                if (_animation.value < 0.5) {
                  scale = 1.0 - (_animation.value * 0.2);
                } else {
                  scale = 0.8 + ((_animation.value - 0.5) * 0.4);
                }

                // 计算透明度，确保在0.0到1.0范围内
                double opacity;
                if (_animation.value < 0.5) {
                  // 前半段：从1.0到0.3
                  opacity = 1.0 - (_animation.value * 1.4);
                } else {
                  // 后半段：从0.3到1.0
                  opacity = 0.3 + ((_animation.value - 0.5) * 1.4);
                }

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // 透视效果
                    ..rotateX(angle)
                    ..scale(scale),
                  alignment: FractionalOffset.center,
                  child: Opacity(
                    opacity: opacity,
                    child: Row(
                      key: ValueKey<bool>(sortSwitch),
                      children: [
                        Icon(
                          sortSwitch
                              ? Icons.timer
                              : Icons.local_fire_department,
                          size: 18,
                        ),
                        SizedBox(width: 2),
                        Text(sortSwitch ? '按时间' : '按热度'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
