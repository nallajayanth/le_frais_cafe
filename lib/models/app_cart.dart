import 'cart_entry.dart';

/// A lightweight application-wide cart store.
/// Ordering screens write to it before opening [CartScreen];
/// any other screen can read from it to open the cart directly.
class AppCart {
  AppCart._(); // non-instantiable

  static final List<CartEntry> _items = [];
  static OrderMode _orderMode = OrderMode.dineIn;

  /// The current cart items (unmodifiable snapshot).
  static List<CartEntry> get items => List.unmodifiable(_items);

  /// The order mode associated with the current cart.
  static OrderMode get orderMode => _orderMode;

  /// Whether the cart has any items.
  static bool get isEmpty => _items.isEmpty;

  /// Whether the cart has any items.
  static bool get isNotEmpty => _items.isNotEmpty;

  /// Replace the cart with [items] for the given [mode].
  /// Called by DineIn / Pickup / Delivery / Menu before pushing CartScreen.
  static void update(List<CartEntry> items, OrderMode mode) {
    _items
      ..clear()
      ..addAll(items);
    _orderMode = mode;
  }

  /// Clear the cart (e.g. after order is placed).
  static void clear() {
    _items.clear();
  }
}
