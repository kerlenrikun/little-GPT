import 'package:flutter/material.dart';

class TitleWidget extends StatefulWidget {
  final String title;
  final String listName;
  final int listCount;

  const TitleWidget({
    super.key,
    required this.title,
    required this.listName,
    this.listCount = 0,
  });

  @override
  State<TitleWidget> createState() => _TitleWidgetState();
}

class _TitleWidgetState extends State<TitleWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              decoration: TextDecoration.none, // 明确设置为无装饰线
            ),
          ),
        ],
      ),
    );
  }
}

class ListTitleView extends StatefulWidget {
  final String listName;
  final int listCount;

  const ListTitleView({
    super.key,
    required this.listName,
    required this.listCount,
  });

  @override
  State<ListTitleView> createState() => _ListTitleViewState();
}

class _ListTitleViewState extends State<ListTitleView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.list_alt, color: Color(0xff959085), size: 18),
              SizedBox(width: 4),
              Text(
                widget.listName + '（ 共 ${widget.listCount} 集 ）',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff959085),
                  decoration: TextDecoration.none, // 明确设置为无装饰线
                ),
              ),
            ],
          ),
          Icon(
            Icons.document_scanner_outlined,
            color: Color(0xff959085),
            size: 18,
          ),
        ],
      ),
    );
  }
}
