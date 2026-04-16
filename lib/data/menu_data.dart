import '../models/menu_item.dart';

class MenuData {
  static final List<MenuItem> appetizers = [
    MenuItem(
      id: 'app_1',
      name: 'French Fries Plain',
      description: 'Golden, crispy classic fries seasoned with sea salt.',
      price: 80,
      imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?q=80&w=800',
      category: 'Appetizers',
      isVeg: true,
      rating: 4.5,
      customizations: [
        CustomizationGroup(
          title: 'Dips & Sauces',
          multiSelect: true,
          options: [
            CustomizationOption(name: 'Cheese Sauce', extraPrice: 20),
            CustomizationOption(name: 'Spicy Mayo', extraPrice: 15),
            CustomizationOption(name: 'Garlic Aioli', extraPrice: 15),
          ],
        ),
        CustomizationGroup(
          title: 'Portion Size',
          isRequired: true,
          options: [
            CustomizationOption(name: 'Regular', extraPrice: 0),
            CustomizationOption(name: 'Large', extraPrice: 30),
          ],
        ),
      ],
    ),
    MenuItem(
      id: 'app_2',
      name: 'French Fries Peri Peri',
      description: 'Zesty fries tossed in our signature spicy peri-peri seasoning.',
      price: 90,
      imageUrl: 'https://images.unsplash.com/photo-1630384066242-17a17833f147?q=80&w=800',
      category: 'Appetizers',
      isVeg: true,
      tag: 'SPICY',
      rating: 4.7,
    ),
    MenuItem(
      id: 'app_3',
      name: 'Onion Rings',
      description: 'Classic battered onion rings, deep-fried to perfection.',
      price: 180,
      imageUrl: 'https://images.unsplash.com/photo-1639122612204-f1974f74449b?q=80&w=800',
      category: 'Appetizers',
      isVeg: true,
      rating: 4.6,
    ),
    MenuItem(
      id: 'app_4',
      name: 'Chicken Pop Corn',
      description: 'Bite-sized pieces of tender chicken, breaded and fried.',
      price: 210,
      imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=800',
      category: 'Appetizers',
      isVeg: false,
      tag: 'BESTSELLER',
      rating: 4.8,
    ),
    MenuItem(
      id: 'app_5',
      name: 'Potato Bytes',
      description: 'Tater tots style crispy potato bites, perfect for snacking.',
      price: 90,
      imageUrl: 'https://images.unsplash.com/photo-1623238913973-21e45cced554?q=80&w=800',
      category: 'Appetizers',
      isVeg: true,
      rating: 4.4,
    ),
    MenuItem(
      id: 'app_6',
      name: 'Chicken Nuggets',
      description: 'Irresistibly juicy chicken nuggets with a crispy coating.',
      price: 200,
      imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?q=80&w=800',
      category: 'Appetizers',
      isVeg: false,
      rating: 4.7,
    ),
  ];

  static final List<MenuItem> chineseStarters = [
    MenuItem(
      id: 'cs_1',
      name: 'Dragon Chicken',
      description: 'Sizzling chicken strips tossed in a spicy, tangy red sauce.',
      price: 280,
      imageUrl: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?q=80&w=800',
      category: 'Chinese Starters',
      isVeg: false,
      tag: 'CHEF\'S PICK',
      rating: 4.9,
      customizations: [
        CustomizationGroup(
          title: 'Spice Level',
          isRequired: true,
          options: [
            CustomizationOption(name: 'Mild', extraPrice: 0),
            CustomizationOption(name: 'Medium', extraPrice: 0),
            CustomizationOption(name: 'Spicy', extraPrice: 0),
          ],
        ),
        CustomizationGroup(
          title: 'Add-ons',
          multiSelect: true,
          options: [
            CustomizationOption(name: 'Extra Cashews', extraPrice: 30),
            CustomizationOption(name: 'Extra Spring Onions', extraPrice: 10),
          ],
        ),
      ],
    ),
    MenuItem(
      id: 'cs_2',
      name: 'Chicken 65',
      description: 'Classic spicy, deep-fried chicken starter from South India.',
      price: 250,
      imageUrl: 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?q=80&w=800',
      category: 'Chinese Starters',
      isVeg: false,
      rating: 4.8,
    ),
    MenuItem(
      id: 'cs_3',
      name: 'Lemon Chicken',
      description: 'Crispy chicken pieces with a refreshing lemon-garlic glaze.',
      price: 250,
      imageUrl: 'https://images.unsplash.com/photo-1603496987351-f84a3ba5ec85?q=80&w=800',
      category: 'Chinese Starters',
      isVeg: false,
      rating: 4.7,
    ),
    MenuItem(
      id: 'cs_4',
      name: 'Butter Garlic Prawns',
      description: 'Succulent prawns sautéed in a rich butter and garlic sauce.',
      price: 299,
      imageUrl: 'https://images.unsplash.com/photo-1559742811-822873691df8?q=80&w=800',
      category: 'Chinese Starters',
      isVeg: false,
      tag: 'PREMIUM',
      rating: 4.9,
    ),
    MenuItem(
      id: 'cs_5',
      name: 'Veg Manchurian',
      description: 'Vegetable dumplings in a savory, soy-based gravy.',
      price: 100,
      imageUrl: 'https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?q=80&w=800',
      category: 'Chinese Starters',
      isVeg: true,
      rating: 4.6,
    ),
    MenuItem(
      id: 'cs_6',
      name: 'Chilli Paneer',
      description: 'Cubed cottage cheese tossed with bell peppers and chillies.',
      price: 210,
      imageUrl: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?q=80&w=800',
      category: 'Chinese Starters',
      isVeg: true,
      rating: 4.8,
    ),
    // ... more Chinese Starters can be added
  ];

