import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CollectionListCardWidget extends StatefulWidget {
  @override
  _CollectionListCardWidgetState createState() =>
      _CollectionListCardWidgetState();
}

class _CollectionListCardWidgetState extends State<CollectionListCardWidget> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width / 2 - 20;
    double screenHeight = screenWidth * 9 / 16;
    return Column(
      children: [
        GestureDetector(
          onTap: () => {},
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Container(
              // color: Colors.blueAccent,
              child: Row(
                children: [
                  Container(
                    width: screenWidth,
                    height: screenHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: 'http://116.62.64.88/projectDoc/testJpg.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: SvgPicture.asset(
                                'assets/vectors/VideoType.svg',
                              ),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(top: 2, bottom: 6),
                                height: screenHeight - 20,
                                child: Text('[标题]这是一个师父的录音或演出，而且不怕很长的标题名字导致溢出'),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: 6),
                            Container(
                              child: SvgPicture.asset(
                                'assets/vectors/videoPlayCountIcon.svg',
                              ),
                            ),
                            SizedBox(width: 4),
                            Text('123456'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
}
