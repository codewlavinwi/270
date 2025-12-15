// lib/models/recipe.dart

import 'ingredient.dart'; // Yeni Ingredient modelini import et!

class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final List<Ingredient> ingredients; 
  final List<String> instructions;
  final int servingSize;

  // 👇 YENİ ALAN: Pişirme süresi (dakika)
  final int cookingTimeMinutes; 

  const Recipe({ 
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.ingredients, 
    required this.instructions,
    required this.servingSize,
    
    required this.cookingTimeMinutes,
  }); 
}