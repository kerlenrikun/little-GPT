import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:star_claude/common/__init__.dart';

import 'package:star_claude/core/configs/__init__.dart';
import 'package:star_claude/models/__init__.dart';
import 'package:star_claude/presentation/page__init__.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 炸裂背景图
          Container(
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage(AppImages.introBG),
              ),
            ),
          ),
          //Container(color: Colors.black.withOpacity(0.05)),  // 页面附魔
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 0, vertical: 64),
            child: Column(
              children: [
                // logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.logo),
                    SizedBox(width: 12),
                    SvgPicture.asset(AppVectors.logo),
                  ],
                ),
                Spacer(),
                // 元标题字
                Align(
                  alignment: AlignmentGeometry.center,
                  child: SvgPicture.asset(AppVectors.logoTitle, width: 312),
                ),
                SizedBox(height: 20),
                // 副标题字
                Align(
                  alignment: AlignmentGeometry.center,
                  child: SvgPicture.asset(AppVectors.logoSubTitle),
                ),
                SizedBox(height: 18),
                // 开始按钮
                BasicAppButton(
                  onPressed: () => context.to(ChooseIdPage),
                  title: '启·创业之旅',
                ),
                SizedBox(height: 27),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
