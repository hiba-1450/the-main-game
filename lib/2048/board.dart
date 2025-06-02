// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'game.dart';
import 'tile.dart';

class GameBoard extends StatefulWidget {
  final Game game;
  final double screenWidth;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final bool isDarkMode;

  const GameBoard({
    super.key,
    required this.game,
    required this.screenWidth,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onMoveLeft,
    required this.onMoveRight,
    this.isDarkMode = false,
  });

  @override
  // ignore: library_private_types_in_public_api
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  Offset? _startPosition;
  Offset? _endPosition;
  static const double _minSwipeDistance = 20.0;

  @override
  Widget build(BuildContext context) {
    double boardSize = math.min(widget.screenWidth - 32, 450);
    double cellSize = boardSize / widget.game.boardSize;
    // No spacing between cells and container edge for perfect alignment
    double spacing = 0.0;
    // Set a small gap between cells in the grid
    double gridSpacing = 2.0;
    // Tile size should exactly match cell size minus the grid spacing
    double tileSize = cellSize - gridSpacing;
    double borderRadius = 8.0;

    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            widget.onMoveUp();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            widget.onMoveDown();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            widget.onMoveLeft();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            widget.onMoveRight();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onPanStart: (details) {
          _startPosition = details.localPosition;
        },
        onPanUpdate: (details) {
          _endPosition = details.localPosition;
        },
        onPanEnd: (_) {
          if (_startPosition == null || _endPosition == null) return;

          // Calculate distance and angle
          final dx = _endPosition!.dx - _startPosition!.dx;
          final dy = _endPosition!.dy - _startPosition!.dy;
          final distance = math.sqrt(dx * dx + dy * dy);

          // Only process as swipe if the distance is significant
          if (distance < _minSwipeDistance) return;

          // Determine swipe direction
          if (dx.abs() > dy.abs()) {
            // Horizontal swipe
            if (dx > 0) {
              widget.onMoveRight();
            } else {
              widget.onMoveLeft();
            }
          } else {
            // Vertical swipe
            if (dy > 0) {
              widget.onMoveDown();
            } else {
              widget.onMoveUp();
            }
          }

          // Reset positions
          _startPosition = null;
          _endPosition = null;
        },
        child: Container(
          width: boardSize,
          height: boardSize,
          padding: EdgeInsets.all(spacing),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFD0E6F0),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.game.boardSize,
                  mainAxisSpacing: gridSpacing,
                  crossAxisSpacing: gridSpacing,
                  childAspectRatio: 1.0,
                ),
                itemCount: widget.game.boardSize * widget.game.boardSize,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFE8F4F9),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  );
                },
              ),
              // Tiles
              for (int r = 0; r < widget.game.boardSize; r++)
                for (int c = 0; c < widget.game.boardSize; c++)
                  if (widget.game.board[r][c] != 0)
                    Positioned(
                      // Calculate exact position based on cell and grid spacing
                      left: c * (tileSize + gridSpacing),
                      top: r * (tileSize + gridSpacing),
                      width: tileSize,
                      height: tileSize,
                      child: TileWidget(
                        value: widget.game.board[r][c],
                        row: r,
                        col: c,
                        lastPosition: widget.game.lastMergePosition(r, c),
                        isNew: widget.game.isNewTile(r, c),
                        isDarkMode: widget.isDarkMode,
                        borderRadius: borderRadius,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
