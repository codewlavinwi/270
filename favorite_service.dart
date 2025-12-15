// lib/services/favorite_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoritesKey = 'favoriteRecipeIds';

  // home_screen'in ihtiyacı olan KRİTİK METOT
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? []; 
  }

  // recipe_detail_screen'in ihtiyacı
  Future<void> toggleFavorite(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favorites = prefs.getStringList(_favoritesKey) ?? [];

    if (favorites.contains(recipeId)) {
      favorites.remove(recipeId);
    } else {
      favorites.add(recipeId);
    }

    await prefs.setStringList(_favoritesKey, favorites);
  }
  
  // recipe_detail_screen'in ihtiyacı
  Future<bool> isFavorite(String recipeId) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(recipeId);
  }
}