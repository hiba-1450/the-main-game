// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'tile_animation.dart';

class TileWidget extends StatefulWidget {
  final int value;
  final int row;
  final int col;
  final List<int>? lastPosition;
  final bool isNew;
  final bool isDarkMode;
  final double borderRadius;

  const TileWidget({
    super.key,
    required this.value,
    required this.row,
    required this.col,
    this.lastPosition,
    required this.isNew,
    this.isDarkMode = false,
    this.borderRadius = 8.0,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TileWidgetState createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: widget.isNew ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.lastPosition != null
        ? TileAnimation(
            startRow: widget.lastPosition![0],
            startCol: widget.lastPosition![1],
            endRow: widget.row,
            endCol: widget.col,
            child: _buildTile(),
          )
        : ScaleTransition(scale: _scaleAnimation, child: _buildTile());
  }

  Widget _buildTile() {
    return Container(
      // Take up the entire space with no margin
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: getColor(widget.value),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text(
              widget.value != 0 ? "${widget.value}" : "",
              style: TextStyle(
                color: getTextColor(widget.value),
                fontSize: getFontSize(widget.value),
                fontWeight: FontWeight.bold,
                fontFamily: 'ConcertOne',
              ),
            ),
          ),
        ),
      ),
    );
  }

  double getFontSize(int value) {
    if (value > 512) return 22;
    if (value > 64) return 24;
    return 28;
  }

  Color getTextColor(int value) {
    return widget.isDarkMode
        ? (value <= 4 ? const Color(0xFFE0E0E0) : Colors.white)
        : (value <= 4 ? const Color(0xFF776E65) : Colors.white);
  }

  Color getColor(int value) {
    if (widget.isDarkMode) {
      // Dark mode colors
      switch (value) {
        case 0:
          return const Color(0xFF2A2A2A);
        case 2:
          return const Color(0xFF3D3A33);
        case 4:
          return const Color(0xFF4A4639);
        case 8:
          return const Color(0xFF2C4776);
        case 16:
          return const Color(0xFF1F5B96);
        case 32:
          return const Color(0xFF1A6FB5);
        case 64:
          return const Color(0xFF148AD4);
        case 128:
          return const Color(0xFF13A0DE);
        case 256:
          return const Color(0xFF10B7E8);
        case 512:
          return const Color(0xFF0CCEF2);
        case 1024:
          return const Color(0xFF09DCF5);
        case 2048:
          return const Color(0xFF06EAF8);
        default:
          return const Color(0xFF03F7FB); // Higher numbers
      }
    } else {
      // Light mode colors - more vibrant and modern
      switch (value) {
        case 0:
          return const Color(0xFFE8F4F9);
        case 2:
          return const Color(0xFFeee4da);
        case 4:
          return const Color(0xFFede0c8);
        case 8:
          return const Color(0xFF5AB0CD);
        case 16:
          return const Color(0xFF59A5D8);
        case 32:
          return const Color(0xFF4B93D5);
        case 64:
          return const Color(0xFF3E81D2);
        case 128:
          return const Color(0xFF326FD0);
        case 256:
          return const Color(0xFF245DCD);
        case 512:
          return const Color(0xFF204FC9);
        case 1024:
          return const Color(0xFF1C41C6);
        case 2048:
          return const Color(0xFF1830C3);
        default:
          return const Color(0xFF142CC0); // Higher numbers
      }
    }
  }
}
