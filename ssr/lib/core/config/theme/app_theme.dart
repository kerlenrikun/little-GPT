import 'package:flutter/material.dart';
import 'package:ssr/core/config/theme/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    brightness: Brightness.light,
    fontFamily: null,
    // 文本选择主题 - 控制光标样式
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary, // 光标颜色
      selectionColor: AppColors.primary.withOpacity(0.3), // 选中文本背景色
      selectionHandleColor: AppColors.primary, // 选择手柄颜色
    ),
    // 输入框
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      hintStyle: TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w400,
        fontSize: 15,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.5), width: 0.5),
      ),
      // 输入框被选中时的样式
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: BorderSide(
          color: AppColors.primary, // 使用主题主色
          width: 1.0,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    brightness: Brightness.dark,
    fontFamily: 'Satoshi',
    // 输入框
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent,
      hintStyle: TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w400,
        fontSize: 15,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      // 输入框被选中时的样式
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(26),
        borderSide: BorderSide(
          color: AppColors.primary, // 使用主题主色
          width: 1.0,
        ),
      ),
    ),
    // 底部按钮
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
  );
}
