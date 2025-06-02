import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  // Unlock the next level after the current one
  static Future<void> unlockNextLevel(int currentLevelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedLevel = prefs.getInt('unlocked_level') ?? 1;
    final nextLevel = currentLevelIndex + 1;

    if (nextLevel > unlockedLevel) {
      await prefs.setInt('unlocked_level', nextLevel);
    }
  }

  static Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unlocked_level') ?? 1;
  }

  // COINS MANAGEMENT
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('coins') ?? 0;
  }

  static Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('coins') ?? 0;
    await prefs.setInt('coins', current + amount);
  }

  static Future<bool> subtractCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('coins') ?? 0;
    if (current >= amount) {
      await prefs.setInt('coins', current - amount);
      return true;
    }
    return false;
  }

  // HINT USAGE TRACKING PER LEVEL
  static Future<bool> getHintUsedForLevel(int levelIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hint_used_$levelIndex') ?? false;
  }

  static Future<void> setHintUsedForLevel(int levelIndex, bool used) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hint_used_$levelIndex', used);
  }
}
