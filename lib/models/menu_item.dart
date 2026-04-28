class CustomizationOption {
  final String name;
  final double extraPrice;

  const CustomizationOption({required this.name, this.extraPrice = 0.0});

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      name: json['name'] ?? '',
      extraPrice: (json['extraPrice'] ?? json['extra_price'] ?? 0).toDouble(),
    );
  }
}

class CustomizationGroup {
  final String title;
  final List<CustomizationOption> options;
  final bool isRequired;
  final bool multiSelect;

  const CustomizationGroup({
    required this.title,
    required this.options,
    this.isRequired = false,
    this.multiSelect = false,
  });

  factory CustomizationGroup.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List? ?? [])
        .map((o) => CustomizationOption.fromJson(o as Map<String, dynamic>))
        .toList();
    return CustomizationGroup(
      title: json['title'] ?? json['name'] ?? '',
      options: opts,
      isRequired: json['isRequired'] ?? json['required'] ?? false,
      multiSelect: json['multiSelect'] ?? json['multi_select'] ?? false,
    );
  }
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double? rating;
  final int? ratingCount;
  final String? tag;
  final bool isVeg;
  final bool isAvailable;
  final int preparationTime;
  final List<CustomizationGroup>? customizations;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isVeg,
    this.rating,
    this.ratingCount,
    this.tag,
    this.isAvailable = true,
    this.preparationTime = 15,
    this.customizations,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    List<CustomizationGroup>? customizations;
    final raw = json['customizations'];
    if (raw is List && raw.isNotEmpty) {
      customizations = raw
          .map((c) => CustomizationGroup.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    return MenuItem(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? json['categoryId'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      isVeg: json['isVeg'] ?? json['is_veg'] ?? false,
      rating: json['rating'] != null ? (json['rating']).toDouble() : null,
      ratingCount: json['ratingCount'] ?? json['rating_count'],
      tag: json['tag'],
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      preparationTime: json['prepTime'] ?? json['preparationTime'] ?? 15,
      customizations: customizations,
    );
  }

  static List<MenuItem> get dummyData {
    return [
      MenuItem(
        id: '1',
        name: 'Veg Burger',
        description: 'Classic veggie patty with lettuce, tomato and special sauce.',
        price: 149,
        imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=800&auto=format&fit=crop',
        category: 'Burgers',
        rating: 4.5,
        tag: 'POPULAR',
        isVeg: true,
      ),
      MenuItem(
        id: '2',
        name: 'Chicken Momos',
        description: 'Steamed dumplings filled with minced chicken and spices.',
        price: 179,
        imageUrl: 'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?q=80&w=800&auto=format&fit=crop',
        category: 'Momos',
        rating: 4.8,
        tag: 'BESTSELLER',
        isVeg: false,
      ),
      MenuItem(
        id: '3',
        name: 'Hakka Noodles',
        description: 'Wok-tossed noodles with fresh vegetables and soy sauce.',
        price: 159,
        imageUrl: 'https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?q=80&w=800&auto=format&fit=crop',
        category: 'Noodles',
        rating: 4.3,
        isVeg: true,
      ),
      MenuItem(
        id: '4',
        name: 'Paneer Tikka',
        description: 'Marinated cottage cheese grilled in tandoor with spices.',
        price: 249,
        imageUrl: 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?q=80&w=800&auto=format&fit=crop',
        category: 'Starters',
        rating: 4.7,
        tag: 'POPULAR',
        isVeg: true,
      ),
      MenuItem(
        id: '5',
        name: 'Chicken Fried Rice',
        description: 'Fragrant fried rice with tender chicken and vegetables.',
        price: 199,
        imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?q=80&w=800&auto=format&fit=crop',
        category: 'Rice',
        rating: 4.6,
        isVeg: false,
      ),
    ];
  }
}
