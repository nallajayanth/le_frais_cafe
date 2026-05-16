import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_entry.dart';
import '../services/api/payment_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartEntry> _items = [];
  OrderMode _orderMode = OrderMode.dineIn;
  DiscountCode? _appliedCoupon;

  List<CartEntry> get items => List.unmodifiable(_items);
  OrderMode get orderMode => _orderMode;

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int get totalItems => _items.fold(0, (sum, item) => sum + item.qty);
  double get subtotal => _items.fold(0, (sum, item) => sum + (item.price * item.qty));

  DiscountCode? get appliedCoupon => _appliedCoupon;
  double get couponDiscount {
    if (_appliedCoupon == null) return 0;
    return _appliedCoupon!.calculateDiscount(subtotal);
  }

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
    // Re-validate coupon whenever cart changes
    _revalidateCoupon();
    _saveToPrefs();
    notifyListeners();
  }

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
    _revalidateCoupon();
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
    _revalidateCoupon();
    _saveToPrefs();
    notifyListeners();
  }

  void incrementQuantity(int index) {
    _items[index].qty++;
    _revalidateCoupon();
    _saveToPrefs();
    notifyListeners();
  }

  void decrementQuantity(int index) {
    if (_items[index].qty > 1) {
      _items[index].qty--;
    } else {
      _items.removeAt(index);
    }
    _revalidateCoupon();
    _saveToPrefs();
    notifyListeners();
  }

  void applyCoupon(DiscountCode coupon) {
    _appliedCoupon = coupon;
    notifyListeners();
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }

  // Remove coupon if subtotal drops below its minimum order value
  void _revalidateCoupon() {
    if (_appliedCoupon != null) {
      if (subtotal < _appliedCoupon!.minOrderValue) {
        _appliedCoupon = null;
      }
    }
  }

  void clear() {
    _items.clear();
    _appliedCoupon = null;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = _items.map((e) => e.toJson()).toList();
    await prefs.setString(_cartPrefKey, jsonEncode(itemsJson));
    await prefs.setString(_orderModePrefKey, _orderMode.name);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsString = prefs.getString(_cartPrefKey);
    if (itemsString != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(itemsString);
        _items = decodedList.map((e) => CartEntry.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _items = [];
      }
    }
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
