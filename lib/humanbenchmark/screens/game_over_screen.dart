// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'home_screen.dart';

class GameOverScreen extends StatelessWidget {
  final int level;
  final String testType;

  const GameOverScreen({
    required this.level,
    required this.testType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C4776),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2C4776),
              const Color(0xFF2C4776).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5AB0CD).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5AB0CD).withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      size: 40,
                      color: Color(0xFF2C4776),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Game Over',
                    style: TextStyle(
                      fontFamily: 'Fredoka', // Add this line
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          testType,
                          style: const TextStyle(
                            fontFamily: 'Fredoka', // Add this line
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$level',
                              style: const TextStyle(
                                fontFamily: 'Fredoka', // Add this line
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5AB0CD),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Level',
                              style: TextStyle(
                                fontFamily: 'Fredoka', // Add this line
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildAchievementBadge(level),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5AB0CD),
                          foregroundColor: Colors.black,
                          minimumSize: const Size(220, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Try Again',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Fredoka'), // Add fontFamily
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.home_rounded,
                                size: 18, color: Colors.white70),
                            SizedBox(width: 8),
                            Text(
                              'Exit to Home',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontFamily: 'Fredoka', // Add this line
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(int level) {
    String achievement;
    Color badgeColor;
    IconData badgeIcon;

    if (level < 5) {
      achievement = 'Beginner';
      badgeColor = Colors.green.shade300;
      badgeIcon = Icons.emoji_events_outlined;
    } else if (level < 10) {
      achievement = 'Intermediate';
      badgeColor = Colors.blue.shade300;
      badgeIcon = Icons.emoji_events;
    } else if (level < 15) {
      achievement = 'Advanced';
      badgeColor = Colors.orange.shade300;
      badgeIcon = Icons.military_tech_outlined;
    } else {
      achievement = 'Expert';
      badgeColor = Colors.red.shade300;
      badgeIcon = Icons.military_tech;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: badgeColor.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            color: badgeColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            achievement,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'Fredoka', // Add this line
            ),
          ),
        ],
      ),
    );
  }
}
