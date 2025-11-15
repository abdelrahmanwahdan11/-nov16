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

class GiftCard {
  const GiftCard({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.imageUrl,
    required this.valueAmount,
    required this.occasionKey,
    required this.deliveryKey,
    required this.bonusKey,
    required this.perkKeys,
  });

  final String id;
  final String titleKey;
  final String subtitleKey;
  final String imageUrl;
  final int valueAmount;
  final String occasionKey;
  final String deliveryKey;
  final String bonusKey;
  final List<String> perkKeys;
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.imageUrl,
    required this.pricePerWeek,
    required this.durationWeeks,
    required this.tagKey,
    required this.perkKeys,
    this.highlightKey,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String imageUrl;
  final double pricePerWeek;
  final int durationWeeks;
  final String tagKey;
  final List<String> perkKeys;
  final String? highlightKey;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.timeKey,
    required this.typeKey,
    this.imageUrl,
    this.isRead = false,
  });

  final String id;
  final String titleKey;
  final String bodyKey;
  final String timeKey;
  final String typeKey;
  final String? imageUrl;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      titleKey: titleKey,
      bodyKey: bodyKey,
      timeKey: timeKey,
      typeKey: typeKey,
      imageUrl: imageUrl,
      isRead: isRead ?? this.isRead,
    );
  }
}

class ReservationSlot {
  const ReservationSlot({
    required this.id,
    required this.restaurantId,
    required this.dateTime,
    required this.capacity,
  });

  final String id;
  final String restaurantId;
  final DateTime dateTime;
  final int capacity;
}

class Reservation {
  const Reservation({
    required this.id,
    required this.restaurantId,
    required this.dateTime,
    required this.guests,
    required this.occasionKey,
    required this.statusKey,
    this.note,
  });

  final String id;
  final String restaurantId;
  final DateTime dateTime;
  final int guests;
  final String occasionKey;
  final String statusKey;
  final String? note;

