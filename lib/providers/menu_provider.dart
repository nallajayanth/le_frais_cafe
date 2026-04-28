import 'package:flutter/material.dart';
import '../services/api/menu_service.dart';

/// Menu Provider - Manages menu items and categories
class MenuProvider extends ChangeNotifier {
  final MenuService menuService;

  List<MenuCategory> _categories = [];
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategoryId;

  MenuProvider({required this.menuService});

  // Getters
  List<MenuCategory> get categories => _categories;
  List<MenuItem> get menuItems => _menuItems;
  List<MenuItem> get filteredMenuItems => _selectedCategoryId == null
      ? _menuItems
      : _menuItems
            .where((item) => item.category == _selectedCategoryId)
            .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategoryId => _selectedCategoryId;

  /// Load categories
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await menuService.getCategories();
    } on MenuException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all menu items
  Future<void> loadMenuItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _menuItems = await menuService.getMenuItems();
    } on MenuException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load menu items by category
  Future<void> loadMenuItemsByCategory(String categoryId) async {
    _isLoading = true;
    _error = null;
    _selectedCategoryId = categoryId;
    notifyListeners();

    try {
      _menuItems = await menuService.getMenuItems(categoryId: categoryId);
    } on MenuException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search menu items
  Future<void> searchMenuItems(String query) async {
    _isLoading = true;
    _error = null;
    _selectedCategoryId = null; // Clear category filter
    notifyListeners();

    try {
      if (query.isEmpty) {
        await loadMenuItems();
      } else {
        _menuItems = await menuService.searchMenuItems(query);
      }
    } on MenuException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get single menu item
  Future<MenuItem?> getMenuItem(String itemId) async {
    try {
      return await menuService.getMenuItem(itemId);
    } on MenuException catch (e) {
      _error = e.message;
      return null;
    }
  }

  /// Filter by category (UI-only)
  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh menu data
  Future<void> refresh() async {
    await Future.wait([loadCategories(), loadMenuItems()]);
  }
}
