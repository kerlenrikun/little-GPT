import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:star_claude/common/__init__.dart';
import 'package:star_claude/core/configs/__init__.dart';
import 'package:star_claude/presentation/dataset/widgets/account_data_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  
  @override
  State<AccountPage> createState() => _AccountPageState();
}


class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // 顶部
      appBar: BasicAppBar(
        title: Transform.scale(
          scale: 0.58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(AppImages.logo),
              SizedBox(width: 15),
              SvgPicture.asset(AppVectors.logo),
            ],
          ),
        ),
      ),
      // 枝干
      body: Stack(
        children: [
          // 背景

          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(AppVectors.homeTopPattern,),
          ),
          
          Align(
            alignment: Alignment.bottomRight,
            child: SvgPicture.asset(AppVectors.homeBottomPattern),
          ), 
          
          // 内容
          AccountDataPage(),
        ]),
    );
  }
}
