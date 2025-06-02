import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final List<String> gameImages = [
    'assets/image/game_2048.png',
    'assets/image/hangman.png',
    'assets/image/level_devil.png',
    'assets/image/memory.png',
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        const AnimatedBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              const SizedBox(height: 50),
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/logomindmatters.png',
                  height: screenHeight / 4,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose a Game',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF24356B),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: gameImages.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        switch (index) {
                          case 0:
                            Navigator.pushNamed(context, '/2048');
                            break;
                          case 1:
                            Navigator.pushNamed(context, '/hangman/levels');
                            break;
                          case 2:
                            Navigator.pushNamed(context, '/escape');
                            break;
                          case 3:
                            Navigator.pushNamed(context, '/humanbenchmark');
                            break;
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          gameImages[index],
                          fit: BoxFit.cover,
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
    );
  }
}
