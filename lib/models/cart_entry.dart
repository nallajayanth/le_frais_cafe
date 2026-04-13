/// Shared data model passed from any ordering screen into CartScreen.
class CartEntry {
  final String name;
  final double price;
  final String imageUrl;
  int qty;

  CartEntry({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.qty,
  });
}

/// Which mode the user arrived from.
enum OrderMode { dineIn, pickup, delivery }
