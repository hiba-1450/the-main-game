import 'package:flutter/material.dart';
import 'screens/game_screen.dart';
import 'screens/win_screen.dart';
import 'screens/lose_screen.dart';
import 'screens/main_menu.dart';
import 'screens/levels_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'ComicNeue'),
      initialRoute: '/',
      routes: {
        '/': (context) => const HangmanMainPage(),
        '/levels': (context) => const LevelsScreen(),
        '/game': (context) {
          final levelIndex = ModalRoute.of(context)!.settings.arguments as int;
          return GameScreen(levelIndex: levelIndex);
        },
        '/win': (context) {
          final nextLevel = ModalRoute.of(context)!.settings.arguments as int;
          final currentLevel = nextLevel - 1;
          return WinScreen(
            nextLevelIndex: nextLevel,
            currentLevel: currentLevel,
          );
        },
        '/lose': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as int;
          return LoseScreen(currentLevelIndex: args, currentLevel: args);
        },
      },
    ),
  );
}
