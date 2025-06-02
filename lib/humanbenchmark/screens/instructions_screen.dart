// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'game_screen.dart';

class InstructionScreen extends StatefulWidget {
  const InstructionScreen({super.key});

  @override
  State<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen> {
  int _selectedGame = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C4776),
      appBar: AppBar(
        title: const Text(
          'How To Play',
          style: TextStyle(
            fontFamily: 'Fredoka', // Add this line
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Choose a Game',
                  style: TextStyle(
                    fontFamily: 'Fredoka', // Add this line
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGameSelector(),
                const SizedBox(height: 30),
                const Text(
                  'Instructions',
                  style: TextStyle(
                    fontFamily: 'Fredoka', // Add this line
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SingleChildScrollView(
                      child: _selectedGame == 0
                          ? _buildVisualMemoryInstructions()
                          : _buildSequenceMemoryInstructions(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            testType: _selectedGame == 0
                                ? 'Visual Memory'
                                : 'Sequence Memory',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(220, 54),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Play ${_selectedGame == 0 ? 'Visual Memory' : 'Sequence Memory'}',
                          style: const TextStyle(
                              fontFamily: 'Fredoka', // Add this line
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.play_arrow_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameSelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildGameSelectorButton(0, 'Visual Memory'),
          _buildGameSelectorButton(1, 'Sequence Memory'),
        ],
      ),
    );
  }

  Widget _buildGameSelectorButton(int index, String title) {
    final isSelected = _selectedGame == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGame = index;
          });
        },
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5AB0CD) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Fredoka', // Add this line
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualMemoryInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInstructionStep(
          icon: Icons.visibility,
          title: 'Step 1: Watch the Pattern',
          description:
              'A pattern of yellow tiles will flash briefly on the screen.',
        ),
        _buildInstructionStep(
          icon: Icons.touch_app,
          title: 'Step 2: Tap the Tiles',
          description:
              'After the pattern disappears, tap on the tiles that were highlighted.',
        ),
        _buildInstructionStep(
          icon: Icons.trending_up,
          title: 'Step 3: Progress',
          description:
              'With each level you pass, more tiles will be added to the pattern, making it harder to remember.',
        ),
        _buildInstructionStep(
          icon: Icons.favorite,
          title: 'Lives',
          description:
              'You have 3 lives. Selecting an incorrect tile costs you a life. Game ends when all lives are lost.',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildSequenceMemoryInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInstructionStep(
          icon: Icons.visibility,
          title: 'Step 1: Watch the Sequence',
          description:
              'Tiles will light up one after another in a specific sequence.',
        ),
        _buildInstructionStep(
          icon: Icons.touch_app,
          title: 'Step 2: Repeat the Sequence',
          description:
              'After the sequence finishes, tap the tiles in the exact same order they appeared.',
        ),
        _buildInstructionStep(
          icon: Icons.add,
          title: 'Step 3: Growing Sequence',
          description:
              'Each level adds one more tile to the sequence, making it progressively harder to remember.',
        ),
        _buildInstructionStep(
          icon: Icons.favorite,
          title: 'Lives',
          description:
              'You have 3 lives. Making an error in the sequence costs you a life. Game ends when all lives are lost.',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildInstructionStep({
    required IconData icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF5AB0CD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2C4776),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka', // Add this line
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Fredoka', // Add this line
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                if (!isLast) const SizedBox(height: 16),
                if (!isLast)
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.1),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
