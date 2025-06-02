// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/intro_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const HumanBenchmarkApp());
}

class HumanBenchmarkApp extends StatelessWidget {
  const HumanBenchmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Human Benchmark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily:
            'Fredoka', // Changed from 'BubblegumSans-Regular' to 'Fredoka'
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C4776),
          primary: const Color(0xFF2C4776),
          secondary: const Color(0xFF5AB0CD),
          background: const Color(0xFFE8F4F9),
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5AB0CD),
            foregroundColor: Colors.white,
            elevation: 3,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF2C4776),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'Fredoka', // Add this line for text buttons
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C4776),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Fredoka', // Add this line for app bar
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      home: const IntroScreen(),
    );
  }
}