  Reservation copyWith({
    String? id,
    String? restaurantId,
    DateTime? dateTime,
    int? guests,
    String? occasionKey,
    String? statusKey,
    String? note,
  }) {
    return Reservation(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      dateTime: dateTime ?? this.dateTime,
      guests: guests ?? this.guests,
      occasionKey: occasionKey ?? this.occasionKey,
      statusKey: statusKey ?? this.statusKey,
      note: note ?? this.note,
    );
  }
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
  MockDataService() {
    _restaurants = List.generate(
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

    DateTime combine(DateTime base, int daysFromNow, int hour, int minute) {
      final shifted = base.add(Duration(days: daysFromNow));
      return DateTime(shifted.year, shifted.month, shifted.day, hour, minute);
    }

    final now = DateTime.now();
    _reservationSlots = [
      ReservationSlot(
        id: 'slot_1',
        restaurantId: _restaurants[0].id,
        dateTime: combine(now, 1, 18, 30),
        capacity: 2,
      ),
      ReservationSlot(
        id: 'slot_2',
        restaurantId: _restaurants[0].id,
        dateTime: combine(now, 1, 20, 0),
        capacity: 4,
      ),
      ReservationSlot(
        id: 'slot_3',
        restaurantId: _restaurants[1].id,
        dateTime: combine(now, 2, 19, 15),
        capacity: 2,
      ),
      ReservationSlot(
        id: 'slot_4',
        restaurantId: _restaurants[2].id,
        dateTime: combine(now, 3, 17, 45),
        capacity: 3,
      ),
      ReservationSlot(
        id: 'slot_5',
        restaurantId: _restaurants[2].id,
        dateTime: combine(now, 3, 20, 15),
        capacity: 4,
      ),
      ReservationSlot(
        id: 'slot_6',
        restaurantId: _restaurants[3].id,
        dateTime: combine(now, 4, 18, 0),
        capacity: 5,
      ),
    ];

    _reservations = [
      Reservation(
        id: 'reservation_1',
        restaurantId: _restaurants[0].id,
        dateTime: combine(now, 1, 19, 30),
        guests: 2,
        occasionKey: 'reservation_occasion_date',
        statusKey: 'reservation_status_confirmed',
        note: 'Window seating if available',
      ),
      Reservation(
        id: 'reservation_2',
        restaurantId: _restaurants[1].id,
        dateTime: combine(now, -2, 18, 0),
        guests: 4,
        occasionKey: 'reservation_occasion_celebration',
        statusKey: 'reservation_status_completed',
        note: 'Birthday dessert surprise',
      ),
      Reservation(
        id: 'reservation_3',
        restaurantId: _restaurants[3].id,
        dateTime: combine(now, 0, 13, 0),
        guests: 3,
        occasionKey: 'reservation_occasion_business',
        statusKey: 'reservation_status_confirmed',
      ),
    ];

    _giftCards = [
      GiftCard(
        id: 'gift_card_1',
        titleKey: 'gift_card_title_weekend',
        subtitleKey: 'gift_card_subtitle_weekend',
        imageUrl: 'https://images.unsplash.com/photo-1528715471579-d1bcf0ba5e83?auto=format&fit=crop&w=900&q=80',
        valueAmount: 50,
        occasionKey: 'gift_occasion_thankyou',
        deliveryKey: 'gift_delivery_instant',
        bonusKey: 'gift_bonus_loyalty',
        perkKeys: const ['gift_perk_free_delivery', 'gift_perk_bonus_points'],
      ),
      GiftCard(
        id: 'gift_card_2',
        titleKey: 'gift_card_title_brunch',
        subtitleKey: 'gift_card_subtitle_brunch',
        imageUrl: 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?auto=format&fit=crop&w=900&q=80',
        valueAmount: 75,
        occasionKey: 'gift_occasion_birthday',
        deliveryKey: 'gift_delivery_schedule',
        bonusKey: 'gift_bonus_handwritten',
        perkKeys: const ['gift_perk_personal_note', 'gift_perk_scheduled_send'],
      ),
      GiftCard(
        id: 'gift_card_3',
        titleKey: 'gift_card_title_date_night',
        subtitleKey: 'gift_card_subtitle_date_night',
        imageUrl: 'https://images.unsplash.com/photo-1481833761820-0509d3217039?auto=format&fit=crop&w=900&q=80',
        valueAmount: 100,
        occasionKey: 'gift_occasion_date',
        deliveryKey: 'gift_delivery_instant',
        bonusKey: 'gift_bonus_dual_course',
        perkKeys: const ['gift_perk_free_delivery', 'gift_perk_premium_support'],
      ),
      GiftCard(
        id: 'gift_card_4',
        titleKey: 'gift_card_title_team',
        subtitleKey: 'gift_card_subtitle_team',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&q=80',
        valueAmount: 150,
        occasionKey: 'gift_occasion_team',
        deliveryKey: 'gift_delivery_bulk',
        bonusKey: 'gift_bonus_group_discount',
        perkKeys: const ['gift_perk_bulk_upload', 'gift_perk_bonus_points'],
      ),
      GiftCard(
        id: 'gift_card_5',
        titleKey: 'gift_card_title_morning',
        subtitleKey: 'gift_card_subtitle_morning',
        imageUrl: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=900&q=80',
        valueAmount: 35,
        occasionKey: 'gift_occasion_congrats',
        deliveryKey: 'gift_delivery_instant',
        bonusKey: 'gift_bonus_breakfast',
        perkKeys: const ['gift_perk_personal_note'],
      ),
      GiftCard(
        id: 'gift_card_6',
        titleKey: 'gift_card_title_global',
        subtitleKey: 'gift_card_subtitle_global',
        imageUrl: 'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?auto=format&fit=crop&w=900&q=80',
        valueAmount: 60,
        occasionKey: 'gift_occasion_longdistance',
        deliveryKey: 'gift_delivery_schedule',
        bonusKey: 'gift_bonus_timezone',
        perkKeys: const ['gift_perk_scheduled_send', 'gift_perk_premium_support'],
      ),
    ];

    _subscriptions = _subscriptionPlans;
  }

  static const int popularPageSize = 6;
  static const int catalogPageSize = 8;
  static const int notificationsPageSize = 4;
  static const int giftCardPageSize = 3;
  static const int subscriptionPageSize = 4;

  late final List<Restaurant> _restaurants;
  late final List<ReservationSlot> _reservationSlots;
  late final List<Reservation> _reservations;
  late final List<GiftCard> _giftCards;
  late final List<SubscriptionPlan> _subscriptions;

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

  List<GiftCard> get giftCards => List.unmodifiable(_giftCards);

  List<SubscriptionPlan> get subscriptionPlans => List.unmodifiable(_subscriptions);

  List<String> get giftOccasionKeys => const [
        'gift_occasion_thankyou',
        'gift_occasion_birthday',
        'gift_occasion_date',
        'gift_occasion_team',
        'gift_occasion_congrats',
        'gift_occasion_longdistance',
      ];

  List<String> get giftPerkKeys => const [
        'gift_perk_free_delivery',
        'gift_perk_bonus_points',
        'gift_perk_personal_note',
        'gift_perk_scheduled_send',
        'gift_perk_premium_support',
        'gift_perk_bulk_upload',
      ];

  List<String> get subscriptionTagKeys => const [
        'subscription_tag_flex',
        'subscription_tag_wellness',
        'subscription_tag_family',
        'subscription_tag_corporate',
      ];

  List<String> get subscriptionPerkKeys => const [
        'subscriptions_perk_free_setup',
        'subscriptions_perk_weekly_consult',
        'subscriptions_perk_family_portions',
        'subscriptions_perk_priority_support',
        'subscriptions_perk_surprise',
      ];

  List<int> get subscriptionDurations => const [4, 8, 12];

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

  Future<List<AppNotification>> fetchNotifications({int page = 0, int pageSize = notificationsPageSize}) async {
    await Future.delayed(const Duration(milliseconds: 360));
    final start = page * pageSize;
    if (start >= _notifications.length) {
      return [];
    }
    final end = min(start + pageSize, _notifications.length);
    return _notifications.sublist(start, end);
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

  List<Restaurant> get restaurants => _restaurants;

  Restaurant getRestaurantById(String id) {
    return _restaurants.firstWhere((restaurant) => restaurant.id == id, orElse: () => _restaurants.first);
  }

  Future<List<Reservation>> loadReservations() async {
    await Future.delayed(const Duration(milliseconds: 320));
    return _reservations.map((reservation) => reservation).toList();
  }

  Future<List<ReservationSlot>> fetchReservationSlots(String restaurantId) async {
    await Future.delayed(const Duration(milliseconds: 260));
    final now = DateTime.now().subtract(const Duration(hours: 1));
    final slots = _reservationSlots
        .where((slot) => slot.restaurantId == restaurantId && slot.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return slots;
  }

  Future<Reservation> createReservation({
    required String restaurantId,
    required DateTime dateTime,
    required int guests,
    required String occasionKey,
    String? note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 280));
    final reservation = Reservation(
      id: 'reservation_${DateTime.now().millisecondsSinceEpoch}',
      restaurantId: restaurantId,
      dateTime: dateTime,
      guests: guests,
      occasionKey: occasionKey,
      statusKey: 'reservation_status_confirmed',
      note: note?.isEmpty == true ? null : note,
    );
    _reservations.insert(0, reservation);
    return reservation;
  }

  Future<Reservation?> updateReservationStatus(String id, String statusKey) async {
    final index = _reservations.indexWhere((element) => element.id == id);
    if (index == -1) {
      return null;
    }
    final updated = _reservations[index].copyWith(statusKey: statusKey);
    _reservations[index] = updated;
    await Future.delayed(const Duration(milliseconds: 220));
    return updated;
  }

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

final List<AppNotification> _notifications = [
  const AppNotification(
    id: 'notif_1',
    titleKey: 'notification_title_order_ready',
    bodyKey: 'notification_body_order_ready',
    timeKey: 'notification_time_5m',
    typeKey: 'notification_type_order',
    imageUrl:
        'https://images.unsplash.com/photo-1528712306091-ed0763094c98?auto=format&fit=crop&w=400&q=80',
  ),
  const AppNotification(
    id: 'notif_2',
    titleKey: 'notification_title_offer_weekend',
    bodyKey: 'notification_body_offer_weekend',
    timeKey: 'notification_time_1h',
    typeKey: 'notification_type_offer',
    imageUrl:
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
  ),
  const AppNotification(
    id: 'notif_3',
    titleKey: 'notification_title_event_live',
    bodyKey: 'notification_body_event_live',
    timeKey: 'notification_time_15m',
    typeKey: 'notification_type_event',
    imageUrl:
        'https://images.unsplash.com/photo-1522906456132-bac22adad34f?auto=format&fit=crop&w=400&q=80',
  ),
  const AppNotification(
    id: 'notif_4',
    titleKey: 'notification_title_meal_plan',
    bodyKey: 'notification_body_meal_plan',
    timeKey: 'notification_time_yesterday',
    typeKey: 'notification_type_tip',
    imageUrl:
        'https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=400&q=80',
  ),
  const AppNotification(
    id: 'notif_5',
    titleKey: 'notification_title_loyalty',
    bodyKey: 'notification_body_loyalty',
    timeKey: 'notification_time_just_now',
    typeKey: 'notification_type_offer',
    imageUrl:
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
  ),
];

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

final List<SubscriptionPlan> _subscriptionPlans = [
  const SubscriptionPlan(
    id: 'subscription_1',
    titleKey: 'subscription_plan_title_express',
    descriptionKey: 'subscription_plan_desc_express',
    imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
    pricePerWeek: 59,
    durationWeeks: 4,
    tagKey: 'subscription_tag_flex',
    perkKeys: [
      'subscriptions_perk_free_setup',
      'subscriptions_perk_weekly_consult',
      'subscriptions_perk_surprise',
    ],
    highlightKey: 'subscriptions_badge_new',
  ),
  const SubscriptionPlan(
    id: 'subscription_2',
    titleKey: 'subscription_plan_title_wellness',
    descriptionKey: 'subscription_plan_desc_wellness',
    imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80&sat=-20',
    pricePerWeek: 72,
    durationWeeks: 8,
    tagKey: 'subscription_tag_wellness',
    perkKeys: [
      'subscriptions_perk_weekly_consult',
      'subscriptions_perk_priority_support',
    ],
  ),
  const SubscriptionPlan(
    id: 'subscription_3',
    titleKey: 'subscription_plan_title_family',
    descriptionKey: 'subscription_plan_desc_family',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&q=80',
    pricePerWeek: 89,
    durationWeeks: 12,
    tagKey: 'subscription_tag_family',
    perkKeys: [
      'subscriptions_perk_family_portions',
      'subscriptions_perk_free_setup',
      'subscriptions_perk_surprise',
    ],
    highlightKey: 'subscriptions_badge_best_value',
  ),
  const SubscriptionPlan(
    id: 'subscription_4',
    titleKey: 'subscription_plan_title_corporate',
    descriptionKey: 'subscription_plan_desc_corporate',
    imageUrl: 'https://images.unsplash.com/photo-1525755662778-989d0524087e?auto=format&fit=crop&w=900&q=80',
    pricePerWeek: 105,
    durationWeeks: 8,
    tagKey: 'subscription_tag_corporate',
    perkKeys: [
      'subscriptions_perk_priority_support',
      'subscriptions_perk_free_setup',
    ],
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
