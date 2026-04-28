import 'api_client.dart';
import '../../models/menu_item.dart';

export '../../models/menu_item.dart' show MenuItem, CustomizationGroup, CustomizationOption;

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
  Future<List<MenuItem>> getMenuItems({String? categoryId, bool? isVeg}) async {
    try {
      String endpoint = '/menu';
      final params = <String>[];
      if (categoryId != null) params.add('categoryId=$categoryId');
      if (isVeg != null) params.add('isVeg=$isVeg');
      if (params.isNotEmpty) endpoint += '?${params.join('&')}';

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
      final encoded = Uri.encodeQueryComponent(query);
      final response = await apiClient.get(
        '/menu/search?query=$encoded',
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
  final int? sortOrder;

  MenuCategory({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.sortOrder,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      sortOrder: json['sortOrder'],
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