  static final List<MenuItem> momos = [
    MenuItem(
      id: 'mo_1',
      name: 'Chicken Steamed Momos',
      description: 'Traditional Himalayan dumplings filled with seasoned chicken.',
      price: 110,
      imageUrl: 'https://images.unsplash.com/photo-1625220194771-7ebdea0b70b9?q=80&w=800',
      category: 'Momos',
      isVeg: false,
      rating: 4.7,
      customizations: [
        CustomizationGroup(
          title: 'Dips',
          multiSelect: true,
          options: [
            CustomizationOption(name: 'Extra Spicy Chutney', extraPrice: 10),
            CustomizationOption(name: 'Mayo', extraPrice: 10),
          ],
        ),
      ],
    ),
    MenuItem(
      id: 'mo_2',
      name: 'Veg Steamed Momos',
      description: 'Delicate dumplings filled with finely chopped vegetables.',
      price: 80,
      imageUrl: 'https://images.unsplash.com/photo-1534422298391-e4f8c170db76?q=80&w=800',
      category: 'Momos',
      isVeg: true,
      rating: 4.6,
    ),
    MenuItem(
      id: 'mo_3',
      name: 'Chicken Kurkure Momos',
      description: 'Crunchy, deep-fried momos with a flavorful chicken center.',
      price: 180,
      imageUrl: 'https://images.unsplash.com/photo-1625220194771-7ebdea0b70b9?q=80&w=800',
      category: 'Momos',
      isVeg: false,
      tag: 'CRUNCHY',
      rating: 4.9,
    ),
  ];

  static final List<MenuItem> burgers = [
    MenuItem(
      id: 'bg_1',
      name: 'Veg Crispy Burger',
      description: 'Crispy veggie patty with lettuce, tomato, and special sauce.',
      price: 70,
      imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=800',
      category: 'Burgers',
      isVeg: true,
      rating: 4.5,
      customizations: [
        CustomizationGroup(
          title: 'Add-ons',
          multiSelect: true,
          options: [
            CustomizationOption(name: 'Cheese Slice', extraPrice: 20),
            CustomizationOption(name: 'Extra Mayo', extraPrice: 10),
            CustomizationOption(name: 'Double Patty', extraPrice: 40),
          ],
        ),
      ],
    ),
    MenuItem(
      id: 'bg_2',
      name: 'Chicken Double Dekker',
      description: 'Double stacked chicken patties with layers of cheese and mayo.',
      price: 199,
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=800',
      category: 'Burgers',
      isVeg: false,
      tag: 'GIANT',
      rating: 4.9,
    ),
  ];

  static final List<MenuItem> noodles = [
    MenuItem(
      id: 'nd_1',
      name: 'Veg Hakka Noodles',
      description: 'Stir-fried noodles with crisp seasonal vegetables.',
      price: 80,
      imageUrl: 'https://images.unsplash.com/photo-1585032226651-759b368d7246?q=80&w=800',
      category: 'Noodles',
      isVeg: true,
      rating: 4.6,
    ),
    MenuItem(
      id: 'nd_2',
      name: 'Chicken Schezwan Noodles',
      description: 'Spicy noodles with shredded chicken in Schezwan sauce.',
      price: 90,
      imageUrl: 'https://images.unsplash.com/photo-1526318896980-cf78c088247c?q=80&w=800',
      category: 'Noodles',
      isVeg: false,
      tag: 'EXTREME SPICY',
      rating: 4.8,
    ),
  ];

  static final List<MenuItem> rice = [
    MenuItem(
      id: 'ri_1',
      name: 'Chicken Fried Rice',
      description: 'Wok-tossed rice with seasoned chicken and fresh veggies.',
      price: 99,
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?q=80&w=800',
      category: 'Rice',
      isVeg: false,
      rating: 4.7,
    ),
    MenuItem(
      id: 'ri_2',
      name: 'Veg Paneer Fried Rice',
      description: 'Fragrant fried rice topped with golden paneer cubes.',
      price: 110,
      imageUrl: 'https://images.unsplash.com/photo-1512058560366-cd2429df1017?q=80&w=800',
      category: 'Rice',
      isVeg: true,
      rating: 4.8,
    ),
  ];

  static List<MenuItem> getAllItems() {
    return [
      ...appetizers,
      ...chineseStarters,
      ...momos,
      ...burgers,
      ...noodles,
      ...rice,
    ];
  }
}
