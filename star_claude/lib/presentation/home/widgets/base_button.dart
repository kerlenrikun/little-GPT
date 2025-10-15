// ignore_for_file: unused_import, deprecated_member_use, must_be_immutable

import 'package:flutter/material.dart';

class BaseButton extends StatefulWidget {
  //按钮点击事件
  final Widget? icon;
  final VoidCallback onTap;
  final String text;
  double scale;

  BaseButton({
    super.key,
    required Widget? icon,
    required this.text,
    required this.onTap,
    this.scale = 1.0,
  }) : icon = icon;

  @override
  State<BaseButton> createState() => _BaseButtonState();
}

class _BaseButtonState extends State<BaseButton> {
  bool _isSelected = false;
  bool _isHovering = false;

  void _onTap() {
    widget.onTap();
  }

  //选中事件
  void _onTapDown(TapDownDetails details) {
    // 先放大文字
    setState(() {
      widget.scale += 0.02;
    });
    //选中
    setState(() {
      _isSelected = true;
    });
  }

  //取消选中事件
  void _onTapUp(TapUpDetails details) {
    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        widget.scale -= 0.02;
      });
    });
    setState(() {
      _isSelected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      //悬停事件
      onHover: (_) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
      },
      child: GestureDetector(
        //选中事件
        onTapDown: _onTapDown,
        //取消选中事件
        onTapUp: _onTapUp,
        //点击事件
        onTap: _onTap,
        child: Transform.scale(
          scale: widget.scale,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              //按钮阴影
              boxShadow: [
                BoxShadow(
                  color: _isHovering ? Colors.grey[500]!.withOpacity(0.5) : Colors.grey[500]!.withOpacity(0.6),  
                  blurRadius: 5,
                  offset: Offset(0, _isHovering ? 4 : 5), // 悬停时阴影变浅
                ),
              ],
              //按钮颜色
              color: _isSelected
                  ? Colors.white
                  : (_isHovering ? Colors.white : Colors.white),
              //按钮形状
              borderRadius: BorderRadius.all(
                Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme(
                  data: IconThemeData(color: _isHovering ? Colors.black : Colors.grey[800],), 
                  child: widget.icon!),
                SizedBox(width: 5),
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _isHovering ? Colors.grey[900] : Colors.grey[850],
                    //letterSpacing: 1.0, // 增加文本间距
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
