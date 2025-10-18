import 'package:flutter/material.dart';

class ArtWordWidget extends StatelessWidget {
  const ArtWordWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final fontColor = Colors.black87;
    final bgc = Colors.white70;

    // final fontColor = Colors.white70;
    // final bgc = Colors.black87;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '课程',
                style: TextStyle(
                  fontSize: 80,
                  fontFamily: 'yzRH',
                  color: fontColor,
                  decoration: TextDecoration.none,
                  letterSpacing: -22.0, // 减少字间距
                ),
                strutStyle: StrutStyle(
                  fontSize: 10, // 减少行间距
                  fontFamily: 'yzRH',
                ),
              ),
              Text(
                '系列名',
                style: TextStyle(
                  fontSize: 80,
                  fontFamily: 'yzRH',
                  color: fontColor,
                  decoration: TextDecoration.none,
                  letterSpacing: -22.0, // 减少字间距
                ),
                strutStyle: StrutStyle(
                  fontSize: 10, // 减少行间距
                  fontFamily: 'yzRH',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 48),
          child: Row(
            children: [
              Text(
                '2025.10.17-10.25',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'yzRH',
                  color: fontColor,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  letterSpacing: 0.0, // 减少字间距
                ),
                strutStyle: StrutStyle(
                  fontSize: 10, // 减少行间距
                  fontFamily: 'yzRH',
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.travel_explore),
            ],
          ),
        ),
        SizedBox(height: 32),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'The',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'yzRH',
                      color: fontColor,
                      decoration: TextDecoration.none,
                      letterSpacing: 0.0, // 减少字间距
                    ),
                    strutStyle: StrutStyle(
                      fontSize: 10, // 减少行间距
                      fontFamily: 'yzRH',
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Teacher:',
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'yzRH',
                      color: fontColor,
                      decoration: TextDecoration.none,
                      letterSpacing: 0.0, // 减少字间距
                    ),
                    strutStyle: StrutStyle(
                      fontSize: 10, // 减少行间距
                      fontFamily: 'yzRH',
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Master',
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: 'yzRH',
                    color: fontColor,
                    decoration: TextDecoration.none,
                    letterSpacing: 0.0, // 减少字间距
                  ),
                  strutStyle: StrutStyle(
                    fontSize: 10, // 减少行间距
                    fontFamily: 'yzRH',
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            'Audio   List',
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'yzRH',
              color: fontColor,
              decoration: TextDecoration.none,
              letterSpacing: 0.0, // 减少字间距
            ),
            strutStyle: StrutStyle(
              fontSize: 10, // 减少行间距
              fontFamily: 'yzRH',
            ),
          ),
        ),
      ],
    );
  }
}
