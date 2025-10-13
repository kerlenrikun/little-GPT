import 'package:flutter/material.dart';
import 'package:ssr/model/router.dart';
import 'package:provider/provider.dart';

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
      routes: {...AppRouter.addRouteMap({})},
    );
  }
}
