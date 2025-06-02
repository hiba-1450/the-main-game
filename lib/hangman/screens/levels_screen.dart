import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';
import 'game_screen.dart';
// Make sure StorageHelper is defined in hangman_storage_helper.dart and properly exported.

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  int unlockedLevel = 1;

  void loadLevelProgress() async {
    int level = await StorageHelper
        .getUnlockedLevel(); // Get the highest unlocked level from storage
    setState(() {
      unlockedLevel = level;
    }); // Update the state with the unlocked level
  }

  @override
  void initState() {
    super.initState();
    loadLevelProgress();
  } // Load the level progress when the widget is initialized(runs only one time)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: GraphPaperBackground()),
          SafeArea(
            // SafeArea widget to avoid system UI overlaps
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color.fromARGB(255, 36, 36, 36)),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      final isUnlocked = index <
                          unlockedLevel; // Check if the level is unlocked
                      // If the level index is less than the unlocked level, it is unlocked
                      return GestureDetector(
                        // GestureDetector to handle taps
                        onTap: isUnlocked
                            ? () => Navigator.push(
                                  // Navigate to the game screen
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GameScreen(levelIndex: index),
                                  ),
                                )
                            : null, // If the level is locked, do nothing on tap
                        child: Container(
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? const Color.fromARGB(255, 25, 25, 112)
                                : const Color.fromARGB(255, 17, 35, 94),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              'Level ${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Fredoka', // Add this line
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
      ..color = const Color.fromARGB(255, 43, 43, 43)
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
