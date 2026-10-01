import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const DivisorCuentaApp());
}

class DivisorCuentaApp extends StatelessWidget {
  const DivisorCuentaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divide la cuenta',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: const HomeScreen(),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00897B),
      brightness: brightness,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
