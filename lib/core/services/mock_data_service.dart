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

class MealPlanDay {
  const MealPlanDay({
    required this.day,
    required this.focusKey,
    required this.tipKey,
    required this.totalCalories,
    required this.items,
    this.isPrepDay = false,
  });

  final String day;
  final String focusKey;
  final String tipKey;
  final int totalCalories;
  final List<FoodItem> items;
  final bool isPrepDay;

  MealPlanDay copyWith({
    String? day,
    String? focusKey,
    String? tipKey,
    int? totalCalories,
    List<FoodItem>? items,
    bool? isPrepDay,
  }) {
    return MealPlanDay(
      day: day ?? this.day,
      focusKey: focusKey ?? this.focusKey,
      tipKey: tipKey ?? this.tipKey,
      totalCalories: totalCalories ?? this.totalCalories,
      items: items ?? this.items,
      isPrepDay: isPrepDay ?? this.isPrepDay,
    );
  }
}

class CommunityEvent {
  const CommunityEvent({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.imageUrl,
    required this.scheduleKey,
    required this.locationKey,
    required this.isVirtual,
    required this.isLive,
    required this.spotsRemaining,
    required this.hostKey,
    required this.highlightKeys,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String imageUrl;
  final String scheduleKey;
  final String locationKey;
  final bool isVirtual;
  final bool isLive;
  final int spotsRemaining;
  final String hostKey;
  final List<String> highlightKeys;
}

class ChefStory {
  const ChefStory({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.imageUrl,
    required this.tagKey,
    required this.durationMinutes,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String imageUrl;
  final String tagKey;
  final int durationMinutes;
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

class UserAddress {
  const UserAddress({
    required this.id,
    required this.label,
    required this.details,
    this.notes = '',
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String details;
  final String notes;
  final bool isDefault;

  UserAddress copyWith({String? id, String? label, String? details, String? notes, bool? isDefault}) {
    return UserAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      details: details ?? this.details,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiry,
    this.isPrimary = false,
  });

  final String id;
  final String brand;
  final String last4;
  final String expiry;
  final bool isPrimary;

  PaymentMethod copyWith({String? id, String? brand, String? last4, String? expiry, bool? isPrimary}) {
    return PaymentMethod(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expiry: expiry ?? this.expiry,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class LoyaltyReward {
  const LoyaltyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.iconUrl,
    this.isClaimed = false,
  });

  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String iconUrl;
  final bool isClaimed;

  LoyaltyReward copyWith({String? id, String? title, String? description, int? pointsRequired, String? iconUrl, bool? isClaimed}) {
    return LoyaltyReward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      iconUrl: iconUrl ?? this.iconUrl,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.handle,
    required this.avatarUrl,
    required this.spent,
    required this.tier,
    required this.loyaltyPoints,
    required this.nextTierPoints,
    required this.addresses,
    required this.paymentMethods,
    required this.rewards,
    required this.favoriteRestaurants,
  });

  final String name;
  final String email;
  final String handle;
  final String avatarUrl;
  final double spent;
  final String tier;
  final int loyaltyPoints;
  final int nextTierPoints;
  final List<UserAddress> addresses;
  final List<PaymentMethod> paymentMethods;
  final List<LoyaltyReward> rewards;
  final List<String> favoriteRestaurants;

  UserProfile copyWith({
    String? name,
    String? email,
    String? handle,
    String? avatarUrl,
    double? spent,
    String? tier,
    int? loyaltyPoints,
    int? nextTierPoints,
    List<UserAddress>? addresses,
    List<PaymentMethod>? paymentMethods,
    List<LoyaltyReward>? rewards,
    List<String>? favoriteRestaurants,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      handle: handle ?? this.handle,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      spent: spent ?? this.spent,
      tier: tier ?? this.tier,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      nextTierPoints: nextTierPoints ?? this.nextTierPoints,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      rewards: rewards ?? this.rewards,
      favoriteRestaurants: favoriteRestaurants ?? this.favoriteRestaurants,
    );
  }
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

  Future<List<CommunityEvent>> fetchCommunityEvents({int page = 0, int pageSize = 2}) async {
    await Future.delayed(const Duration(milliseconds: 450));
    final start = page * pageSize;
    if (start >= _communityEvents.length) {
      return [];
    }
    final end = min(start + pageSize, _communityEvents.length);
    return _communityEvents.sublist(start, end);
  }

  Future<List<ChefStory>> fetchChefStories() async {
    await Future.delayed(const Duration(milliseconds: 320));
    return _communityStories;
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

  UserProfile get userProfile => _profile;

  List<MealPlanDay> get mealPlanWeek => _mealPlanWeek;
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

final List<UserAddress> _profileAddresses = [
  const UserAddress(
    id: 'addr_1',
    label: 'Home',
    details: '123 Market Street, San Francisco, CA 94103',
    notes: 'Ring the bell twice',
    isDefault: true,
  ),
  const UserAddress(
    id: 'addr_2',
    label: 'Office',
    details: '88 Mission Blvd, 6th Floor',
    notes: 'Leave with reception',
  ),
  const UserAddress(
    id: 'addr_3',
    label: 'Gym',
    details: '455 Sunset Ave, Locker 21',
    notes: 'Deliver before 7pm',
  ),
];

final List<PaymentMethod> _profilePayments = [
  const PaymentMethod(id: 'pm_1', brand: 'Visa', last4: '4242', expiry: '08/26', isPrimary: true),
  const PaymentMethod(id: 'pm_2', brand: 'Apple Pay', last4: '0007', expiry: '—'),
  const PaymentMethod(id: 'pm_3', brand: 'Mastercard', last4: '9921', expiry: '04/25'),
];

final List<LoyaltyReward> _profileRewards = [
  const LoyaltyReward(
    id: 'reward_1',
    title: 'Free Delivery',
    description: 'Enjoy one free delivery on orders above $15.',
    pointsRequired: 200,
    iconUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=200&q=80',
  ),
  const LoyaltyReward(
    id: 'reward_2',
    title: 'Dessert Treat',
    description: 'Unlock a complimentary dessert from select partners.',
    pointsRequired: 420,
    iconUrl: 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?auto=format&fit=crop&w=200&q=80',
  ),
  const LoyaltyReward(
    id: 'reward_3',
    title: 'VIP Chef Call',
    description: 'Schedule a live session with our culinary concierge.',
    pointsRequired: 900,
    iconUrl: 'https://images.unsplash.com/photo-1528715471579-d1bcf0ba5e83?auto=format&fit=crop&w=200&q=80',
  ),
];

final UserProfile _profile = UserProfile(
  name: 'Lina Bright',
  email: 'lina@example.com',
  handle: '@linabright',
  avatarUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
  spent: 15000,
  tier: 'Rose Gold',
  loyaltyPoints: 680,
  nextTierPoints: 1200,
  addresses: _profileAddresses,
  paymentMethods: _profilePayments,
  rewards: _profileRewards,
  favoriteRestaurants: const ['Spicy Heaven', 'Blooming Bowls', 'Saffron Soul'],
);

const List<String> _mealPlanDayNames = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

const List<String> _mealPlanFocus = [
  'focus_protein',
  'focus_greens',
  'focus_chef',
  'focus_comfort',
  'focus_spice',
  'focus_weekend',
  'focus_brunch',
];

const List<String> _mealPlanTips = [
  'tip_hydrate',
  'tip_extra_greens',
  'tip_fruits',
  'tip_mindful',
  'tip_spice',
  'tip_invite',
  'tip_brunch',
];

final List<MealPlanDay> _mealPlanWeek = List.generate(_mealPlanDayNames.length, (index) {
  final start = (index * 3) % _baseFoodItems.length;
  final meals = _baseFoodItems.skip(start).take(3).toList();
  return MealPlanDay(
    day: _mealPlanDayNames[index],
    focusKey: _mealPlanFocus[index % _mealPlanFocus.length],
    tipKey: _mealPlanTips[index % _mealPlanTips.length],
    totalCalories: 1650 + index * 110,
    items: meals,
    isPrepDay: index == 0 || index == 3,
  );
});

final List<CommunityEvent> _communityEvents = [
  CommunityEvent(
    id: 'event_1',
    titleKey: 'community_event_title_1',
    descriptionKey: 'community_event_desc_1',
    imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?auto=format&fit=crop&w=900&q=80',
    scheduleKey: 'community_event_schedule_1',
    locationKey: 'community_event_location_virtual',
    isVirtual: true,
    isLive: true,
    spotsRemaining: 18,
    hostKey: 'community_host_laila',
    highlightKeys: const ['community_story_tag_masterclass', 'focus_spice'],
  ),
  CommunityEvent(
    id: 'event_2',
    titleKey: 'community_event_title_2',
    descriptionKey: 'community_event_desc_2',
    imageUrl: 'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?auto=format&fit=crop&w=900&q=80',
    scheduleKey: 'community_event_schedule_2',
    locationKey: 'community_event_location_hq',
    isVirtual: false,
    isLive: false,
    spotsRemaining: 9,
    hostKey: 'community_host_omar',
    highlightKeys: const ['focus_greens', 'community_story_tag_seasonal'],
  ),
  CommunityEvent(
    id: 'event_3',
    titleKey: 'community_event_title_3',
    descriptionKey: 'community_event_desc_3',
    imageUrl: 'https://images.unsplash.com/photo-1481931098730-318b6f776db0?auto=format&fit=crop&w=900&q=80',
    scheduleKey: 'community_event_schedule_3',
    locationKey: 'community_event_location_market',
    isVirtual: false,
    isLive: false,
    spotsRemaining: 24,
    hostKey: 'community_host_zoe',
    highlightKeys: const ['focus_brunch', 'community_story_tag_trend'],
  ),
];

final List<ChefStory> _communityStories = [
  ChefStory(
    id: 'story_1',
    titleKey: 'community_story_title_1',
    descriptionKey: 'community_story_desc_1',
    imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
    tagKey: 'community_story_tag_masterclass',
    durationMinutes: 6,
  ),
  ChefStory(
    id: 'story_2',
    titleKey: 'community_story_title_2',
    descriptionKey: 'community_story_desc_2',
    imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=900&q=80',
    tagKey: 'community_story_tag_trend',
    durationMinutes: 4,
  ),
  ChefStory(
    id: 'story_3',
    titleKey: 'community_story_title_3',
    descriptionKey: 'community_story_desc_3',
    imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80',
    tagKey: 'community_story_tag_seasonal',
    durationMinutes: 5,
  ),
];
