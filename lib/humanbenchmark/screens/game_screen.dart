// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final String testType;
  const GameScreen({required this.testType, super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<int> sequence = [];
  List<int> userSequence = [];
  List<bool> revealed = [];
  bool isShowingSequence = true;
  int level = 1;
  int lives = 3;
  int gridSize = 3;
  int visibleTiles = 3;
  late AnimationController _tileAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();
    _tileAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _updateGridSize();
    startNewRound();
  }

  @override
  void dispose() {
    _tileAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _updateGridSize() {
    if (widget.testType == 'Sequence Memory') {
      gridSize = 3;
    } else {
      if (level < 3) {
        gridSize = 3;
      } else if (level < 6) {
        gridSize = 4;
      } else {
        gridSize = 5;
      }
    }
    revealed = List.generate(gridSize * gridSize, (_) => false);
  }

  void startNewRound() {
    _updateGridSize();

    setState(() {
      userSequence.clear();
      revealed = List.generate(gridSize * gridSize, (_) => false);
      isShowingSequence = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      int totalTiles = gridSize * gridSize;
      if (widget.testType == 'Visual Memory') {
        visibleTiles = min(3 + level - 1, totalTiles);
        Set<int> uniqueTiles = {};
        while (uniqueTiles.length < visibleTiles) {
          uniqueTiles.add(Random().nextInt(totalTiles));
        }
        sequence = uniqueTiles.toList();
      } else {
        sequence.add(Random().nextInt(totalTiles));
      }
      showSequence();
    });
  }

  Future<void> showSequence() async {
    setState(() {
      userSequence.clear();
      isShowingSequence = true;
    });

    if (widget.testType == 'Visual Memory') {
      setState(() {
        for (int index in sequence) {
          revealed[index] = true;
        }
      });

      await Future.delayed(Duration(milliseconds: 800 + (level * 100)));

      setState(() {
        revealed = List.generate(gridSize * gridSize, (_) => false);
        isShowingSequence = false;
      });
    } else {
      for (int i = 0; i < sequence.length; i++) {
        setState(() {
          revealed[sequence[i]] = true;
        });

        await Future.delayed(
            Duration(milliseconds: 500 - (level > 10 ? 200 : level * 20)));

        setState(() {
          revealed[sequence[i]] = false;
        });

        await Future.delayed(const Duration(milliseconds: 200));
      }

      setState(() {
        isShowingSequence = false;
      });
    }
  }

  void checkSequence(int index) {
    if (isShowingSequence || revealed[index]) return;

    if (widget.testType == 'Visual Memory') {
      if (sequence.contains(index) && !userSequence.contains(index)) {
        HapticFeedback.lightImpact();
        setState(() {
          revealed[index] = true;
          userSequence.add(index);
        });

        if (userSequence.toSet().length == sequence.toSet().length) {
          levelUp();
        }
      } else if (!sequence.contains(index)) {
        loseLife();
      }
    } else {
      if (index == sequence[userSequence.length]) {
        HapticFeedback.lightImpact();
        setState(() {
          revealed[index] = true;
          userSequence.add(index);
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              revealed[index] = false;
            });

            if (userSequence.length == sequence.length) {
              levelUp();
            }
          }
        });
      } else {
        loseLife();
      }
    }
  }

  void levelUp() {
    _tileAnimationController.forward(from: 0.0);
    setState(() {
      level++;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        startNewRound();
      }
    });
  }

  void loseLife() {
    HapticFeedback.mediumImpact();

    setState(() {
      lives--;
    });

    if (lives <= 0 && !isGameOver) {
      setState(() {
        isGameOver = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                GameOverScreen(level: level, testType: widget.testType),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = gridSize * gridSize;
    return Scaffold(
      backgroundColor: const Color(0xFF2C4776),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 22),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    widget.testType,
                    style: const TextStyle(
                      fontFamily: 'Fredoka', // Add this line
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Level',
                        style: TextStyle(
                          fontFamily: 'Fredoka', // Add this line
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedBuilder(
                        animation: _tileAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_tileAnimationController.value * 0.2),
                            child: Text(
                              '$level',
                              style: const TextStyle(
                                fontFamily: 'Fredoka', // Add this line
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: Icon(
                          Icons.favorite,
                          color: index < lives
                              ? Colors.red
                              : Colors.grey.withOpacity(0.3),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 6, bottom: 10),
              height: 40,
              child: AnimatedOpacity(
                opacity: isShowingSequence ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5AB0CD),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: const Icon(
                              Icons.visibility,
                              color: Color(0xFF2C4776),
                              size: 18,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Memorize the pattern',
                        style: TextStyle(
                          fontFamily: 'Fredoka', // Add this line
                          color: Color(0xFF2C4776),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: itemCount,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        childAspectRatio: 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => checkSequence(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: revealed[index]
                                  ? const Color(0xFF5AB0CD)
                                  : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: revealed[index]
                                    ? Colors.transparent
                                    : Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: revealed[index]
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF5AB0CD)
                                            .withOpacity(0.5),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 40,
              child: AnimatedOpacity(
                opacity: !isShowingSequence ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: Text(
                    widget.testType == 'Visual Memory'
                        ? 'Tap on all the tiles that were highlighted'
                        : 'Repeat the sequence in the same order',
                    style: TextStyle(
                      fontFamily: 'Fredoka', // Add this line
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
