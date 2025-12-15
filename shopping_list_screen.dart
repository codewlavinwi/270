// lib/screens/shopping_list_screen.dart

import 'package:flutter/material.dart';
import '../services/pantry_service.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final PantryService _pantryService = PantryService();
  Future<List<String>>? _shoppingListFuture;

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  // Listeyi Shared Preferences'tan yükler
  void _loadShoppingList() {
    setState(() {
      _shoppingListFuture = _pantryService.getShoppingListItems();
    });
  }

  // Bir öğeyi listeden kaldırır ve kullanıcıya geri bildirim verir
  void _removeItem(String item) async {
    await _pantryService.removeShoppingListItem(item);
    _loadShoppingList(); // Listeyi yeniden yükle
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$item removed from the list.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışveriş Listesi 🛒'),
      ),
      body: FutureBuilder<List<String>>(
        future: _shoppingListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Alışveriş listeniz boş. Bir tariften eksik malzemeleri ekleyin!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key(item),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _removeItem(item);
                },
                background: Container(
                  color: Colors.green, // Sağa kaydırıldığında yeşil arka plan
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(item),
                  // Listeden manuel silme butonu
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeItem(item),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}