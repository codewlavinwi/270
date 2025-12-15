// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider importu
import 'screen/welcome_screen.dart';
import 'services/theme_service.dart'; // ThemeService importu

// 1. Tema Renklerini Dışarı Taşıyoruz
const Color softOrange = Color(0xFFFF9F68); 
const Color lightSoftOrange = Color(0xFFFFDAC1);
const Color darkPrimary = Color(0xFFE91E63); // Koyu mod için belirgin bir renk (Örn: Pembe/Kırmızı)

void main() {
  // 2. Uygulamayı Provider ile sarıyoruz (Durum Yönetimi)
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeService(), // Tema yöneticisini oluştur
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // LIGHT TEMA TANIMI
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: softOrange,
        secondary: lightSoftOrange, 
        onPrimary: Colors.white,
        
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF8F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: softOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: const TextTheme(
          // Font boyutlarını da burada ayarlayabilirsiniz
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: softOrange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // DARK TEMA TANIMI
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary, // Koyu mod birincil rengi
        secondary: Color(0xFF3700B3), // Koyu mod ikincil rengi (Örn: Koyu Mor)
        surface: Color(0xFF121212), 
        
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF1F1F1F), 
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212), // AppBar daha koyu
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Diğer widget'ların (örneğin Card'lar) karanlık temaya uyum sağlamasını sağlar.
      cardColor: const Color(0xFF2C2C2C), 
      // ... Diğer Dark Tema ayarları
      // Karanlık modda Elevated Button stilini de ayarlayalım:
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary, // Karanlık mod ana rengi
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3. ThemeService'ı dinle
    // Tema modu değiştiğinde bu widget otomatik olarak yeniden inşa edilir.
    final themeService = Provider.of<ThemeService>(context); 

    return MaterialApp(
      title: 'These are Very Good Meals',
      debugShowCheckedModeBanner: false,
      
      // Temaları themeMode ile bağlıyoruz
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeService.themeMode, // ThemeService'dan gelen modu kullan
      
      home: const WelcomeScreen(),
    );
  }
}