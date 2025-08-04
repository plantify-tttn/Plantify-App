import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = false;

  ThemeData get currentTheme => isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    primaryColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black), // chữ màu xanh
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    primaryColor: Colors.black,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white), // chữ màu đỏ
    ),
  );
}
