import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'package:ssr/core/config/assets/app_images.dart';
import 'package:ssr/core/config/assets/app_vector.dart';
import 'package:ssr/core/config/theme/__init__.dart';
import 'package:ssr/model/router.dart';
import 'package:ssr/presentation/__init__.dart';
import 'package:ssr/domain/provider/user_provider.dart';

class SignupOrSigninPage extends StatelessWidget {
  const SignupOrSigninPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BasicAppBar(),
          // 背景修饰
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(AppVectors.topPattern,),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SvgPicture.asset(AppVectors.bottomPattern),
          ),
          Align(s
            alignment: Alignment.bottomLeft,
            child: Image.asset(AppImages.authBG),
          ),
          // 内容部分
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 178,),
                  // logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppImages.logo),
                      SizedBox(width: 12),
                      SvgPicture.asset(AppVectors.logo),
                    ],
                  ),
                  const SizedBox(height: 55),
                  // 元标题
                  const Text(
                    '跑通线上 · 赋能集团',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 7,
                      color: AppColors.lightBackground,
                    ),
                  ),
                  SizedBox(height: 24,),
                  // 副标题
                  Text(
                    'This star is created for digitally empower connecting online to the group',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      //letterSpacing: 6,
                      wordSpacing: 2,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 45,),
                  Row(
                    children: [
                      // 注册
                      Expanded(
                        flex: 1,
                        child: BasicAppButton(
                          height: 73,
                          title: 'Register',
                          fontsize: 18,
                          letterspacing: 1,
                          color: Colors.white,
                          onPressed: () => context.to(RegisterPage),
                          )
                      ),
                      SizedBox(width: 20,),
                      //登录
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () { context.to(SigninPage);},
                          child: Text('Sign in',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),),
                          )
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
