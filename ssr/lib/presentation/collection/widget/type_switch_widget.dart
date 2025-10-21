import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ssr/presentation/collection/util/collection_provider.dart';

class TypeSwitchWidget extends StatefulWidget {
  const TypeSwitchWidget({super.key});

  @override
  State<TypeSwitchWidget> createState() => _TypeSwitchWidgetState();
}

class _TypeSwitchWidgetState extends State<TypeSwitchWidget> {
  final List<String> _typeTitles = ['全部', '视频', '音频', '文章'];
  final List<int> _typeValues = [1, 2, 3, 4];
  final List<IconData> _typeIcons = [
    Icons.format_list_numbered,
    Icons.video_library,
    Icons.audio_file,
    Icons.article,
  ];

  Widget _switchBottomItem(
    BuildContext context, {
    required int currentType,
    required String title,
    required IconData icon,
  }) {
    final selectedType = context.watch<CollectionProvider>().currentType;

    return GestureDetector(
      onTap: () =>
          context.read<CollectionProvider>().setCurrentType(currentType),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 5),

        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: selectedType == currentType
                ? Color(0xff0147A6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: selectedType == currentType
                    ? Color(0xffF2B833)
                    : Colors.black54,
              ),
              SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: selectedType == currentType
                      ? Color(0xffF2B833)
                      : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentType = context.watch<CollectionProvider>().currentType;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<CollectionProvider>().setCurrentType(0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),

              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: currentType == 0
                      ? Color(0xff0147A6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '收藏夹',
                  style: TextStyle(
                    color: currentType == 0
                        ? Color(0xffF2B833)
                        : Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 18,
            child: VerticalDivider(
              width: 1.5,
              thickness: 1,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _typeTitles.length,
                itemBuilder: (context, index) {
                  return _switchBottomItem(
                    context,
                    currentType: _typeValues[index],
                    title: _typeTitles[index],
                    icon: _typeIcons[index],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
