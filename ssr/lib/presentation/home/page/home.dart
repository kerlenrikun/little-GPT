import 'package:flutter/material.dart';
import 'package:ssr/model/router.dart';
import 'package:ssr/presentation/auth/page/signin.dart';
import 'package:ssr/presentation/auth/page/register.dart';
import 'package:ssr/presentation/video/play_video.dart';
import 'package:ssr/data/service/local/database_manager.dart';
import 'package:ssr/common/animated/disappear.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //------------------------------------------------------------------------------
  // 状态变量和动画键
  //------------------------------------------------------------------------------
  
  // 数据同步按钮的动画键
  final GlobalKey<State<Disappear>> _animatedButtonKey = GlobalKey();

  // 数据同步状态
  bool _isSyncing = false;
  String? _syncMessage;

  //------------------------------------------------------------------------------
  // 数据同步方法
  //------------------------------------------------------------------------------

  /// 从云端同步数据到本地数据库
  Future<void> _syncDataFromCloud() async {
    if (_isSyncing) return;

    // 开始同步动画
    final animatedState = _animatedButtonKey.currentState;
    if (animatedState != null) {
      (animatedState as dynamic).startAnimation();
    }

    setState(() {
      _isSyncing = true;
      _syncMessage = null;
    });

    try {
      final databaseManager = DatabaseManager();
      final result = await databaseManager.importAllDataFromCloud();
      
      // 重置动画
      if (animatedState != null) {
        (animatedState as dynamic).resetAnimation();
      }

      setState(() {
        _isSyncing = false;
        _syncMessage = '数据同步完成！\n用户数据: ${result['users']}条';
      });
    } catch (e) {
      // 重置动画
      if (animatedState != null) {
        (animatedState as dynamic).resetAnimation();
      }

      setState(() {
        _isSyncing = false;
        _syncMessage = '数据同步失败: $e';
      });
    }
  }

  //------------------------------------------------------------------------------
  // UI组件构建方法
  //------------------------------------------------------------------------------

  /// 构建数据同步按钮组件
  Widget _buildSyncButton() {
    return Disappear(
      key: _animatedButtonKey,
      loadingWidget: const CircularProgressIndicator(
        color: Colors.blue,
        strokeWidth: 5,
      ),
      child: ElevatedButton(
        onPressed: _syncDataFromCloud,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: Size(279, 85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: const Text(
          '从云端同步数据',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
            fontSize: 24,
            fontFamily: 'Satoshi',
          ),
        ),
      ),
    );
  }

  /// 构建同步状态消息组件
  Widget _buildSyncMessage() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Text(
        _syncMessage!,
        style: TextStyle(color: Colors.green[800], fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 构建用户区域1（雨新）的按钮组
  Widget _buildUser1Section() {
    return Expanded(
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
                ElevatedButton(
                  onPressed: () => context.to(SigninPage),
                  child: Text('跳转到登录页面'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.to(RegisterPage),
                  child: Text('跳转到注册页面'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建用户区域2（翁锐）的按钮组
  Widget _buildUser2Section() {
    return Expanded(
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
                ElevatedButton(
                  onPressed: () => context.to(PlayVideo),
                  child: Text('跳转到播放视频页面'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建主要内容区域
  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        const Text('Welcome to the Home Page!'),
        SizedBox(height: 20),
        
        // 数据同步按钮区域
        if (!_isSyncing && _syncMessage == null)
          _buildSyncButton(),
        
        // 同步状态消息区域
        if (_syncMessage != null)
          _buildSyncMessage(),
        
        SizedBox(height: 20),
        
        // 用户按钮区域
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildUser1Section(),
            _buildUser2Section(),
          ],
        ),
        SizedBox(height: 40),
      ],
    );
  }

  //------------------------------------------------------------------------------
  // 主构建方法
  //------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _buildMainContent(),
    );
  }
}

//------------------------------------------------------------------------------
// 封装路由按钮组件
//------------------------------------------------------------------------------

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
