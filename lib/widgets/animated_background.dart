// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    // Wave animation controller
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return CustomPaint(
          painter: BackgroundPainter(
            waveValue: _waveController.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double waveValue;

  BackgroundPainter({
    required this.waveValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Create gradient background
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color.fromARGB(255, 57, 82, 167),
        Color(0xFF24356B),
        Color.fromARGB(255, 219, 229, 255),
      ],
      stops: [
        0.0,
        0.3,
        0.6,
        1.0,
      ],
    );

    // Draw gradient background
    paint.shader = gradient.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);

    // Draw multiple wave layers with enhanced effect
    drawEnhancedWaves(canvas, size, paint);
  }

  void drawEnhancedWaves(Canvas canvas, Size size, Paint paint) {
    final width = size.width;
    final height = size.height;

    // Create multiple wave layers with different properties
    for (var i = 0; i < 5; i++) {
      final path = Path();
      final waveOffset = i * 0.2;
      final opacity = 0.15 - (i * 0.02);
      final amplitude = height * 0.08 * (1 - (i * 0.15));
      final frequency = (i % 2 == 0) ? 3.0 : 2.5;

      path.moveTo(0, height);

      // Draw wave path
      for (var x = 0.0; x <= width; x++) {
        final normalizedX = x / width;
        final phase = waveValue * 2 * math.pi + waveOffset;
        final y = height * 0.5 +
            amplitude * math.sin((normalizedX * frequency * math.pi) + phase) +
            amplitude *
                0.5 *
                math.cos((normalizedX * frequency * 2 * math.pi) + phase);

        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      // Complete the wave path
      path.lineTo(width, height);
      path.lineTo(0, height);

      // Create gradient for wave
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(0),
        ],
      ).createShader(Offset.zero & size);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
