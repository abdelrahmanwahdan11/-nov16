import 'dart:math';

class Category {
  const Category({required this.id, required this.name, required this.iconUrl});

  final String id;
  final String name;
  final String iconUrl;
}

class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.deliveryTime,
    required this.category,
    this.calories = 420,
    this.ingredients = const ['Cheese', 'Tomato', 'Olives'],
  });

  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final double rating;
  final int reviews;
  final int deliveryTime;
  final String category;
  final int calories;
  final List<String> ingredients;
}

class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.category,
    required this.deliveryFee,
    required this.deliveryTime,
    required this.menu,
  });

  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String category;
  final double deliveryFee;
  final int deliveryTime;
  final List<FoodItem> menu;
}

class Order {
  const Order({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
    required this.items,
  });

  final String id;
  final DateTime date;
  final double total;
  final String status;
  final List<FoodItem> items;
}

class MockDataService {
  static const int popularPageSize = 6;
  static const int catalogPageSize = 8;

  final List<Category> mockCategories = [
    const Category(
      id: 'fast_food',
      name: 'Fast Food',
      iconUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349',
    ),
    const Category(
      id: 'rice',
      name: 'Rice',
      iconUrl: 'https://images.unsplash.com/photo-1504753793650-d4a2b783c15e',
    ),
    const Category(
      id: 'seafood',
      name: 'Sea Food',
      iconUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
    ),
    const Category(
      id: 'crispy',
      name: 'Crispy',
      iconUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe',
    ),
    const Category(
      id: 'dessert',
      name: 'Dessert',
      iconUrl: 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e',
    ),
  ];

  List<FoodItem> get mockOffers => _foodItems.take(5).toList();

  List<FoodItem> paginatePopular(int page) {
    final start = page * popularPageSize;
    return _foodItems.skip(start).take(popularPageSize).toList();
  }

  List<FoodItem> paginateCatalog(int page) {
    final start = page * catalogPageSize;
    return _foodItems.skip(start).take(catalogPageSize).toList();
  }

  List<FoodItem> searchFood(String query) {
    final lower = query.toLowerCase();
    return _foodItems
        .where((element) =>
            element.name.toLowerCase().contains(lower) ||
            element.description.toLowerCase().contains(lower) ||
            element.category.toLowerCase().contains(lower))
        .toList();
  }

  List<FoodItem> itemsByIds(Iterable<String> ids) {
    final lookup = ids.toSet();
    final list = _foodItems.where((item) => lookup.contains(item.id)).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  List<FoodItem> get allFoodItems => _foodItems;

  List<Order> get mockOrders => List.generate(
        6,
        (index) => Order(
          id: '#80$index',
          date: DateTime.now().subtract(Duration(days: index * 3)),
          total: 19.5 + index * 5,
          status: index < 2 ? 'Cooking' : (index == 3 ? 'Pickup' : 'Delivered'),
          items: _foodItems.take(Random().nextInt(3) + 1).toList(),
        ),
      );

  List<Restaurant> get restaurants => List.generate(
        10,
        (index) => Restaurant(
          id: 'rest_$index',
          name: 'Spicy Heaven ${index + 1}',
          imageUrl: 'https://images.unsplash.com/photo-1555992336-cbf3cd4f1b89',
          rating: 4.2 + (index % 3) * 0.3,
          category: mockCategories[index % mockCategories.length].name,
          deliveryFee: 2.99 + index,
          deliveryTime: 20 + index * 3,
          menu: _foodItems.sublist(0, 6),
        ),
      );

  List<FoodItem> get _foodItems => _baseFoodItems;
}

final List<FoodItem> _baseFoodItems = List.generate(
  30,
  (index) => FoodItem(
    id: 'food_$index',
    name: 'Fusion Delight ${index + 1}',
    description: 'A mouth-watering mix of spices and textures for any craving.',
    imageUrl: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?auto=format&fit=crop&w=800&q=80',
    price: 8.5 + index,
    rating: 4.1 + (index % 4) * 0.2,
    reviews: 120 + index * 5,
    deliveryTime: 20 + index % 10,
    category: index % 2 == 0 ? 'Fast Food' : 'Sea Food',
    calories: 350 + index * 10,
    ingredients: const ['Cheese', 'Tomato', 'Basil', 'Herbs'],
  ),
);
