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
}

/// Which mode the user arrived from.
enum OrderMode { dineIn, pickup, delivery }
