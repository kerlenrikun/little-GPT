import 'package:flutter/material.dart';
import 'package:ssr/presentation/collection/widget/type_switch_widget.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage>
    with SingleTickerProviderStateMixin {
  final _tabs = <String>['收藏'];
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            toolbarHeight: 48,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black54,
          ),
          TabBar(
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            labelColor: Color(0XFF0147A6),
            dividerColor: Colors.transparent,
            indicatorColor: Color(0XFF0147A6),
            unselectedLabelColor: Colors.deepOrangeAccent,
            controller: _tabController,
            tabs: _tabs.map((e) => Tab(text: e)).toList(),
          ),
          SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [TabPage()],
            ),
          ),
        ],
      ),
    );
  }
}

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  @override
  Widget build(BuildContext context) {
    return Container(child: Column(children: [TypeSwitchWidget()]));
  }
}
