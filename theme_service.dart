// lib/services/theme_service.dart

import 'package:flutter/material.dart';

// --- TEMA VERİLERİ (Theme Data) ---

// 1. AYDINLIK TEMA TANIMI
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  primaryColor: const Color(0xFFB71C1C), 
  
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFB71C1C), 
    brightness: Brightness.light,
    
    // UYARI GİDERİLDİ: 'background' ve 'onBackground' kaldırıldı.
    surface: Colors.white, 
    onPrimary: Colors.white,
    onSurface: Colors.black87,
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFB71C1C),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
);

// 2. KARANLIK TEMA TANIMI
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  primaryColor: const Color(0xFF7F0000), 

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFB71C1C), 
    brightness: Brightness.dark,

    
    surface: const Color(0xFF1E1E1E), 
    onPrimary: Colors.white,
    onSurface: Colors.white70,
  ),
  
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF7F0000),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
);


// --- TEMA YÖNETİM SERVİSİ ---

class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); 
  }
  
  String get themeModeName {
    return _themeMode == ThemeMode.light ? 'Aydınlık Mod' : 'Karanlık Mod';
  }
}