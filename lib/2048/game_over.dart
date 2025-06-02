// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final VoidCallback onTap;
  final bool isDarkMode;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.onTap,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 320,
          decoration: BoxDecoration(
            color:
                isDarkMode ? const Color(0xFF252525) : const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sentiment_dissatisfied,
                size: 64,
                color: isDarkMode ? Colors.amber : const Color(0xFF5AB0CD),
              ),
              const SizedBox(height: 16),
              Text(
                "Game Over!",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : const Color(0xFF2C4776),
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  fontFamily:
                      'Fredoka', // Changed from 'ConcertOne' to 'Fredoka'
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF2C4776).withOpacity(0.3)
                      : const Color(0xFF5AB0CD).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Your Score: $score",
                  style: TextStyle(
                    color:
                        isDarkMode ? Colors.white70 : const Color(0xFF2C4776),
                    fontSize: 20,
                    fontFamily:
                        'Fredoka', // Changed from 'ConcertOne' to 'Fredoka'
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.refresh),
                label: const Text("Play Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? const Color(0xFF2C4776)
                      : const Color(0xFF5AB0CD),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(
                    fontFamily:
                        'Fredoka', // Changed from 'ConcertOne' to 'Fredoka'
                    fontSize: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
