// lib/services/pantry_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class PantryService {
  static const String _pantryKey = 'pantryItems';
  static const String _shoppingListKey = 'shoppingListItems'; // Yeni anahtar

  // --- KİLER (PANTRY) İŞLEVLERİ ---
  
  // Mevcut Kiler (Pantry) işlevi (kullanıcının elindeki malzemeler)
  Future<List<String>> getPantryItems() async {
    final prefs = await SharedPreferences.getInstance();
    // Burası, kullanıcının kilerinde ne olduğunu döndürmelidir.
    // Başlangıç değerlerini küçük harfe çevirerek tutarlılığı artırabiliriz
    return prefs.getStringList(_pantryKey) ?? ['un', 'süt', 'yumurta', 'tuz', 'yağ'];
  }

  // 👇 YENİ EKLENEN METOT: Kilerdeki öğeleri kaydeder (PantryScreen'in ihtiyacı)
  Future<void> savePantryItems(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pantryKey, items);
  }

  // --- ALIŞVERİŞ LİSTESİ İŞLEVLERİ ---

  // Alışveriş listesini çeker
  Future<List<String>> getShoppingListItems() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_shoppingListKey) ?? [];
  }

  // Yeni malzemeleri listeye ekler (duplicate kontrolü yaparak)
  Future<void> addMissingItemsToShoppingList(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentList = prefs.getStringList(_shoppingListKey) ?? [];
    
    // Tekrarlanan öğeleri önlemek için Set kullanın
    final Set<String> currentSet = currentList.toSet();
    
    for (var item in items) {
      // Sadece listeye eklenmemiş yeni malzemeleri ekle
      // (item.toString() çağrısı, RecipeDetailScreen'den gelen scaledIngredient.toString() formatına uygun olmalıdır)
      if (!currentSet.contains(item)) {
          currentList.add(item);
      }
    }
    await prefs.setStringList(_shoppingListKey, currentList);
  }

  // Bir öğeyi listeden kaldırır (satın alındı olarak işaretlemek veya silmek için)
  Future<void> removeShoppingListItem(String item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> currentList = prefs.getStringList(_shoppingListKey) ?? [];
    currentList.remove(item);
    await prefs.setStringList(_shoppingListKey, currentList);
  }
}