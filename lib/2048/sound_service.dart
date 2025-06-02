import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;

  // Sound effect names
  static const String mergeSound = 'merge.mp3';
  static const String swipeSound = 'swipe.mp3';
  static const String gameOverSound = 'game_over.mp3';
  static const String achievementSound = 'achievement.mp3';

  // Initialize the sounds
  Future<void> initialize() async {
    // Set the global volume (0.0 to 1.0)
    await _audioPlayer.setVolume(0.5);
  }

  // Play a sound effect
  Future<void> playSound(String soundName) async {
    if (!_soundEnabled) return;

    try {
      await _audioPlayer
          .play(AssetSource('2048/sounds/$soundName')); // Corrected path
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
    }
  }

  // Play specific sound effects
  Future<void> playMergeSound() async {
    await playSound(mergeSound);
  }

  Future<void> playSwipeSound() async {
    await playSound(swipeSound);
  }

  Future<void> playGameOverSound() async {
    await playSound(gameOverSound);
  }

  Future<void> playAchievementSound() async {
    await playSound(achievementSound);
  }

  // Toggle sound on/off
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  // Get sound status
  bool get isSoundEnabled => _soundEnabled;
}
