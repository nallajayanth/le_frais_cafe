/// Shared data model passed from any ordering screen into CartScreen.
class CartEntry {
  final String name;
  final double price;
  final String imageUrl;
  final List<String> selectedOptions;
  final String? instructions;
  int qty;

  CartEntry({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.qty,
    this.selectedOptions = const [],
    this.instructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'qty': qty,
      'selectedOptions': selectedOptions,
      'instructions': instructions,
    };
  }

  factory CartEntry.fromJson(Map<String, dynamic> json) {
    return CartEntry(
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      qty: json['qty'] as int,
      selectedOptions: (json['selectedOptions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      instructions: json['instructions'] as String?,
    );
  }

  bool isSameItem(CartEntry other) {
    if (name != other.name) return false;
    if (instructions != other.instructions) return false;
    
    // Check options (order doesn't matter for logical equality)
    if (selectedOptions.length != other.selectedOptions.length) return false;
    final otherOptions = List<String>.from(other.selectedOptions);
    for (final opt in selectedOptions) {
      if (!otherOptions.remove(opt)) return false;
    }
    
    return true;
  }
}

/// Which mode the user arrived from.
enum OrderMode { dineIn, pickup, delivery }
