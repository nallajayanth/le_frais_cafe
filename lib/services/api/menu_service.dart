import 'api_client.dart';

/// Menu Service - Fetch menu items, categories, search
class MenuService {
  final ApiClient apiClient;

  MenuService({required this.apiClient});

  /// Fetch all menu categories
  Future<List<MenuCategory>> getCategories() async {
    try {
      final response = await apiClient.get(
        '/menu/categories',
        requiresAuth: false,
      );
      final categories = (response['data'] as List)
          .map((item) => MenuCategory.fromJson(item as Map<String, dynamic>))
          .toList();
      return categories;
    } on ApiException catch (e) {
      throw MenuException(e.message);
    }
  }

  /// Fetch all menu items
  Future<List<MenuItem>> getMenuItems({String? categoryId}) async {
    try {
      String endpoint = '/menu';
      if (categoryId != null) {
        endpoint += '?categoryId=$categoryId';
      }

      final response = await apiClient.get(endpoint, requiresAuth: false);
      final items = (response['data'] as List)
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList();
      return items;
    } on ApiException catch (e) {
      throw MenuException(e.message);
    }
  }

  /// Search menu items
  Future<List<MenuItem>> searchMenuItems(String query) async {
    try {
      final response = await apiClient.get(
        '/menu/search?query=$query',
        requiresAuth: false,
      );
      final items = (response['data'] as List)
          .map((item) => MenuItem.fromJson(item as Map<String, dynamic>))
          .toList();
      return items;
    } on ApiException catch (e) {
      throw MenuException(e.message);
    }
  }

  /// Get single menu item details
  Future<MenuItem> getMenuItem(String itemId) async {
    try {
      final response = await apiClient.get(
        '/menu/$itemId',
        requiresAuth: false,
      );
      return MenuItem.fromJson(response['data'] as Map<String, dynamic>);
    } on ApiException catch (e) {
      throw MenuException(e.message);
    }
  }
}

/// Menu Category Model
class MenuCategory {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  MenuCategory({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}

/// Menu Item Model
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final List<String> dietary;
  final bool isAvailable;
  final int preparationTime;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.dietary,
    required this.isAvailable,
    required this.preparationTime,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      dietary: List<String>.from(json['dietary'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      preparationTime: json['preparationTime'] ?? 15,
    );
  }
}

/// Menu Exception
class MenuException implements Exception {
  final String message;

  MenuException(this.message);

  @override
  String toString() => 'MenuException: $message';
}
