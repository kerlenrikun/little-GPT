import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ssr/core/config/theme/app_colors.dart';
import 'package:ssr/data/service/local/database_manager.dart';
import 'package:ssr/domain/provider/db_path_provider.dart';
import 'package:ssr/domain/provider/series_id_provider.dart';
import 'package:ssr/model/router.dart';
import 'package:provider/provider.dart';
import 'package:ssr/presentation/article/article_page.dart';
import 'package:ssr/common/page/select/select_page.dart';
import 'package:ssr/domain/provider/audio_url_provider.dart'; // 导入AudioUrlProvider
import 'package:ssr/presentation/collection/collection_page.dart';
import 'package:ssr/presentation/collection/util/collection_provider.dart';

// 导入路由
import 'package:ssr/presentation/home_page/home_page.dart';
import 'package:ssr/presentation/auth/page/signin.dart';
import 'package:ssr/presentation/auth/page/register.dart';
import 'package:ssr/presentation/audio/audio_page.dart';
import 'package:ssr/presentation/video/video_page.dart';

void main() async {
  // 确保Flutter绑定已初始化
  // 这是使用任何平台通道（如shared_preferences）的必要步骤
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 200;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 300 << 20;

  // 使用与 database_manager.dart 一致的方式获取数据库路径
  final dbPath = join(await getDatabasesPath(), 'data.db');
  print('<Main>初始化数据库路径: $dbPath');

  // 创建 DbPathProvider 并设置路径
  final dbPathProvider = DbPathProvider();
  dbPathProvider.setDbPath(dbPath);

  // 初始化数据库管理器
  final dbManager = DatabaseManager();
  await dbManager.database; // 确保数据库已初始化

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AudioUrlProvider(),
        ), // 注册AudioUrlProvider
        ChangeNotifierProvider(
          create: (_) => SeriesIdProvider(),
        ), // 注册SeriesIdProvider
        ChangeNotifierProvider(
          create: (_) => CollectionProvider(),
        ), // 注册CollectionProvider
      ],
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'Satoshi'),
        debugShowCheckedModeBanner: false,
        // 完善路由注册
        routes: {
          ...AppRouter.addRouteMap({
            HomePage: (context) => const HomePage(),
            SigninPage: (context) => const SigninPage(),
            RegisterPage: (context) => const RegisterPage(),
            AudioSelectPage: (context) => const AudioSelectPage(),
            PlayVideo: (context) => const PlayVideo(),
            SoundPage: (context) => const SoundPage(
              listName: '播单系列名字',
              title: '[标题]这是一个师父的录音',
              coverUrl:
                  'http://116.62.64.88/projectDoc/testJpg.jpg', // 修改为jpg格式
              listCount: 10,
            ),
            ArticlePage: (context) => const ArticlePage(),
            CollectionPage: (context) => const CollectionPage(),
          }),
        },
        home: HomePage(),
      ),
    );
  }
}

// 将NavigatorButtom类移到Home.dart中
