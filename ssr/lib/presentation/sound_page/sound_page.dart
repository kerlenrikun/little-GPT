import 'package:flutter/material.dart';

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.85;
    final screenHeight = screenWidth * 9 / 16;

    return Container(
      color: Color.fromARGB(255, 1, 29, 68),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '听音频',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none, // 明确设置为无装饰线
                  decorationStyle: null,
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              color: Color(0xffA47508),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}
