import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CollectionListCardWidget extends StatefulWidget {
  @override
  _CollectionListCardWidgetState createState() =>
      _CollectionListCardWidgetState();
}

class _CollectionListCardWidgetState extends State<CollectionListCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => {},
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Container(
                  child: CachedNetworkImage(
                    imageUrl: 'http://116.62.64.88/projectDoc/testJpg.jpg',
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
}
