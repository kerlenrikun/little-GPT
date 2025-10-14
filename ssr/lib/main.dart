import 'package:flutter/material.dart';
import 'package:ssr/core/config/theme/app_colors.dart';
import 'package:ssr/model/router.dart';
import 'package:provider/provider.dart';

// 导入路由
import 'package:ssr/presentation/home_page/home_page.dart';
import 'package:ssr/presentation/auth/page/signin.dart';
import 'package:ssr/presentation/auth/page/register.dart';
import 'package:ssr/presentation/video_page/video_page.dart';

void main() {
  // 确保Flutter绑定已初始化
  // 这是使用任何平台通道（如shared_preferences）的必要步骤
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 200;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 300 << 20;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Satoshi'),
      debugShowCheckedModeBanner: false,
      // 完善路由注册
      routes: {
        ...AppRouter.addRouteMap({
          HomePage: (context) => const HomePage(),
          SigninPage: (context) => const SigninPage(),
          RegisterPage: (context) => const RegisterPage(),
          PlayVideo: (context) => const PlayVideo(),
        }),
      },
      home: HomePage(),
    );
  }
}

// 将NavigatorButtom类移到Home.dart中
