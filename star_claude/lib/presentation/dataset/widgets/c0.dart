// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:star_claude/domain/entities/data/succ_data.dart';
import 'package:star_claude/presentation/dataset/widgets/base_data_page.dart';
import 'package:star_claude/core/configs/theme/app_colors.dart';

class C0Page extends StatefulWidget {
  const C0Page({super.key});

  @override
  State<C0Page> createState() => _C0PageState();
}

class _C0PageState extends BaseDataPage<C0Page> {
  // 获取c0=1的数据项
  @override
  List<SuccDataEntity> get dataList {
    return fullDataList.where((data) => data.c0 == 1).toList();
  }

  // 获取副标题文本
  @override
  Widget getSubtitle(SuccDataEntity succData) {
    // 收集所有文本片段
    List<TextSpan> textSpans = [];
    
    // 检查流量端
    if (succData.succLl.isNotEmpty) {
      textSpans.add(TextSpan(
        text: succData.succLl,
        style: TextStyle(fontSize: 13, height: 2, color: AppColors.primary),
      ));
    }
    textSpans.add(TextSpan(
        text: ' ->',
        style: TextStyle(fontSize: 12, height: 2, color: Colors.white70),
      ));
    
    // 检查承接端
    if (succData.succCj.isNotEmpty) {
      textSpans.add(TextSpan(
        text: succData.succCj,
        style: TextStyle(fontSize: 13, height: 2, color: AppColors.primary),
      ));
    }
    textSpans.add(TextSpan(
        text: ' ->',
        style: TextStyle(fontSize: 12, height: 2, color: Colors.white70),
      ));
    

    // 检查直销端
    if (succData.succZx.isNotEmpty) {
      textSpans.add(TextSpan(
        text: succData.succZx,
        style: TextStyle(fontSize: 13, height: 2, color: AppColors.primary),
      ));
    }
    textSpans.add(TextSpan(
        text: ' ->',
        style: TextStyle(fontSize: 12, height: 2, color: Colors.white70),
      ));
    
    // 检查转化端
    if (succData.succZh.isNotEmpty) {
      textSpans.add(TextSpan(
        text: succData.succZh,
        style: TextStyle(fontSize: 13, height: 2, color: AppColors.primary),
      ));
    }
    textSpans.add(TextSpan(
        text: ' ->',
        style: TextStyle(fontSize: 12, height: 2, color: Colors.white70),
      ));
    
    // C0信息已移至主标题显示，此处不再重复显示
    
    return RichText(
      text: TextSpan(children: textSpans),
      textAlign: TextAlign.left,
    );
  }
  @override
  Widget build(BuildContext context) {
    return buildPage();
  }
}
