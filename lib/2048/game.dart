import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'sound_service.dart';

class Game {
  late List<List<int>> board;
  late Random random;
  int score = 0;
  int best = 0;
  final int boardSize; // 4 for 4x4, 5 for 5x5, 6 for 6x6
  final SoundService _soundService = SoundService();
  
  // For undo functionality
  late List<List<int>> _previousBoard;
  int _previousScore = 0;
  bool canUndo = false;

  Map<String, List<int>> mergedTiles = {};
  List<List<int>> newTiles = [];

  Game(this.boardSize) {
    random = Random();
    board = List.generate(boardSize, (_) => List.generate(boardSize, (_) => 0));
    _previousBoard = List.generate(boardSize, (_) => List.generate(boardSize, (_) => 0));
    loadBest();
  }

  void initGame() {
    board = List.generate(boardSize, (_) => List.generate(boardSize, (_) => 0));
    score = 0;
    mergedTiles = {};
    newTiles = [];
    canUndo = false;
    addNewTile();
    addNewTile();
    _savePreviousState();
  }

  // Save the current state before a move
  void _savePreviousState() {
    _previousBoard = List.generate(
      boardSize,
      (r) => List.generate(
        boardSize,
        (c) => board[r][c],
      ),
    );
    _previousScore = score;
  }

  // Restore the previous state (undo)
  void undoMove() {
    if (!canUndo) return;
    
    board = _previousBoard;
    score = _previousScore;
    canUndo = false;
    mergedTiles = {};
    newTiles = [];
    
    // Play a sound for undo
    _soundService.playSwipeSound();
  }

  Future<void> loadBest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    best =
        prefs.getInt('best_$boardSize') ??
        0; // Separate best score for each level
  }

  Future<void> saveBest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best_$boardSize', best);
  }

  void addNewTile() {
    List<List<int>> emptyTiles = [];
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (board[r][c] == 0) {
          emptyTiles.add([r, c]);
        }
      }
    }

    if (emptyTiles.isNotEmpty) {
      int randomIndex = random.nextInt(emptyTiles.length);
      int row = emptyTiles[randomIndex][0];
      int col = emptyTiles[randomIndex][1];
      board[row][col] = random.nextInt(10) < 9 ? 2 : 4;

      newTiles.add([row, col]);
    }
  }

  void moveUp() {
    _savePreviousState();
    mergedTiles = {};
    newTiles = [];
    bool moved = false;

    for (int c = 0; c < boardSize; c++) {
      List<int> column = List.generate(boardSize, (r) => board[r][c]);
      List<int> result = _moveTiles(column, [0, c], [1, 0]);

      if (!_areEqual(column, result)) {
        moved = true;
        for (int r = 0; r < boardSize; r++) {
          board[r][c] = result[r];
        }
      }
    }

    if (moved) {
      _soundService.playSwipeSound();
      checkBest();
      addNewTile();
      canUndo = true;
    }
  }

  void moveDown() {
    _savePreviousState();
    mergedTiles = {};
    newTiles = [];
    bool moved = false;

    for (int c = 0; c < boardSize; c++) {
      List<int> column = List.generate(boardSize, (r) => board[r][c]);
      List<int> result = _moveTiles(
        column.reversed.toList(),
        [boardSize - 1, c],
        [-1, 0],
      );
      result = result.reversed.toList();

      if (!_areEqual(column, result)) {
        moved = true;
        for (int r = 0; r < boardSize; r++) {
          board[r][c] = result[r];
        }
      }
    }

    if (moved) {
      _soundService.playSwipeSound();
      checkBest();
      addNewTile();
      canUndo = true;
    }
  }

  void moveLeft() {
    _savePreviousState();
    mergedTiles = {};
    newTiles = [];
    bool moved = false;

    for (int r = 0; r < boardSize; r++) {
      List<int> row = board[r];
      List<int> result = _moveTiles(row, [r, 0], [0, 1]);

      if (!_areEqual(row, result)) {
        moved = true;
        board[r] = result;
      }
    }

    if (moved) {
      _soundService.playSwipeSound();
      checkBest();
      addNewTile();
      canUndo = true;
    }
  }

  void moveRight() {
    _savePreviousState();
    mergedTiles = {};
    newTiles = [];
    bool moved = false;

    for (int r = 0; r < boardSize; r++) {
      List<int> row = board[r];
      List<int> result = _moveTiles(
        row.reversed.toList(),
        [r, boardSize - 1],
        [0, -1],
      );
      result = result.reversed.toList();

      if (!_areEqual(row, result)) {
        moved = true;
        board[r] = result;
      }
    }

    if (moved) {
      _soundService.playSwipeSound();
      checkBest();
      addNewTile();
      canUndo = true;
    }
  }

  bool _areEqual(List<int> a, List<int> b) {
    for (int i = 0; i < boardSize; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  List<int> _moveTiles(
    List<int> line,
    List<int> basePosition,
    List<int> direction,
  ) {
    List<Map<String, int>> nonZeroWithPosition = [];
    for (int i = 0; i < line.length; i++) {
      if (line[i] != 0) {
        nonZeroWithPosition.add({'value': line[i], 'originalIndex': i});
      }
    }

    for (int i = 0; i < nonZeroWithPosition.length - 1; i++) {
      if (nonZeroWithPosition[i]['value'] ==
          nonZeroWithPosition[i + 1]['value']) {
        nonZeroWithPosition[i]['value'] = nonZeroWithPosition[i]['value']! * 2;
        score += nonZeroWithPosition[i]['value']!;

        // Play merge sound when tiles merge
        _soundService.playMergeSound();
        
        // Check for 2048 achievement
        if (nonZeroWithPosition[i]['value'] == 2048) {
          _soundService.playAchievementSound();
        }

        num originalRow =
            basePosition[0] +
            nonZeroWithPosition[i + 1]['originalIndex']! * direction[0];
        num originalCol =
            basePosition[1] +
            nonZeroWithPosition[i + 1]['originalIndex']! * direction[1];
        int newRow = (basePosition[0] + i * direction[0]).toInt();
        int newCol = (basePosition[1] + i * direction[1]).toInt();

        String key = "$newRow,$newCol";
        mergedTiles[key] = [originalRow.toInt(), originalCol.toInt()];

        nonZeroWithPosition.removeAt(i + 1);
      }
    }

    List<int> result = List.filled(boardSize, 0);
    for (int i = 0; i < nonZeroWithPosition.length; i++) {
      result[i] = nonZeroWithPosition[i]['value']!;
    }

    return result;
  }

  List<int>? lastMergePosition(int row, int col) {
    String key = "$row,$col";
    return mergedTiles[key];
  }

  bool isNewTile(int row, int col) {
    for (var position in newTiles) {
      if (position[0] == row && position[1] == col) {
        return true;
      }
    }
    return false;
  }

  void checkBest() {
    if (score > best) {
      best = score;
      saveBest();
    }
  }

  bool isGameOver() {
    // Check for empty cells
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (board[r][c] == 0) return false;
      }
    }

    // Check horizontal matches
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize - 1; c++) {
        if (board[r][c] == board[r][c + 1]) return false;
      }
    }

    // Check vertical matches
    for (int c = 0; c < boardSize; c++) {
      for (int r = 0; r < boardSize - 1; r++) {
        if (board[r][c] == board[r + 1][c]) return false;
      }
    }

    // Play game over sound when game is actually over
    _soundService.playGameOverSound();
    return true;
  }
}
