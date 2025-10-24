import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

bool stateSwitch = false;

class VideoListWidget extends StatefulWidget {
  const VideoListWidget({super.key});

  @override
  State<VideoListWidget> createState() => _VideoListWidgetState();
}

class _VideoListWidgetState extends State<VideoListWidget> {
  void _onStateChanged() {
    // 当状态改变时刷新组件
    setState(() {
      // 可以在这里添加其他需要在状态改变时执行的逻辑
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TypeSwitchButton(onStateChanged: _onStateChanged),
          SizedBox(height: 12),
          // 这里已经正确传递了网络图片URL
          stateSwitch
              ? SizedBox()
              : ListVideoCard(
                  coverUrl: 'https://rmtt.top/projectDoc/testJpg.jpg',
                ),
        ],
      ),
    );
  }
}

class TypeSwitchButton extends StatefulWidget {
  final VoidCallback? onStateChanged;

  const TypeSwitchButton({super.key, this.onStateChanged});

  @override
  State<TypeSwitchButton> createState() => _TypeSwitchButtonState();
}

class _TypeSwitchButtonState extends State<TypeSwitchButton> {
  void toList() {
    setState(() {
      stateSwitch = false;
    });
    // 调用回调函数通知状态已更改
    widget.onStateChanged?.call();
  }

  void toRecommend() {
    setState(() {
      stateSwitch = true;
    });
    // 调用回调函数通知状态已更改
    widget.onStateChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 为"播单"按钮添加点击事件
        GestureDetector(
          onTap: toList,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 60,
            height: 35,
            decoration: BoxDecoration(
              color: stateSwitch ? Color(0xffF0F4FF) : Color(0xffF2B833),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(1, 1), // 阴影方向
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                '播单',
                style: TextStyle(
                  fontSize: 14,
                  color: stateSwitch ? Colors.black : Color(0xff0147A6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Container(width: 1, height: 35, color: Colors.grey),
        // 为"推荐"按钮添加点击事件
        GestureDetector(
          onTap: toRecommend,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 60,
            height: 35,
            decoration: BoxDecoration(
              color: stateSwitch ? Color(0xffF2B833) : Color(0xffF0F4FF),

              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(1, 1), // 阴影方向
                ),
              ],
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                '推荐',
                style: TextStyle(
                  fontSize: 14,
                  color: stateSwitch ? Color(0xff0147A6) : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ListVideoCard extends StatefulWidget {
  final String coverUrl;
  const ListVideoCard({super.key, required this.coverUrl});

  @override
  State<ListVideoCard> createState() => _ListVideoCardState();
}

class _ListVideoCardState extends State<ListVideoCard> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width / 2 - 20;
    double screenHeight = screenWidth * 9 / 16;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenWidth,
                height: screenHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: widget.coverUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.only(top: 2, bottom: 6),
                width: MediaQuery.of(context).size.width - screenWidth - 50,
                height: screenHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '[标题]这是同一个系列的其他视频',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.video_collection, size: 18),
                        SizedBox(width: 4),
                        Text(
                          '1000',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(height: 1),
        ],
      ),
    );
  }
}
