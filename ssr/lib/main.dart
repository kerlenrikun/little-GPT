import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:ssr/core/config/theme/app_colors.dart';
import 'package:ssr/model/router.dart';
import 'package:provider/provider.dart';

// 导入路由
import 'package:ssr/presentation/home_page/home_page.dart';
import 'package:ssr/presentation/auth/page/signin.dart';
import 'package:ssr/presentation/auth/page/register.dart';
import 'package:ssr/presentation/sound_page/sound_page.dart';
import 'package:ssr/presentation/video_page/video_page.dart';

void main() async {
  // 确保Flutter绑定已初始化
  // 这是使用任何平台通道（如shared_preferences）的必要步骤
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 200;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 300 << 20;

  // 初始化后台播放组件
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.audio.channel',
    androidNotificationChannelName: '音频播放',
    androidNotificationOngoing: true,
  );
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
          SoundPage: (context) => const SoundPage(
            listName: '播单系列名字',
            title: '[标题]这是一个师父的录音',
            soundFileUrl: 'http://116.62.64.88/projectDoc/testLongMp3.mp3',
            coverUrl: 'http://116.62.64.88/projectDoc/testJpg.jpg', // 修改为jpg格式
            listCount: 10,
          ),
        }),
      },
      home: HomePage(),
    );
  }
}

// 将NavigatorButtom类移到Home.dart中
