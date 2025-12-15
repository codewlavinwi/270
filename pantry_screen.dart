// lib/screens/pantry_screen.dart

import 'package:flutter/material.dart';
import '../services/pantry_service.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final PantryService _pantryService = PantryService();
  final TextEditingController _controller = TextEditingController();
  List<String> _pantryItems = [];

  @override
  void initState() {
    super.initState();
    _loadPantryItems();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadPantryItems() async {
    // getPantryItems metodu PantryService'te tanımlı olmalıdır
    final items = await _pantryService.getPantryItems(); 
    setState(() {
      _pantryItems = items;
    });
  }

  void _addItem() {
    final item = _controller.text.trim();
    if (item.isNotEmpty) {
      final normalizedItem = item.toLowerCase();
      
      // Tekrar eden girişi engelle (küçük harfle karşılaştır)
      if (!_pantryItems.map((e) => e.toLowerCase()).contains(normalizedItem)) {
        setState(() {
          _pantryItems.add(item); 
          // savePantryItems metodu PantryService'te tanımlı olmalıdır
          _pantryService.savePantryItems(_pantryItems); 
        });
        _controller.clear();
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$item is already in your pantry.')),
          );
        }
      }
    }
  }

  void _removeItem(String item) {
    setState(() {
      _pantryItems.remove(item);
      // savePantryItems metodu PantryService'te tanımlı olmalıdır
      _pantryService.savePantryItems(_pantryItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry Items'), 
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Add New Ingredient', // İngilizce Çeviri
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 30),
                  color: Theme.of(context).colorScheme.primary, // Tema rengi
                  onPressed: _addItem,
                ),
              ],
            ),
          ),
          Expanded(
            child: _pantryItems.isEmpty
                ? Center(
                    child: Text(
                      'Your pantry is empty. Add some ingredients!', // İngilizce Çeviri
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: _pantryItems.length,
                    itemBuilder: (context, index) {
                      final item = _pantryItems[index];
                      return ListTile(
                        title: Text(item),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _removeItem(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}