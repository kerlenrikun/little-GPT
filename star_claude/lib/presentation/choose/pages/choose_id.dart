import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/auth/user.dart';
import '../widgets/button/id_button.dart';

import 'package:star_claude/core/configs/__init__.dart';
import 'package:star_claude/presentation/page__init__.dart';
import 'package:star_claude/domain/__init__.dart';
import 'package:star_claude/models/__init__.dart';
import 'package:star_claude/common/__init__.dart';

class ChooseIdPage extends StatefulWidget {
  const ChooseIdPage({super.key});

  @override
  State<ChooseIdPage> createState() => _ChooseIdPageState();
}

int _selectedId = 0;

class _ChooseIdPageState extends State<ChooseIdPage> {
  /// 用户信息
  UserProvider get userProvider => Provider.of<UserProvider>(context, listen: false);

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
                image: AssetImage(AppImages.chooseIDBG),
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
                  child: Text(
                    '职业 选择',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 7,
                      color: Colors.white,
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 6,
                          offset: Offset(0, 3), // 阴影位置
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // 副标题字
                Align(
                  alignment: AlignmentGeometry.center,
                  child: SvgPicture.asset(AppVectors.chooseSubTitle),
                ),
                // 选择按钮 - 使用新的按钮选择器组件
                ButtonSelector(
                  currentSelectedId: _selectedId,
                  onSelectionChanged: (id) {
                    setState(() {
                      _selectedId = id;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // 开始按钮
                BasicAppButton(
                  onPressed: () {
                    // 保存选择的ID到UserProvider
                    userProvider.updateUserInfo(
                      selectedId: _selectedId,
                    );
                    context.to(SignupOrSigninPage);
                  },
                  title: '进入${JobUtils.idToString(_selectedId).substring(0,JobUtils.idToString(_selectedId).length-1)}世界',
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
