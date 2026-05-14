/// Food items for the game with emojis and metadata
class FoodItem {
  final String emoji;
  final String name;
  final String description;

  const FoodItem({
    required this.emoji,
    required this.name,
    required this.description,
  });
}

class FoodItems {
  static const List<FoodItem> items = [
    FoodItem(
      emoji: '🍕',
      name: 'Pizza',
      description: 'Delicious pizza',
    ),
    FoodItem(
      emoji: '🍔',
      name: 'Burger',
      description: 'Juicy burger',
    ),
    FoodItem(
      emoji: '🍟',
      name: 'Fries',
      description: 'Golden fries',
    ),
    FoodItem(
      emoji: '☕',
      name: 'Coffee',
      description: 'Hot coffee',
    ),
    FoodItem(
      emoji: '🍣',
      name: 'Sushi',
      description: 'Fresh sushi',
    ),
    FoodItem(
      emoji: '🌮',
      name: 'Taco',
      description: 'Tasty taco',
    ),
    FoodItem(
      emoji: '🍗',
      name: 'Chicken',
      description: 'Crispy chicken',
    ),
    FoodItem(
      emoji: '🥗',
      name: 'Salad',
      description: 'Fresh salad',
    ),
    FoodItem(
      emoji: '🍜',
      name: 'Noodles',
      description: 'Hot noodles',
    ),
    FoodItem(
      emoji: '🍰',
      name: 'Cake',
      description: 'Sweet cake',
    ),
    FoodItem(
      emoji: '🥤',
      name: 'Drink',
      description: 'Cold drink',
    ),
    FoodItem(
      emoji: '🍖',
      name: 'Ribs',
      description: 'Tender ribs',
    ),
  ];

  /// Get a random subset of food items for a game
  static List<FoodItem> getRandomItems(int count) {
    final randomized = List<FoodItem>.from(items)..shuffle();
    return randomized.take(count).toList();
  }
}
