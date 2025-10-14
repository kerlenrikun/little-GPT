import 'package:flutter/material.dart';
import 'package:ssr/model/router.dart';
import 'package:ssr/presentation/auth/page/signin.dart';
import 'package:ssr/presentation/auth/page/register.dart';
import 'package:ssr/presentation/auth/page/video_page/play_video.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          const Text('Welcome to the Home Page!'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('雨新'),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          NavigatorButtom(
                            page: SigninPage(),
                            buttonText: '跳转到登录页面',
                          ),
                          // 使用封装的路由按钮
                          SizedBox(height: 20),
                          NavigatorButtom(
                            page: RegisterPage(),
                            buttonText: '跳转到注册页面',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('翁锐'),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          NavigatorButtom(
                            page: PlayVideo(),
                            buttonText: '跳转到播放视频页面',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

// 封装路由按钮组件
class NavigatorButtom extends StatefulWidget {
  // 添加页面实例参数和按钮文本参数
  final Widget page;
  final String buttonText;

  const NavigatorButtom({
    super.key,
    required this.page,
    required this.buttonText,
  });

  @override
  State<NavigatorButtom> createState() => _NavigatorButtomState();
}

class _NavigatorButtomState extends State<NavigatorButtom> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // 按钮点击事件，使用Context扩展的to方法进行路由跳转
      onPressed: () {
        // 通过widget.page.runtimeType获取页面类型并进行跳转
        context.to(widget.page.runtimeType);
      },
      // 按钮文本
      child: Text(widget.buttonText),
    );
  }
}
