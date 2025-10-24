import 'package:flutter/material.dart';
import 'package:ssr/presentation/collection/widget/collection_list_card_widget.dart';

class AllCollectionlPage extends StatefulWidget {
  @override
  _AllCollectionlPageState createState() => _AllCollectionlPageState();
}

class _AllCollectionlPageState extends State<AllCollectionlPage> {
  @override
  Widget build(BuildContext context) {
    return Container(child: CollectionListCardWidget());
  }
}
