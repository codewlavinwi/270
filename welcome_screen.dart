// lib/screen/welcome_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema rengine erişim
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // AppBar kullanmıyoruz, tam ekran karşılama için
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              
              // 1. LOGO GÖRÜNTÜSÜ
              // Logo dosyasını assets/images/ içine eklediğinizden emin olun.
              // Dosya adınız 'tastygo_logo.png' veya 'tastygo_logo.jpg' olabilir.
              // Eğer JPEG kullanıyorsanız burayı 'tastygo_logo.jpg' yapmayı unutmayın!
              Image.asset(
                'assets/images/tastygo_logo.jpg', 
                height: 250, // Logoyu belirginleştirmek için büyük bir boyut
              ),
              
              const SizedBox(height: 40),
              
              // 2. UYGULAMA BAŞLIĞI
              Text(
                'TASTYGO RECIPES',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              
              // 3. KARŞILAMA MESAJI
              const Text(
                'Discover delicious recipes at your fingertips!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 50),
              
              // 4. BAŞLANGIÇ BUTONU
              ElevatedButton(
                onPressed: () {
                  // Ana ekrana geçiş yap ve geri dönüşü engelle (replace)
                  // Navigator.pushReplacement kullanmak Welcome ekranına geri dönüşü engeller.
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}