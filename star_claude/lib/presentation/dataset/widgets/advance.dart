
// ignore_for_file: prefer_interpolation_to_compose_strings
import 'package:flutter/material.dart';
import 'package:star_claude/domain/entities/data/succ_data.dart';
import 'package:star_claude/presentation/dataset/widgets/base_data_page.dart';
import 'package:star_claude/core/configs/theme/app_colors.dart';

class AdvancePage extends StatefulWidget {
  const AdvancePage({super.key});

  @override
  State<AdvancePage> createState() => _AdvancePageState();
}

class _AdvancePageState extends BaseDataPage<AdvancePage> {
  // 获取所有数据项
  @override
  List<SuccDataEntity> get dataList {
    return fullDataList;
  }

  // 获取副标题文本
  @override
  Widget getSubtitle(SuccDataEntity succData) {
    // 收集所有文本片段
    List<TextSpan> textSpans = [];
    bool hasContent = false;
    
    // 检查流量端
    if (succData.succLl!=0) {
      textSpans.add(TextSpan(
        text: succData.succLl.toString(),
        style: TextStyle(fontSize: 13, height: 2, color: AppColors.primary),
      ));
      textSpans.add(TextSpan(
        text: '->',
        style: TextStyle(fontSize: 13, height: 2, color: Colors.white70),
      ));
      hasContent = true;
    }
    
    // 检查承接端
    if (succData.succCj!=0) {
      if (hasContent) textSpans.add(TextSpan(text: '  '));
      textSpans.add(TextSpan(
        text: succData.succCj,
        style: TextStyle(fontSize: 13, height: 2, color: AppColors.primary),
      ));
      textSpans.add(TextSpan(
        text: '->',
        style: TextStyle(fontSize: 13, height: 2, color: Colors.white70),
      ));
      hasContent = true;
    }
    
    // 检查直销端
    if (succData.succZx.isNotEmpty) {
      textSpans.add(TextSpan(
        text: succData.succZx,
        style: TextStyle(fontSize: 13, height: 2, color: AppColors.primary),
      ));
      textSpans.add(TextSpan(
        text: '->',
        style: TextStyle(fontSize: 13, height: 2, color: Colors.white70),
      ));
      hasContent = true;
    }
    
    // 检查转化端
    if (succData.succZh.isNotEmpty) {
      textSpans.add(TextSpan(
        text: succData.succZh,
        style: TextStyle(fontSize: 13, height: 2, color: AppColors.primary),
      ));
      textSpans.add(TextSpan(
        text: '->',
        style: TextStyle(fontSize: 13, height: 2, color: Colors.white70),
      ));
      hasContent = true;
    }
    
    // 对于既不是C0也不是C1的记录，显示进阶课标识
    if (succData.c0 != 1 && succData.c1 != 1) {
      if (hasContent) textSpans.add(TextSpan(text: '  | '));
      textSpans.add(TextSpan(
        text: '进阶课',
        style: TextStyle(fontSize: 13, height: 2, color: Colors.white70),
      ));
    }
    
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
