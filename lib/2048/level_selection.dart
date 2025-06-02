// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'main.dart';
import 'sound_service.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  LevelSelectionScreenState createState() => LevelSelectionScreenState();
}

class LevelSelectionScreenState extends State<LevelSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isAnimationComplete = false;
  static bool _hasAnimated = false; // Static flag to track if animation has run
  bool _isDarkMode = false;
  final SoundService _soundService = SoundService();

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 500,
      ), // 0.5-second duration per animation
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Initialize sound service
    _soundService.initialize();

    // Run the animation only if it hasn't been played yet
    if (!_hasAnimated) {
      _startAnimationSequence();
      _hasAnimated = true; // Mark animation as played
    } else {
      // If animation has already played, set to completed state immediately
      _isAnimationComplete = true;
      _controller.value = 1.0; // Set animation to end state
    }
  }

  void _startAnimationSequence() {
    // Staggered animation sequence
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimationComplete = true;
        });
      }
    });

    // Start animations with delays
    Future.delayed(const Duration(milliseconds: 0), () {
      if (mounted) {
        _controller.forward(from: 0.0); // "2048" text
      }
    });
    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) {
        _controller.forward(from: 0.0); // "Select Level" text
      }
    });
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) {
        _controller.forward(from: 0.0); // First button (6x6)
      }
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        _controller.forward(from: 0.0); // Second button (5x5)
      }
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        _controller.forward(from: 0.0); // Third button (4x4)
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFE8F4F9),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "2048",
                                style: TextStyle(
                                  color: _isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF2C4776),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 56,
                                  fontFamily:
                                      'Fredoka', // Changed from 'ConcertOne' to 'Fredoka'
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(2, 2),
                                      blurRadius: 5.0,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isDarkMode
                                      ? const Color(0xFF2C4776)
                                      : const Color(0xFF5AB0CD),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    _isDarkMode
                                        ? Icons.light_mode
                                        : Icons.dark_mode,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isDarkMode = !_isDarkMode;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Text(
                            "Select Level",
                            style: TextStyle(
                              color: _isDarkMode
                                  ? Colors.white70
                                  : const Color(0xFF2C4776),
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              fontFamily:
                                  'Fredoka', // Changed from 'ConcertOne' to 'Fredoka'
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildLevelButton(
                          "Easy (6x6)",
                          6,
                          _isDarkMode
                              ? const Color(0xFF13A0DE)
                              : const Color(0xFF5AB0CD),
                          Icons.star_border),
                      const SizedBox(height: 16),
                      _buildLevelButton(
                          "Medium (5x5)",
                          5,
                          _isDarkMode
                              ? const Color(0xFF0CCEF2)
                              : const Color(0xFF4B93D5),
                          Icons.star_half_outlined),
                      const SizedBox(height: 16),
                      _buildLevelButton(
                          "Hard (4x4)",
                          4,
                          _isDarkMode
                              ? const Color(0xFF06EAF8)
                              : const Color(0xFF3E81D2),
                          Icons.star),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _isDarkMode
                                  ? const Color(0xFF2C4776)
                                  : const Color(0xFF5AB0CD),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                _soundService.isSoundEnabled
                                    ? Icons.volume_up
                                    : Icons.volume_off,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  _soundService.toggleSound();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Swipe to combine tiles with the same numbers.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isDarkMode
                        ? Colors.white60
                        : const Color(0xFF2C4776).withOpacity(0.7),
                    fontFamily:
                        'Fredoka', // Changed from 'ConcertOne' to 'Fredoka'
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton(
      String text, int boardSize, Color color, IconData icon) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 260,
          height: 70,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: _isAnimationComplete
                ? () {
                    _soundService.playSwipeSound();
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            MyHomePage(boardSize: boardSize),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var begin = const Offset(1.0, 0.0);
                          var end = Offset.zero;
                          var curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  }
                : null, // Disable button until animation completes
            icon: Icon(icon, size: 28),
            label: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Fredoka', // Changed from 'ConcertOne' to 'Fredoka'
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
              // ignore: deprecated_member_use
              disabledBackgroundColor:
                  color.withOpacity(0.5), // Dimmed when disabled
            ),
          ),
        ),
      ),
    );
  }
}
