class CustomizationOption {
  final String name;
  final double extraPrice;

  const CustomizationOption({required this.name, this.extraPrice = 0.0});
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
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double? rating;
  final String? tag;
  final bool isVeg;
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
    this.tag,
    this.customizations,
  });

  static List<MenuItem> get dummyData {
    return [
      MenuItem(
        id: '1',
        name: 'Pain au Chocolat',
        description: '24-hour fermented dough with 70% dark Belgian chocolate.',
        price: 6.50,
        imageUrl: 'https://images.unsplash.com/photo-1549903072-7e6e0fdd2a4f?q=80&w=800&auto=format&fit=crop',
        category: 'Bakery',
        rating: 4.9,
        tag: 'VEGAN',
        isVeg: true,
      ),
      MenuItem(
        id: '2',
        name: 'Signature Latte',
        description: 'Single origin Peruvian beans with silky micro-foam.',
        price: 5.25,
        imageUrl: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?q=80&w=800&auto=format&fit=crop',
        category: 'All Day',
        rating: 4.8,
        tag: 'POPULAR',
        isVeg: true,
      ),
      MenuItem(
        id: '3',
        name: 'Forest Green Bowl',
        description: 'Kale, avocado, poached egg, and house-made walnut pesto.',
        price: 14.00,
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=800&auto=format&fit=crop',
        category: 'Breakfast',
        rating: 5.0,
        tag: 'FARM FRESH',
        isVeg: true,
      ),
      MenuItem(
        id: '4',
        name: 'Smoked Salmon Brioche',
        description: 'House smoked salmon on toasted brioche with capers.',
        price: 19.00,
        imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?q=80&w=800&auto=format&fit=crop',
        category: 'Breakfast',
        rating: 4.7,
        isVeg: false,
      ),
      MenuItem(
        id: '5',
        name: 'Almond Croissant',
        description: 'Double baked with frangipane and sliced almonds.',
        price: 7.00,
        imageUrl: 'https://images.unsplash.com/photo-1555507054-d6edcd01362e?q=80&w=800&auto=format&fit=crop',
        category: 'Bakery',
        rating: 4.9,
        isVeg: true,
      ),
    ];
  }
}
