import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class VideoTitle extends StatefulWidget {
  const VideoTitle({super.key});

  @override
  State<VideoTitle> createState() => _VideoTitleState();
}

class _VideoTitleState extends State<VideoTitle> with TickerProviderStateMixin {
  // 将isExpanded设置为可变的状态变量
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化旋转动画控制器
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    // 创建旋转动画，从右边开始旋转
    _animation = Tween<double>(begin: 0, end: -0.5).animate(_controller);

    // 初始化展开动画控制器
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    // 创建展开动画
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '[标题]这是一个师父的录音或演出，并且标题是加长的',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  maxLines: isExpanded ? null : 1,
                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                ),
              ),
              // 添加点击事件来切换展开/收起状态
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                    // 根据状态控制动画播放
                    if (isExpanded) {
                      _controller.forward();
                      _expandController.forward();
                    } else {
                      _controller.reverse();
                      _expandController.reverse();
                    }
                  });
                },
                child: RotationTransition(
                  turns: _animation,
                  child: Icon(Icons.keyboard_arrow_down),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 5),
              Row(
                children: [
                  Icon(Icons.video_collection, size: 18),
                  SizedBox(width: 2),
                  Text('4125'),
                ],
              ),
              SizedBox(width: 30),
              Row(
                children: [
                  Icon(Icons.access_time_filled, size: 18),
                  SizedBox(width: 2),
                  Text('2025年10月11日 15:27'),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0, // 从顶部开始展开
            child: Container(
              key: ValueKey<bool>(isExpanded),
              child: Text(
                '这是一个很长的简介，里面可以写很多东西，比如视频的简介或者是啥的，总之先把这里写的很多，示意一下这里可以写很多的东西，容纳比较长的文本',
                style: TextStyle(fontSize: 14.0),
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.thumb_up_alt, size: 36),
                    SizedBox(height: 2),
                    Text('1245'),
                  ],
                ),
              ),
              SizedBox(width: 24),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 36),
                    SizedBox(height: 2),
                    Text('1245'),
                  ],
                ),
              ),
              SizedBox(width: 24),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.share, size: 36),
                    SizedBox(height: 2),
                    Text('1245'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
