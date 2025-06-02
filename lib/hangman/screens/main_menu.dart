//main_menu.dart
import 'package:flutter/material.dart';
import 'levels_screen.dart';

class HangmanMainPage extends StatelessWidget {
  const HangmanMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/hangman/home_background.png', fit: BoxFit.cover),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // center horizontally
            children: [
              Spacer(flex: 2), // pushes content down
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LevelsScreen(),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/hangman/start_icon.png',
                  width: 100,
                  height: 100,
                ),
              ),
              Spacer(
                flex: 1,
              ), // smaller spacer below to keep it just under center
            ],
          ),
        ],
      ),
    );
  }
}
