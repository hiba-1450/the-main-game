import 'package:flutter/material.dart';

// Import your main app screens
import 'screens/splash_screen.dart';
import 'screens/start_screen.dart';
import 'screens/games_screen.dart';

// Hangman imports
import 'hangman/screens/game_screen.dart';
import 'hangman/screens/win_screen.dart';
import 'hangman/screens/lose_screen.dart';
import 'hangman/screens/levels_screen.dart';

// Human Benchmark import
import 'humanbenchmark/screens/intro_screen.dart';

// Escape imports
import 'escape/main.dart';

// 2048 imports
import '2048/level_selection.dart';

void main() {
  runApp(const MindMattersApp());
}

class MindMattersApp extends StatelessWidget {
  const MindMattersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Matters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Fredoka',
        textTheme: Theme.of(context).textTheme,
      ),
      home: const SplashScreen(),
      routes: {
        '/start': (context) => const StartScreen(),
        '/games': (context) => const GamesScreen(),

        // Hangman routes
        //'/hangman': (context) => const HangmanMainPage(),
        '/hangman/levels': (context) => const LevelsScreen(),

        // Human Benchmark route
        '/humanbenchmark': (context) => const IntroScreen(),

        // Escape route
        '/escape': (context) => const MyMenuPage(),

        // 2048 route
        '/2048': (context) => const LevelSelectionScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/hangman/game') {
          final levelIndex = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => GameScreen(levelIndex: levelIndex),
          );
        }
        if (settings.name == '/hangman/win') {
          final nextLevel = settings.arguments as int;
          final currentLevel = nextLevel - 1;
          return MaterialPageRoute(
            builder: (context) => WinScreen(
              nextLevelIndex: nextLevel,
              currentLevel: currentLevel,
            ),
          );
        }
        if (settings.name == '/hangman/lose') {
          final args = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => LoseScreen(
              currentLevelIndex: args,
              currentLevel: args,
            ),
          );
        }
        return null;
      },
    );
  }
}
