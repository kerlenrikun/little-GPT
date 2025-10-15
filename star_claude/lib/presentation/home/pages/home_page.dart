// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_claude/core/configs/theme/app_colors.dart';
import 'package:star_claude/domain/provider/common_data_provider.dart';
import 'package:star_claude/presentation/page__init__.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 通用数据提供器实例
  CommonDataProvider get commonDataProvider =>
      Provider.of<CommonDataProvider>(context, listen: false);

  // 当前选中的索引
  int _currentIndex = 0;

  // 导航项对应的页面
  final List<Widget> _pages = [
    // 数据管理
    DatasetPage(),
    // 选择页面（这里使用占位符)
    AccountPage(),
    // 个人资料页面（占位符）
    ProfilePage(),
  ];

  // 处理导航栏切换
  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _pages[_currentIndex], // 根据当前索引显示对应的页面
      bottomNavigationBar: ButtonNavBar(
        onTabChange: _onTabChange,
        currentIndex: _currentIndex,
      ),
    );
  }
}

// 选择页面占位组件
class SelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 60, color: Colors.grey),
          SizedBox(height: 20),
          Text('选择页面', style: TextStyle(fontSize: 24)),
          Text('这里将显示选择ID的内容', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// 个人资料页面占位组件
