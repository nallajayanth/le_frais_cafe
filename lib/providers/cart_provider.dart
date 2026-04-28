import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_entry.dart';

class CartProvider extends ChangeNotifier {
  List<CartEntry> _items = [];
  OrderMode _orderMode = OrderMode.dineIn;

  List<CartEntry> get items => List.unmodifiable(_items);
  OrderMode get orderMode => _orderMode;

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int get totalItems => _items.fold(0, (sum, item) => sum + item.qty);
  double get subtotal => _items.fold(0, (sum, item) => sum + (item.price * item.qty));

  static const String _cartPrefKey = 'le_frais_cart_items';
  static const String _orderModePrefKey = 'le_frais_order_mode';

  CartProvider() {
    _loadFromPrefs();
  }

  void updateOrderMode(OrderMode mode) {
    if (_orderMode != mode) {
      _orderMode = mode;
      _saveToPrefs();
      notifyListeners();
    }
  }

  void addItem(CartEntry entry) {
    final index = _items.indexWhere((e) => e.isSameItem(entry));
    if (index >= 0) {
      _items[index].qty += entry.qty;
    } else {
      _items.add(entry);
    }
    _saveToPrefs();
    notifyListeners();
  }

  /// Sets (not increments) the quantity for an item that matches [entry] by
  /// isSameItem equality. If a match exists its qty is replaced; if not the
  /// entry is inserted. Qty ≤ 0 removes the existing entry.
  /// Use this from ItemDetailScreen so tapping "Add to Cart" reflects the
  /// exact stepper value rather than stacking on top of the old cart qty.
  void setItem(CartEntry entry) {
    final index = _items.indexWhere((e) => e.isSameItem(entry));
    if (index >= 0) {
      if (entry.qty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].qty = entry.qty;
      }
    } else if (entry.qty > 0) {
      _items.add(entry);
    }
    _saveToPrefs();
    notifyListeners();
  }

  int getItemQuantity(String itemName) {
    return _items
        .where((e) => e.name == itemName)
        .fold(0, (sum, item) => sum + item.qty);
  }

  int findFirstIndexByName(String itemName) {
    return _items.indexWhere((e) => e.name == itemName);
  }

  void removeItemAt(int index) {
    _items.removeAt(index);
    _saveToPrefs();
    notifyListeners();
  }

  void incrementQuantity(int index) {
    _items[index].qty++;
    _saveToPrefs();
    notifyListeners();
  }

  void decrementQuantity(int index) {
    if (_items[index].qty > 1) {
      _items[index].qty--;
    } else {
      _items.removeAt(index);
    }
    _saveToPrefs();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save items
    final itemsJson = _items.map((e) => e.toJson()).toList();
    await prefs.setString(_cartPrefKey, jsonEncode(itemsJson));
    
    // Save order mode
    await prefs.setString(_orderModePrefKey, _orderMode.name);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load items
    final itemsString = prefs.getString(_cartPrefKey);
    if (itemsString != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(itemsString);
        _items = decodedList.map((e) => CartEntry.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _items = []; // Fallback on error
      }
    }

    // Load order mode
    final modeString = prefs.getString(_orderModePrefKey);
    if (modeString != null) {
      _orderMode = OrderMode.values.firstWhere(
        (e) => e.name == modeString,
        orElse: () => OrderMode.dineIn,
      );
    }

    notifyListeners();
  }
}
