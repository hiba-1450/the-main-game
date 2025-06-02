// ignore_for_file: unnecessary_overrides, unnecessary_brace_in_string_interps, deprecated_member_use

import 'package:flutter/material.dart';
import '../utils/word_bank.dart';
import '../utils/storage_helper.dart';

class GameScreen extends StatefulWidget {
  final int levelIndex;

  const GameScreen({super.key, required this.levelIndex});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late String word;
  late String hint;
  Set<String> guessedLetters = {};
  int livesLeft = 7;
  bool gameOver = false;
  bool isWin = false;
  bool hintUsed = false;

  @override
  void initState() {
    super.initState();
    word = levelWords[widget.levelIndex].word.toUpperCase();
    hint = levelWords[widget.levelIndex].hint;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onLetterTap(String letter) async {
    if (guessedLetters.contains(letter) || gameOver) return;

    setState(() {
      guessedLetters.add(letter);
      if (!word.contains(letter)) {
        livesLeft--;
      }
    });

    if (livesLeft == 0) {
      setState(() {
        gameOver = true;
        isWin = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          '/hangman/lose',
          arguments: widget.levelIndex,
        );
      });
      return;
    }

    // Win condition
    if (word.split('').every((l) => guessedLetters.contains(l))) {
      setState(() {
        gameOver = true;
        isWin = true;
      });
      await StorageHelper.unlockNextLevel(widget.levelIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.levelIndex + 1 >= levelWords.length) {
          Navigator.pushReplacementNamed(context, '/levels');
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/hangman/win',
            arguments: widget.levelIndex + 1,
          );
        }
      });
    }
  }

  void useHint() {
    if (hintUsed || gameOver) return;

    final unrevealedLetters =
        word.split('').where((l) => !guessedLetters.contains(l)).toList();

    if (unrevealedLetters.isNotEmpty) {
      setState(() {
        guessedLetters.add(unrevealedLetters.first);
        hintUsed = true;
      });
    }
  }

  // ...rest of your code (buildWordDisplay, buildKeyboard, build method)...

  Widget buildWordDisplay(double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(top: screenWidth * 0.1),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: word.split('').map((letter) {
            final letterBoxWidth =
                screenWidth / (word.length > 10 ? word.length : 10);
            return Container(
              margin: const EdgeInsets.all(4),
              padding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.02,
                horizontal: letterBoxWidth * 0.2,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 29, 29, 29),
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                // Display the letter if guessed, otherwise show an empty string
                guessedLetters.contains(letter) ? letter : '',
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  color: const Color.fromARGB(255, 0, 10, 36),
                  fontFamily:
                      'Fredoka', // Changed from 'ComicNeue' to 'Fredoka'
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildKeyboard(double screenWidth) {
    final List<String> row1 = 'ABCDEFGH'.split('');
    final List<String> row2 = 'IJKLMNO'.split('');
    final List<String> row3 = 'PQRSTU'.split('');
    final List<String> row4 = 'VWXYZ'.split('');

    Widget buildRow(List<String> row) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: row.map((letter) {
          final guessed = guessedLetters.contains(letter);
          return Padding(
            padding: const EdgeInsets.all(4),
            child: GestureDetector(
              onTap: guessed || gameOver
                  ? null
                  : () => onLetterTap(letter), // Handle letter tap
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: screenWidth * 0.095,
                height: screenWidth * 0.11,
                decoration: BoxDecoration(
                  color: guessed
                      ? Color.fromARGB(255, 0, 24, 88)
                      : const Color.fromARGB(255, 17, 35, 94),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  letter,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.045,
                    fontFamily:
                        'Fredoka', // Changed from 'ComicNeue' to 'Fredoka'
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildRow(row1),
        const SizedBox(height: 6),
        buildRow(row2),
        const SizedBox(height: 6),
        buildRow(row3),
        const SizedBox(height: 6),
        buildRow(row4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GraphPaperBackground()),
          Column(
            children: [
              SizedBox(height: screenHeight * 0.05),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        " Level${widget.levelIndex + 1}:$hint",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: screenWidth * 0.055,
                          fontFamily: 'Fredoka', // Add this line
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                height: screenHeight * 0.3,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: List.generate(
                            8 - livesLeft,
                            (index) => Image.asset(
                              'assets/hangman/images/hangman_${index}.png',
                              height: screenHeight * 0.4,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Lives Left as Heart
                    Padding(
                      padding: EdgeInsets.only(right: screenWidth * 0.08),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: const Color.fromARGB(255, 8, 7, 34),
                            size: screenWidth * 0.06,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            "$livesLeft",
                            style: TextStyle(
                              color: const Color.fromARGB(255, 8, 7, 34),
                              fontSize: screenWidth * 0.05,
                              fontFamily: 'Fredoka', // Add this line
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: buildWordDisplay(screenWidth),
              ),
              SizedBox(height: screenHeight * 0.05),
              if (!gameOver)
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 8), // Shadow below the keyboard
                      ),
                    ],
                  ),
                  child: buildKeyboard(screenWidth),
                ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.08),
                child: FloatingActionButton(
                  onPressed: (hintUsed || gameOver) ? null : useHint,
                  backgroundColor: const Color.fromARGB(255, 17, 35, 94),
                  child: const Icon(
                    Icons.lightbulb,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GraphPaperBackground extends StatelessWidget {
  const GraphPaperBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GraphPaperPainter(), child: Container());
  }
}

class _GraphPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 47, 48, 48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.07;

    const squareSize = 020.0;

    for (double x = 0; x < size.width; x += squareSize) {
      for (double y = 0; y < size.height; y += squareSize) {
        canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
