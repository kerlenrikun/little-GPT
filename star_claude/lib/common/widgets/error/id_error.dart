import 'package:flutter/material.dart';
import 'package:star_claude/core/configs/theme/app_colors.dart';

/// 身份错误提示组件
/// 
/// 当用户尝试执行超出其权限的操作时，在屏幕底部显示错误提示
/// 
/// [参数说明]:
/// - [message]: 要显示的错误消息，默认为"You Can't Do That For Your Id"
class IdError extends StatelessWidget {
  final String message;
  
  const IdError({super.key, this.message = '权限不足'});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xfffa2900).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}