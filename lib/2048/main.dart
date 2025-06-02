// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'game.dart';
import 'board.dart';
import 'score_board.dart';
import 'game_over.dart';
import 'level_selection.dart';
import 'sound_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C4776),
          brightness: Brightness.light,
        ),
      ),
      home: const LevelSelectionScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int boardSize;

  const MyHomePage({super.key, required this.boardSize});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Game game;
  final SoundService _soundService = SoundService();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    game = Game(widget.boardSize);
    game.initGame();
    _soundService.initialize();
  }

  // Function to undo the last move
  void _undoMove() {
    if (game.canUndo) {
      setState(() {
        game.undoMove();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor:
          _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFE8F4F9),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: _isDarkMode
                            ? const Color(0xFF5AB0CD)
                            : const Color(0xFF2C4776),
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "2048",
                        style: TextStyle(
                          color: _isDarkMode
                              ? Colors.white
                              : const Color(0xFF2C4776),
                          fontWeight: FontWeight.bold,
                          fontSize: 42,
                          fontFamily:
                              'Fredoka', // Changed from 'ConcertOne' to 'Fredoka'
                          shadows: [
                            Shadow(
                              offset: const Offset(1, 1),
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ScoreBoard(
                          title: "Score",
                          score: game.score,
                          isDarkMode: _isDarkMode),
                      const SizedBox(width: 1),
                      ScoreBoard(
                          title: "Best",
                          score: game.best,
                          isDarkMode: _isDarkMode),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            game.initGame();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("New Game"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDarkMode
                              ? const Color(0xFF2C4776)
                              : const Color(0xFF5AB0CD),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _undoMove,
                        icon: const Icon(Icons.undo),
                        label: const Text("Undo"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDarkMode
                              ? const Color(0xFF2C4776)
                              : const Color(0xFF5AB0CD),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _soundService.isSoundEnabled
                              ? Icons.volume_up
                              : Icons.volume_off,
                          color: _isDarkMode
                              ? Colors.white
                              : const Color(0xFF2C4776),
                        ),
                        onPressed: () {
                          setState(() {
                            _soundService.toggleSound();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                          color: _isDarkMode
                              ? Colors.white
                              : const Color(0xFF2C4776),
                        ),
                        onPressed: () {
                          setState(() {
                            _isDarkMode = !_isDarkMode;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Join the tiles and get to 2048!",
                style: TextStyle(
                  color: _isDarkMode ? Colors.white70 : const Color(0xFF2C4776),
                  fontWeight: FontWeight.bold,
                  fontFamily:
                      'Fredoka', // Changed from 'ConcertOne' to 'Fredoka'
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GameBoard(
                    game: game,
                    screenWidth: screenWidth,
                    isDarkMode: _isDarkMode,
                    onMoveUp: () {
                      setState(() {
                        game.moveUp();
                      });
                    },
                    onMoveDown: () {
                      setState(() {
                        game.moveDown();
                      });
                    },
                    onMoveLeft: () {
                      setState(() {
                        game.moveLeft();
                      });
                    },
                    onMoveRight: () {
                      setState(() {
                        game.moveRight();
                      });
                    },
                  ),
                  if (game.isGameOver())
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: GameOverDialog(
                            score: game.score,
                            isDarkMode: _isDarkMode,
                            onTap: () {
                              setState(() {
                                game.initGame();
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
