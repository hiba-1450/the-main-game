// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ScoreBoard extends StatelessWidget {
  final String title;
  final int score;
  final bool isDarkMode;

  const ScoreBoard(
      {super.key,
      required this.title,
      required this.score,
      this.isDarkMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2C4776) : const Color(0xFF5AB0CD),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'ConcertOne',
              fontSize: isDarkMode ? 14 : 16,
            ),
          ),
          Text(
            "$score",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isDarkMode ? 20 : 22,
              fontFamily: 'ConcertOne',
            ),
          ),
        ],
      ),
    );
  }
}
