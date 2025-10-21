import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Interaction extends StatefulWidget {
  @override
  _InteractionState createState() => _InteractionState();
}

class _InteractionState extends State<Interaction> {
  Widget _buildInteractionItem(
    Widget svg,
    String text, {
    double width = 35,
    double height = 35,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
      decoration: BoxDecoration(
        // color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          SizedBox(width: width, height: height, child: svg),
          SizedBox(height: 8.0),
          Text(
            text,
            style: TextStyle(
              color: Color(0xffDCD2BD),
              fontSize: 13,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          _buildInteractionItem(
            SvgPicture.asset('assets/vectors/thumb.svg'),
            '1248',
          ),
          _buildInteractionItem(
            SvgPicture.asset('assets/vectors/star.svg'),
            '1248',
          ),
          _buildInteractionItem(
            SvgPicture.asset('assets/vectors/comment.svg'),
            '1248',
          ),
          _buildInteractionItem(
            SvgPicture.asset('assets/vectors/share.svg'),
            '1248',
          ),
        ],
      ),
    );
  }
}
