import 'package:flutter/material.dart';
import 'board.dart';

class TileAnimation extends StatefulWidget {
  final Widget child;
  final int startRow;
  final int startCol;
  final int endRow;
  final int endCol;

  const TileAnimation({
    super.key,
    required this.child,
    required this.startRow,
    required this.startCol,
    required this.endRow,
    required this.endCol,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TileAnimationState createState() => _TileAnimationState();
}

class _TileAnimationState extends State<TileAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate position differences
        double rowDiff = (widget.endRow - widget.startRow).toDouble();
        double colDiff = (widget.endCol - widget.startCol).toDouble();

        // Get the tile cell size based on the MediaQuery width
        double screenWidth = MediaQuery.of(context).size.width;
        double boardSize = screenWidth > 500 ? 450 : screenWidth - 32;
        
        // Find the GameBoard ancestor to get the correct board size
        final GameBoard? gameBoard = context.findAncestorWidgetOfExactType<GameBoard>();
        int boardDimension = gameBoard?.game.boardSize ?? 4; // Default to 4 if not found
        
        // Recalculate using the same logic as in the GameBoard widget
        double cellSize = boardSize / boardDimension;
        double gridSpacing = 2.0; // Match the spacing in GameBoard
        double tileSize = cellSize - gridSpacing;
        
        // Calculate current position based on animation value and new grid layout
        double currentRowOffset = (rowDiff * (1 - _animation.value)) * (tileSize + gridSpacing);
        double currentColOffset = (colDiff * (1 - _animation.value)) * (tileSize + gridSpacing);

        return Transform.translate(
          offset: Offset(
            -currentColOffset,
            -currentRowOffset,
          ),
          child: widget.child,
        );
      },
    );
  }
}
