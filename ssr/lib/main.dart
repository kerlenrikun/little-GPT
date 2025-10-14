import 'package:flutter/material.dart';
import 'package:ssr/model/router.dart';
import 'package:provider/provider.dart';

// 导入路由
import 'package:ssr/presentation/auth/page/home/home.dart';
import 'package:ssr/presentation/auth/page/signin.dart';
import 'package:ssr/presentation/auth/page/register.dart';
import 'package:ssr/presentation/auth/page/video_page/play_video.dart';

void main() {
  // 确保Flutter绑定已初始化
  // 这是使用任何平台通道（如shared_preferences）的必要步骤
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
