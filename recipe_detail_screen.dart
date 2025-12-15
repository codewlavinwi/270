// lib/screens/recipe_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';

import '../services/favorite_service.dart';
import 'dart:async'; 
import '../services/pantry_service.dart';
import 'shopping_list_screen.dart'; // 💡 YENİ: Alışveriş Listesi Ekranını import edin

// Ana widget, favori durumunu yönetmek için StatefulWidget olmalıdır.
class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({required this.recipe, super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

// State Sınıfı: Favori durumu, Zamanlayıcı, Eksik Malzemeleri ve Porsiyonu yönetir.
class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final PantryService _pantryService = PantryService(); 
  
  bool _isFavorite = false; 
  
  // Porsiyon Ölçeklendirme Değişkeni
  late int _currentServingSize; 
  
  // Zamanlayıcı Ayarları
  late int _initialSeconds; 
  int _secondsRemaining = 0; 
  
  bool _isRunning = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    
    _currentServingSize = widget.recipe.servingSize; 
    
    // ZAMANLAYICI BAŞLANGIÇ AYARI
    _initialSeconds = widget.recipe.cookingTimeMinutes * 60;
    _secondsRemaining = _initialSeconds;
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkFavoriteStatus() async {
    bool isFav = await _favoriteService.isFavorite(widget.recipe.id);
    setState(() {
      _isFavorite = isFav;
    });
  }

  void _toggleFavorite() async {
    await _favoriteService.toggleFavorite(widget.recipe.id);
    _checkFavoriteStatus(); 
  }
  
  // --- ZAMANLAYICI METOTLARI ---
  
  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
            _isRunning = false;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Süre bitti! Yemek hazır olmalı!')),
            );
          }
        });
      });
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _initialSeconds; 
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }


  // --- EKSİK MALZEME MANTIĞI ---

  Future<List<String>> _getMissingIngredients() async {
    final pantryItems = await _pantryService.getPantryItems();
    
    final Set<String> pantrySet = pantryItems
        .map((item) => item.toLowerCase())
        .toSet();

    List<String> missingItems = [];
    for (var recipeIngredient in widget.recipe.ingredients) {
      // Burası scaledIngredient.toString() formatında bir metin döndürür
      final ingredientName = recipeIngredient.name;
      
      if (!pantrySet.contains(ingredientName.toLowerCase())) {
          missingItems.add(recipeIngredient.toString()); 
      }
    }

    return missingItems;
  }
  
  // --- Yardımcı Yapı Metotları ---
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary, 
        ), 
      ),
    );
  }


  // --- PORSIYON ÖLÇEKLENDİRMELİ MALZEME LİSTESİ ---

  Widget _buildIngredientList() {
    final double scaleFactor = _currentServingSize / widget.recipe.servingSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.recipe.ingredients.map((ingredient) {
        // Ingredient objesini ölçekle
        final scaledIngredient = (ingredient as dynamic).scale(scaleFactor); // Type casting for Ingredient object
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('- ${scaledIngredient.toString()}'), // scaledIngredient.toString() çağrılır
        );
      }).toList(),
    );
  }


  // --- GÜZELLEŞTİRİLMİŞ TALİMAT LİSTESİ METODU ---
  Widget _buildInstructionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.recipe.instructions
          .asMap()
          .entries
          .map((entry) {
            final stepNumber = entry.key + 1;
            final instructionText = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Numaralı Daire (Görsel Adım Sayacı)
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary, 
                    ),
                    child: Text(
                      stepNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // 2. Talimat Metni
                  Expanded(
                    child: Text(
                      instructionText,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(),
    );
  }

  // --- Ana Build Metodu ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
        actions: [
          // 👇 GÜNCELLENMİŞ Alışveriş Listesi Butonu
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () async {
              final missingItems = await _getMissingIngredients();
              
              if (!context.mounted) return; 
              
              showDialog(
                context: context, 
                builder: (ctx) => AlertDialog(
                  title: const Text('Missing Ingredients 🛒'),
                  content: Text(missingItems.isEmpty 
                      ? 'Harika! Bu tarif için tüm malzemeleriniz evde mevcut.' 
                      // Eksik malzemeler varsa, listeyi ekleme seçeneği ile göster
                      :"The following ingredients are missing:\n\n${missingItems.join('\n')}"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Off'),
                    ),
                    if (missingItems.isNotEmpty) 
                      TextButton(
                        onPressed: () async {
                          // 1. Eksik malzemeleri kalıcı listeye ekle
                          await _pantryService.addMissingItemsToShoppingList(missingItems);
                          
                          if (!mounted) return;
                          
                          // 2. Diyalogu kapat
                          Navigator.of(ctx).pop(); 
                          
                          // 3. Alışveriş Listesi ekranına yönlendir
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Missing ingredients added to shopping list.')),
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => const ShoppingListScreen(),
                            ),
                          );
                        },
                        child: const Text(' Add to Shopping List'),
                      ),
                  ],
                ),
              );
            },
          ),
          // Favori Butonu
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ... (Görsel Bölümü)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withAlpha(128), 
                  borderRadius: BorderRadius.circular(10),
                ),
                child: widget.recipe.imageUrl.isNotEmpty
                    ? ClipRRect( 
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          widget.recipe.imageUrl, 
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 300,
                        ),
                      )
                    : Center( 
                        child: Text(
                          'Recipe Image Placeholder',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              
              // Orijinal Kategori Bilgisi
              Text(
                'Category: ${widget.recipe.category}',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary.withAlpha(178), 
                ),
              ),
              
              // MERKEZE HİZALI PORSIYON SEÇİM KONTROLÜ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Porsiyon: $_currentServingSize',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: _currentServingSize > 1
                        ? () {
                              setState(() {
                                _currentServingSize--;
                              });
                            }
                        : null, // Porsiyon 1'den küçük olamaz
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      setState(() {
                        _currentServingSize++;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20), 
              
              // Malzemeler Başlık
              _buildSectionTitle(context, 'Ingredients'),
              
              // Malzemeler Listesi (Sadece ölçeklendirilebilir)
              _buildIngredientList(),

              const SizedBox(height: 20),
              const Divider(),
              
              // ZAMANLAYICI ARAYÜZÜ
              _buildSectionTitle(context, 'Cooking Timer'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatTime(_secondsRemaining),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      // Başlat/Durdur Butonu
                      IconButton(
                        icon: Icon(
                          _isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _toggleTimer,
                      ),
                      // Sıfırla Butonu
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          size: 30,
                          color: Colors.grey,
                        ),
                        onPressed: _resetTimer,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              
              // Yapılışı Başlık
              _buildSectionTitle(context, 'Instructions'),
              
              // Yapılışı Adımları (Güzelleştirilmiş)
              _buildInstructionsList(),
            ],
          ),
        ),
      ),
    );
  }
}