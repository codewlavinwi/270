// lib/models/ingredient.dart

class Ingredient {
  final double quantity; 
  final String unit;     
  final String name;     

  const Ingredient({
    required this.quantity,
    required this.unit,
    required this.name,
  });

  // Yeni porsiyon sayısına göre güncellenmiş Ingredient nesnesi döndürür
  Ingredient scale(double scaleFactor) {
    return Ingredient(
      quantity: quantity * scaleFactor,
      unit: unit,
      name: name,
    );
  }

  // Ekranda gösterilecek metni oluşturur
  @override
  String toString() {
    // Miktarı ondalık ise bir haneye kadar, tam sayı ise tam sayı olarak göster.
    final displayQuantity = quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toStringAsFixed(1);
    
    // Eğer birim boş değilse, birim ile birlikte göster.
    final unitDisplay = unit.isNotEmpty ? '$unit ' : '';
    
    return '$displayQuantity $unitDisplay$name';
  }
}