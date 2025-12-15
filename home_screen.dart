// lib/screen/home_screen.dart

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../data/mock_data.dart';
import 'recipe_detail_screen.dart';

import 'package:provider/provider.dart'; 
import '../services/theme_service.dart'; 
import '../services/favorite_service.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchText = '';
  bool _showFavorites = false; 
  Set<String> _favoriteIds = {};
  final FavoriteService _favoriteService = FavoriteService();

  String _selectedCategory = 'All'; 
  List<String> _categories = ['All']; 

  
  final Map<String, IconData> _categoryIcons = {
    'All': Icons.restaurant_menu, 
    'Dessert': Icons.cake,
    'Appetizers': Icons.tapas,
    'Soups & Salads': Icons.local_cafe,
    'Breakfast': Icons.egg_alt,
    'Main Dish': Icons.local_dining, 
    'Side Dishes': Icons.fastfood,
    'Beverages': Icons.local_drink,
    
  };

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    
    _categories.addAll(mockRecipes.map((r) => r.category).whereType<String>());
    _categories = _categories.toSet().toList();
    // "All" listenin başında olmasını sağla
    if (!_categories.contains('All')) {
        _categories.insert(0, 'All');
    }
  }

  void _loadFavorites() async {
    final favIds = await _favoriteService.getFavoriteIds(); 
    setState(() {
      _favoriteIds = favIds.toSet();
    });
  }

  // --- Yardımcı Widget: Kategori Butonları (Görselleştirildi) ---
  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category;
          final iconColor = isSelected ? Colors.white : Theme.of(context).colorScheme.primary;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              // 👇 İKON HARİTASI KULLANILDI
              avatar: Icon(
                _categoryIcons[category] ?? Icons.category, 
                color: iconColor,
              ),
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.surface, 
            ),
          );
        }).toList(),
      ),
    );
  }
  
  // Tekli ListTile için yardımcı metot (Animasyonlu)
  Widget _buildRecipeListTile(Recipe recipe) {
    final isFavorite = _favoriteIds.contains(recipe.id);

    return ListTile(
      leading: Icon(
        isFavorite ? Icons.favorite : Icons.star, 
        color: isFavorite ? Colors.redAccent : Theme.of(context).colorScheme.secondary,
      ), 
      title: Text(
        recipe.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Serves ${recipe.servingSize}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async { 
        // 💡 Animasyonlu Sayfa Geçişi
        await Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) => 
                RecipeDetailScreen(recipe: recipe),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                );
            },
          ),
        );
        _loadFavorites(); 
      },
    );
  }
  

  // --- Ana Build Metodu ---

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context); 

    // 1. Filtreleme mantığı: Kategori, Favori ve Arama
    final filteredRecipes = mockRecipes.where((recipe) {
        final isCategoryMatch = _selectedCategory == 'All' || recipe.category == _selectedCategory;
        final isRecipeFavorite = _favoriteIds.contains(recipe.id); 
        final isFavoriteMatch = !_showFavorites || isRecipeFavorite; 
        final isSearchMatch = _searchText.isEmpty || 
                             recipe.title.toLowerCase().contains(_searchText.toLowerCase()) || 
                             recipe.category.toLowerCase().contains(_searchText.toLowerCase());

        return isSearchMatch && isFavoriteMatch && isCategoryMatch; 
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Very Good Meals'), 
        automaticallyImplyLeading: false, 
        actions: [
          // TEMA DEĞİŞTİRME BUTONU
          IconButton(
            icon: Icon(
              themeService.themeMode == ThemeMode.light 
                ? Icons.dark_mode
                : Icons.light_mode,
            ),
            onPressed: () {
              themeService.toggleTheme();
            },
          ),
          
          // FAVORİ FİLTRE BUTONU
          IconButton(
            icon: Icon(
              _showFavorites ? Icons.home : Icons.favorite,
              color: _showFavorites ? Colors.redAccent : null, 
            ),
            onPressed: () {
              setState(() {
                _showFavorites = !_showFavorites;
              });
            },
          ),
        ],
      ),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KATEGORİ SEKMELERİ
          _buildCategoryTabs(),
          
          // ARAMA ÇUBUĞU
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search for recipes...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                labelStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(204), 
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          
          // FİLİTRELENMİŞ TARİF LİSTESİ
          Expanded(
            child: ListView(
              children: [
                // Başlık
                if (filteredRecipes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 8.0),
                    child: Text(
                      _selectedCategory == 'All' ? 'All Recipes' : '$_selectedCategory Recipes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary, 
                      ),
                    ),
                  ),

                // Hata veya Sonuçlar
                ...filteredRecipes.isEmpty && (_searchText.isNotEmpty || _selectedCategory != 'All')
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'No recipes found matching your criteria.',
                            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ]
                  : filteredRecipes.map((recipe) => _buildRecipeListTile(recipe)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}