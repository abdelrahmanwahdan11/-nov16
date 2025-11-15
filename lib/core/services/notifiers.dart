import 'dart:async';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';
import 'shared_prefs_service.dart';
import 'mock_data_service.dart';

class AppState extends ChangeNotifier {
  AppState() {
    final mock = MockDataService();
    mockDataService = mock;
    themeNotifier = ThemeNotifier();
    localeNotifier = LocaleNotifier();
    homeFeedNotifier = HomeFeedNotifier(mock);
    catalogNotifier = CatalogNotifier(mock);
    searchNotifier = SearchNotifier(mock);
    cartNotifier = CartNotifier();
    comparisonNotifier = ComparisonNotifier();
    favoritesNotifier = FavoritesNotifier();
    ordersNotifier = OrdersNotifier(mock);
    profileNotifier = ProfileNotifier(mock);
    mealPlannerNotifier = MealPlannerNotifier(mock);
    communityNotifier = CommunityNotifier(mock);
    notificationsNotifier = NotificationsNotifier(mock);
    reservationsNotifier = ReservationsNotifier(mock);
    giftCardsNotifier = GiftCardsNotifier(mock);
    subscriptionsNotifier = SubscriptionsNotifier(mock);
  }

  late final MockDataService mockDataService;
  late final ThemeNotifier themeNotifier;
  late final LocaleNotifier localeNotifier;
  late final HomeFeedNotifier homeFeedNotifier;
  late final CatalogNotifier catalogNotifier;
  late final SearchNotifier searchNotifier;
  late final CartNotifier cartNotifier;
  late final ComparisonNotifier comparisonNotifier;
  late final FavoritesNotifier favoritesNotifier;
  late final OrdersNotifier ordersNotifier;
  late final ProfileNotifier profileNotifier;
  late final MealPlannerNotifier mealPlannerNotifier;
  late final CommunityNotifier communityNotifier;
  late final NotificationsNotifier notificationsNotifier;
  late final ReservationsNotifier reservationsNotifier;
  late final GiftCardsNotifier giftCardsNotifier;
  late final SubscriptionsNotifier subscriptionsNotifier;

  final SharedPrefsService prefs = SharedPrefsService();

  Future<void> bootstrap() async {
    await prefs.init();
    themeNotifier.applyPrefs(prefs);
    localeNotifier.applyPrefs(prefs);
    unawaited(homeFeedNotifier.loadInitial());
    unawaited(catalogNotifier.loadInitial());
    unawaited(ordersNotifier.loadInitial());
    unawaited(profileNotifier.loadProfile());
    unawaited(mealPlannerNotifier.loadPlan());
    unawaited(communityNotifier.loadInitial());
    unawaited(notificationsNotifier.loadInitial());
    unawaited(reservationsNotifier.loadInitial());
    unawaited(giftCardsNotifier.loadInitial());
    unawaited(subscriptionsNotifier.loadInitial());
  }

  @override
  void dispose() {
    themeNotifier.dispose();
    localeNotifier.dispose();
    homeFeedNotifier.dispose();
    catalogNotifier.dispose();
    searchNotifier.dispose();
    cartNotifier.dispose();
    comparisonNotifier.dispose();
    favoritesNotifier.dispose();
    ordersNotifier.dispose();
    profileNotifier.dispose();
    mealPlannerNotifier.dispose();
    communityNotifier.dispose();
    notificationsNotifier.dispose();
    reservationsNotifier.dispose();
    giftCardsNotifier.dispose();
    subscriptionsNotifier.dispose();
    super.dispose();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({super.key, required AppState state, required Widget child})
      : super(notifier: state, child: child);

  static AppState of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<AppStateScope>()
        : context.getInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = AppTheme.defaultPrimary;
  final ValueNotifier<Color> primaryColorNotifier = ValueNotifier(AppTheme.defaultPrimary);

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Color get primaryColor => _primaryColor;

  void toggleDarkMode(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void updatePrimary(Color color) {
    _primaryColor = color;
    primaryColorNotifier.value = color;
    notifyListeners();
  }

  Future<void> persist(SharedPrefsService prefs) async {
    await prefs.saveThemeMode(_themeMode);
    await prefs.savePrimaryColor(_primaryColor);
  }

  void applyPrefs(SharedPrefsService prefs) {
    _themeMode = prefs.themeMode ?? ThemeMode.light;
    _primaryColor = prefs.primaryColor ?? AppTheme.defaultPrimary;
    primaryColorNotifier.value = _primaryColor;
    notifyListeners();
  }
}

class LocaleNotifier extends ChangeNotifier {
  Locale _locale = AppLocalizations.supportedLocales.first;

  Locale get locale => _locale;

  void switchLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  Future<void> persist(SharedPrefsService prefs) async {
    await prefs.saveLocale(_locale);
  }

  void applyPrefs(SharedPrefsService prefs) {
    _locale = prefs.locale ?? AppLocalizations.supportedLocales.first;
    notifyListeners();
  }
}

class HomeFeedNotifier extends ChangeNotifier {
  HomeFeedNotifier(this._dataService);

  final MockDataService _dataService;
  final ValueNotifier<List<FoodItem>> offers = ValueNotifier([]);
  final ValueNotifier<List<Category>> categories = ValueNotifier([]);
  final ValueNotifier<List<FoodItem>> popular = ValueNotifier([]);
  final ValueNotifier<bool> loadingMore = ValueNotifier(false);
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;

  bool get isLoading => _loading;
  bool get hasMore => _hasMore;

  Future<void> loadInitial() async {
    if (_loading) return;
    _loading = true;
    _hasMore = true;
    _page = 0;
    offers.value = [];
    categories.value = [];
    popular.value = [];
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    offers.value = _dataService.mockOffers;
    categories.value = _dataService.mockCategories;
    final batch = _dataService.paginatePopular(_page);
    popular.value = batch;
    _hasMore = batch.length == MockDataService.popularPageSize;
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_loading || loadingMore.value || !_hasMore) return;
    loadingMore.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    _page += 1;
    final batch = _dataService.paginatePopular(_page);
    if (batch.isEmpty) {
      _hasMore = false;
    } else {
      popular.value = [...popular.value, ...batch];
      if (batch.length < MockDataService.popularPageSize) {
        _hasMore = false;
      }
    }
    loadingMore.value = false;
    notifyListeners();
  }

  @override
  void dispose() {
    offers.dispose();
    categories.dispose();
    popular.dispose();
    loadingMore.dispose();
    super.dispose();
  }
}

class CatalogNotifier extends ChangeNotifier {
  CatalogNotifier(this._dataService);

  final MockDataService _dataService;
  final ValueNotifier<List<FoodItem>> items = ValueNotifier([]);
  final ValueNotifier<Set<String>> activeFilters = ValueNotifier({});
  final ValueNotifier<String?> sortOption = ValueNotifier(null);
  bool _loading = false;
  bool _hasMore = true;
  final ValueNotifier<bool> loadingMore = ValueNotifier(false);

  bool get hasMore => _hasMore;
  bool get isLoading => _loading;

  Future<void> loadInitial() async {
    if (_loading) return;
    _loading = true;
    _hasMore = true;
    items.value = [];
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final source = _filteredSource();
    items.value = source.take(MockDataService.catalogPageSize).toList();
    _hasMore = source.length > items.value.length;
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _hasMore = true;
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_loading || loadingMore.value || !_hasMore) return;
    loadingMore.value = true;
    await Future.delayed(const Duration(milliseconds: 450));
    final source = _filteredSource();
    final start = items.value.length;
    final more = source.skip(start).take(MockDataService.catalogPageSize).toList();
    if (more.isEmpty) {
      _hasMore = false;
    } else {
      items.value = [...items.value, ...more];
      _hasMore = source.length > items.value.length;
    }
    loadingMore.value = false;
    notifyListeners();
  }

  void toggleFilter(String filter) {
    final filters = Set<String>.from(activeFilters.value);
    if (!filters.add(filter)) {
      filters.remove(filter);
    }
    activeFilters.value = filters;
    _hasMore = true;
    _recomputeFromSource();
  }

  void updateSort(String option) {
    sortOption.value = option == 'best_match' ? null : option;
    _hasMore = true;
    _recomputeFromSource();
  }

  List<FoodItem> _filteredSource() {
    Iterable<FoodItem> list = _dataService.allFoodItems;
    if (activeFilters.value.isNotEmpty) {
      list = list.where((item) => activeFilters.value.contains(item.category));
    }
    final option = sortOption.value;
    final result = List<FoodItem>.from(list);
    switch (option) {
      case 'lowest_price':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'highest_rating':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'fastest_delivery':
        result.sort((a, b) => a.deliveryTime.compareTo(b.deliveryTime));
        break;
      default:
        break;
    }
    return result;
  }

  void _recomputeFromSource() {
    final source = _filteredSource();
    items.value = source.take(MockDataService.catalogPageSize).toList();
    _hasMore = source.length > items.value.length;
    notifyListeners();
  }

  @override
  void dispose() {
    items.dispose();
    activeFilters.dispose();
    sortOption.dispose();
    loadingMore.dispose();
    super.dispose();
  }
}

class SearchNotifier extends ChangeNotifier {
  SearchNotifier(this._dataService);

  final MockDataService _dataService;
  final ValueNotifier<List<String>> history = ValueNotifier([]);
  final ValueNotifier<List<FoodItem>> results = ValueNotifier([]);
  final TextEditingController controller = TextEditingController();
  bool _isSearching = false;
  Timer? _debounce;

  bool get isSearching => _isSearching;

  void search(String query) {
    final trimmed = query.trim();
    _debounce?.cancel();
    if (trimmed.isEmpty) {
      _isSearching = false;
      results.value = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!history.value.contains(trimmed)) {
        history.value = [trimmed, ...history.value.take(4)];
      }
      results.value = _dataService.searchFood(trimmed);
      _isSearching = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    history.dispose();
    results.dispose();
    controller.dispose();
    super.dispose();
  }
}

class CartNotifier extends ChangeNotifier {
  final ValueNotifier<List<CartItem>> items = ValueNotifier([]);

  void add(FoodItem item) {
    final list = List<CartItem>.from(items.value);
    final index = list.indexWhere((element) => element.item.id == item.id);
    if (index == -1) {
      list.add(CartItem(item: item, quantity: 1));
    } else {
      list[index] = list[index].copyWith(quantity: list[index].quantity + 1);
    }
    items.value = list;
    notifyListeners();
  }

  void remove(FoodItem item) {
    final list = List<CartItem>.from(items.value);
    list.removeWhere((element) => element.item.id == item.id);
    items.value = list;
    notifyListeners();
  }

  void updateQuantity(FoodItem item, int delta) {
    final list = List<CartItem>.from(items.value);
    final index = list.indexWhere((element) => element.item.id == item.id);
    if (index == -1) return;
    final current = list[index];
    final newQuantity = (current.quantity + delta).clamp(1, 99);
    list[index] = current.copyWith(quantity: newQuantity);
    items.value = list;
    notifyListeners();
  }

  double get total =>
      items.value.fold(0, (previousValue, element) => previousValue + element.item.price * element.quantity);

  void clear() {
    items.value = [];
    notifyListeners();
  }

  @override
  void dispose() {
    items.dispose();
    super.dispose();
  }
}

class ComparisonNotifier extends ChangeNotifier {
  final ValueNotifier<List<FoodItem>> selected = ValueNotifier([]);

  void toggle(FoodItem item) {
    final list = List<FoodItem>.from(selected.value);
    if (list.any((element) => element.id == item.id)) {
      list.removeWhere((element) => element.id == item.id);
    } else {
      if (list.length >= 3) {
        list.removeAt(0);
      }
      list.add(item);
    }
    selected.value = list;
    notifyListeners();
  }

  void clear() {
    selected.value = [];
    notifyListeners();
  }

  @override
  void dispose() {
    selected.dispose();
    super.dispose();
  }
}

class FavoritesNotifier extends ChangeNotifier {
  final ValueNotifier<Set<String>> _favorites = ValueNotifier({});

  ValueNotifier<Set<String>> get favorites => _favorites;

  void toggle(FoodItem item) {
    final set = Set<String>.from(_favorites.value);
    if (!set.add(item.id)) {
      set.remove(item.id);
    }
    _favorites.value = set;
    notifyListeners();
  }

  bool isFavorite(String id) => _favorites.value.contains(id);

  @override
  void dispose() {
    _favorites.dispose();
    super.dispose();
  }
}

class OrdersNotifier extends ChangeNotifier {
  OrdersNotifier(this._dataService);

  final MockDataService _dataService;
  final ValueNotifier<List<Order>> currentOrders = ValueNotifier([]);
  final ValueNotifier<List<Order>> historyOrders = ValueNotifier([]);
  bool _loading = false;

  bool get isLoading => _loading;

  Future<void> loadInitial() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    final orders = _dataService.mockOrders;
    currentOrders.value = orders.where((order) => order.status != 'Delivered').toList();
    historyOrders.value = orders.where((order) => order.status == 'Delivered').toList();
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  @override
  void dispose() {
    currentOrders.dispose();
    historyOrders.dispose();
    super.dispose();
  }
}

class MealPlannerNotifier extends ChangeNotifier {
  MealPlannerNotifier(this._dataService);

  final MockDataService _dataService;

  final ValueNotifier<List<MealPlanDay>> days = ValueNotifier([]);
  final ValueNotifier<int> activeDayIndex = ValueNotifier(0);
  final ValueNotifier<Set<String>> preparedMeals = ValueNotifier(<String>{});
  final ValueNotifier<bool> autoPilot = ValueNotifier(false);

  bool _loading = false;
  bool _initialized = false;

  bool get isLoading => _loading;

  Future<void> loadPlan({bool force = false}) async {
    if (_loading) return;
    if (_initialized && !force) return;
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 360));
    final plan = _dataService.mealPlanWeek.map((day) => day.copyWith(items: List<FoodItem>.from(day.items))).toList();
    days.value = plan;
    activeDayIndex.value = 0;
    preparedMeals.value = <String>{};
    _initialized = true;
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadPlan(force: true);

  void goToDay(int index) {
    if (days.value.isEmpty) return;
    final clamped = index.clamp(0, days.value.length - 1);
    activeDayIndex.value = clamped;
    notifyListeners();
  }

  void togglePrepared(String foodId) {
    final updated = Set<String>.from(preparedMeals.value);
    if (!updated.add(foodId)) {
      updated.remove(foodId);
    }
    preparedMeals.value = updated;
    notifyListeners();
  }

  void toggleAutoPilot(bool value) {
    autoPilot.value = value;
    notifyListeners();
  }

  void rotatePlan() {
    final plan = List<MealPlanDay>.from(days.value);
    if (plan.length <= 1) return;
    final first = plan.removeAt(0);
    plan.add(first);
    days.value = plan;
    activeDayIndex.value = 0;
    preparedMeals.value = <String>{};
    notifyListeners();
  }
}

class NotificationsNotifier extends ChangeNotifier {
  NotificationsNotifier(this._dataService);

  final MockDataService _dataService;

  final ValueNotifier<List<AppNotification>> notifications = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> loadingMore = ValueNotifier(false);
  final ValueNotifier<int> unreadCount = ValueNotifier(0);

  bool _initialized = false;
  bool _hasMore = true;
  int _page = 0;
  final Set<String> _readIds = <String>{};

  bool get initialized => _initialized;
  bool get hasMore => _hasMore;

  Future<void> loadInitial({bool force = false}) async {
    if (isLoading.value) return;
    if (_initialized && !force) return;
    isLoading.value = true;
    _hasMore = true;
    _page = 0;
    notifications.value = [];
    notifyListeners();
    final fetched = await _dataService.fetchNotifications(page: 0);
    final mapped = _mapReadState(fetched);
    notifications.value = mapped;
    _hasMore = fetched.length == MockDataService.notificationsPageSize;
    _page = _hasMore ? 1 : 0;
    isLoading.value = false;
    _initialized = true;
    _updateUnread();
    notifyListeners();
  }

  Future<void> refresh() => loadInitial(force: true);

  Future<void> loadMore() async {
    if (!_hasMore || loadingMore.value) return;
    loadingMore.value = true;
    notifyListeners();
    final fetched = await _dataService.fetchNotifications(page: _page);
    if (fetched.isEmpty) {
      _hasMore = false;
    } else {
      final mapped = _mapReadState(fetched);
      notifications.value = [...notifications.value, ...mapped];
      _page += 1;
      if (fetched.length < MockDataService.notificationsPageSize) {
        _hasMore = false;
      }
    }
    loadingMore.value = false;
    _updateUnread();
    notifyListeners();
  }

  void markAsRead(String id) {
    if (_readIds.contains(id)) return;
    _readIds.add(id);
    notifications.value = notifications.value
        .map((notification) => notification.id == id ? notification.copyWith(isRead: true) : notification)
        .toList();
    _updateUnread();
    notifyListeners();
  }

  void markAllAsRead() {
    if (notifications.value.isEmpty) return;
    _readIds.addAll(notifications.value.map((e) => e.id));
    notifications.value = notifications.value.map((e) => e.copyWith(isRead: true)).toList();
    _updateUnread();
    notifyListeners();
  }

  List<AppNotification> _mapReadState(List<AppNotification> items) {
    return items
        .map((item) => _readIds.contains(item.id) ? item.copyWith(isRead: true) : item)
        .toList();
  }

  void _updateUnread() {
    final count = notifications.value.where((element) => !element.isRead).length;
    unreadCount.value = count;
  }

  @override
  void dispose() {
    notifications.dispose();
    isLoading.dispose();
    loadingMore.dispose();
    unreadCount.dispose();
    super.dispose();
  }
}

class ReservationsNotifier extends ChangeNotifier {
  ReservationsNotifier(this._dataService);

  final MockDataService _dataService;
  final ValueNotifier<List<Reservation>> upcoming = ValueNotifier([]);
  final ValueNotifier<List<Reservation>> history = ValueNotifier([]);
  final ValueNotifier<List<ReservationSlot>> availableSlots = ValueNotifier([]);
  final ValueNotifier<bool> isLoadingSlots = ValueNotifier(false);
  final ValueNotifier<bool> isBooking = ValueNotifier(false);
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> loadInitial() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    final reservations = await _dataService.loadReservations();
    _assign(reservations);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    final reservations = await _dataService.loadReservations();
    _assign(reservations);
  }

  Future<void> loadSlotsForRestaurant(String restaurantId) async {
    isLoadingSlots.value = true;
    availableSlots.value = [];
    final slots = await _dataService.fetchReservationSlots(restaurantId);
    availableSlots.value = slots;
    isLoadingSlots.value = false;
  }

  void clearSlots() {
    availableSlots.value = [];
    isLoadingSlots.value = false;
  }

  Future<Reservation?> bookReservation({
    required String restaurantId,
    required DateTime dateTime,
    required int guests,
    required String occasionKey,
    String? note,
  }) async {
    if (isBooking.value) return null;
    isBooking.value = true;
    try {
      final reservation = await _dataService.createReservation(
        restaurantId: restaurantId,
        dateTime: dateTime,
        guests: guests,
        occasionKey: occasionKey,
        note: note,
      );
      final reservations = await _dataService.loadReservations();
      _assign(reservations);
      return reservation;
    } finally {
      isBooking.value = false;
    }
  }

  Future<bool> updateStatus(String id, String statusKey) async {
    final updated = await _dataService.updateReservationStatus(id, statusKey);
    if (updated == null) {
      return false;
    }
    final reservations = await _dataService.loadReservations();
    _assign(reservations);
    return true;
  }

  Restaurant restaurantFor(String id) {
    return _dataService.getRestaurantById(id);
  }

  void _assign(List<Reservation> reservations) {
    final now = DateTime.now().subtract(const Duration(hours: 2));
    final upcomingReservations = reservations
        .where((reservation) => reservation.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final historyReservations = reservations
        .where((reservation) => reservation.dateTime.isBefore(now))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    upcoming.value = upcomingReservations;
    history.value = historyReservations;
  }

  @override
  void dispose() {
    upcoming.dispose();
    history.dispose();
    availableSlots.dispose();
    isLoadingSlots.dispose();
    isBooking.dispose();
    super.dispose();
  }
}

class CommunityNotifier extends ChangeNotifier {
  CommunityNotifier(this._dataService);

  final MockDataService _dataService;

  static const int _pageSize = 2;

  final ValueNotifier<List<CommunityEvent>> events = ValueNotifier([]);
  final ValueNotifier<List<ChefStory>> stories = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> loadingMore = ValueNotifier(false);

  bool _hasMore = true;
  bool _initialized = false;
  int _page = 0;

  bool get hasMore => _hasMore;

  Future<void> loadInitial({bool force = false}) async {
    if (isLoading.value) return;
    if (_initialized && !force) return;
    isLoading.value = true;
    _hasMore = true;
    _page = 0;
    events.value = [];
    notifyListeners();
    final fetched = await _dataService.fetchCommunityEvents(page: 0, pageSize: _pageSize);
    events.value = fetched;
    _hasMore = fetched.length == _pageSize;
    _page = _hasMore ? 1 : 0;
    if (stories.value.isEmpty || force) {
      final loadedStories = await _dataService.fetchChefStories();
      stories.value = loadedStories;
    }
    isLoading.value = false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> refresh() => loadInitial(force: true);

  Future<void> loadMore() async {
    if (!_hasMore || loadingMore.value) return;
    loadingMore.value = true;
    final fetched = await _dataService.fetchCommunityEvents(page: _page, pageSize: _pageSize);
    if (fetched.isEmpty) {
      _hasMore = false;
    } else {
      events.value = [...events.value, ...fetched];
      _page += 1;
      if (fetched.length < _pageSize) {
        _hasMore = false;
      }
    }
    loadingMore.value = false;
    notifyListeners();
  }

  @override
  void dispose() {
    events.dispose();
    stories.dispose();
    isLoading.dispose();
    loadingMore.dispose();
    super.dispose();
  }
}

class GiftCardsNotifier extends ChangeNotifier {
  GiftCardsNotifier(this._dataService);

  final MockDataService _dataService;

  final ValueNotifier<List<GiftCard>> cards = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> loadingMore = ValueNotifier(false);
  final ValueNotifier<String?> selectedOccasion = ValueNotifier(null);
  final ValueNotifier<Set<String>> selectedPerks = ValueNotifier(<String>{});

  List<GiftCard> _all = [];
  List<GiftCard> _filtered = [];
  int _page = 0;
  bool _hasMore = true;
  bool _initialized = false;

  bool get hasMore => _hasMore;

  Future<void> loadInitial({bool force = false}) async {
    if (isLoading.value) return;
    if (_initialized && !force) return;
    isLoading.value = true;
    _hasMore = true;
    _page = 0;
    cards.value = [];
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 420));
    _all = List<GiftCard>.from(_dataService.giftCards);
    _applyFilters();
    isLoading.value = false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> refresh() => loadInitial(force: true);

  Future<void> loadMore() async {
    if (!_hasMore || loadingMore.value || isLoading.value) return;
    loadingMore.value = true;
    await Future.delayed(const Duration(milliseconds: 360));
    final nextPage = _page + 1;
    final start = nextPage * MockDataService.giftCardPageSize;
    final nextBatch = _filtered.skip(start).take(MockDataService.giftCardPageSize).toList();
    if (nextBatch.isEmpty) {
      _hasMore = false;
    } else {
      cards.value = [...cards.value, ...nextBatch];
      _page = nextPage;
      _hasMore = cards.value.length < _filtered.length;
    }
    loadingMore.value = false;
    notifyListeners();
  }

  void selectOccasion(String? key) {
    final current = selectedOccasion.value;
    selectedOccasion.value = current == key ? null : key;
    _applyFilters();
    notifyListeners();
  }

  void togglePerk(String key) {
    final current = {...selectedPerks.value};
    if (current.contains(key)) {
      current.remove(key);
    } else {
      current.add(key);
    }
    selectedPerks.value = current;
    _applyFilters();
    notifyListeners();
  }

  void clearPerks() {
    if (selectedPerks.value.isEmpty) return;
    selectedPerks.value = <String>{};
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    Iterable<GiftCard> filtered = _all;
    final occasion = selectedOccasion.value;
    final perks = selectedPerks.value;
    if (occasion != null) {
      filtered = filtered.where((card) => card.occasionKey == occasion);
    }
    if (perks.isNotEmpty) {
      filtered = filtered.where((card) {
        return perks.every((perk) => card.perkKeys.contains(perk));
      });
    }
    _filtered = filtered.toList();
    _page = 0;
    final initial = _filtered.take(MockDataService.giftCardPageSize).toList();
    cards.value = initial;
    _hasMore = _filtered.length > initial.length;
  }

  @override
  void dispose() {
    cards.dispose();
    isLoading.dispose();
    loadingMore.dispose();
    selectedOccasion.dispose();
    selectedPerks.dispose();
    super.dispose();
  }
}

class SubscriptionsNotifier extends ChangeNotifier {
  SubscriptionsNotifier(this._dataService);

  final MockDataService _dataService;

  final ValueNotifier<List<SubscriptionPlan>> plans = ValueNotifier([]);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<bool> loadingMore = ValueNotifier(false);
  final ValueNotifier<String?> selectedTag = ValueNotifier(null);
  final ValueNotifier<int?> selectedDuration = ValueNotifier(null);
  final ValueNotifier<Set<String>> selectedPerks = ValueNotifier(<String>{});

  List<SubscriptionPlan> _all = [];
  List<SubscriptionPlan> _filtered = [];
  int _page = 0;
  bool _hasMore = true;
  bool _initialized = false;

  bool get hasMore => _hasMore;

  Future<void> loadInitial({bool force = false}) async {
    if (isLoading.value) return;
    if (_initialized && !force) return;
    isLoading.value = true;
    _hasMore = true;
    _page = 0;
    plans.value = [];
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 420));
    _all = List<SubscriptionPlan>.from(_dataService.subscriptionPlans);
    _applyFilters();
    isLoading.value = false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> refresh() => loadInitial(force: true);

  Future<void> loadMore() async {
    if (!_hasMore || loadingMore.value || isLoading.value) return;
    loadingMore.value = true;
    await Future.delayed(const Duration(milliseconds: 360));
    final nextPage = _page + 1;
    final start = nextPage * MockDataService.subscriptionPageSize;
    final nextBatch =
        _filtered.skip(start).take(MockDataService.subscriptionPageSize).toList();
    if (nextBatch.isEmpty) {
      _hasMore = false;
    } else {
      plans.value = [...plans.value, ...nextBatch];
      _page = nextPage;
      _hasMore = plans.value.length < _filtered.length;
    }
    loadingMore.value = false;
    notifyListeners();
  }

  void selectTag(String? key) {
    final current = selectedTag.value;
    selectedTag.value = current == key ? null : key;
    _applyFilters();
    notifyListeners();
  }

  void selectDuration(int? weeks) {
    selectedDuration.value = weeks;
    _applyFilters();
    notifyListeners();
  }

  void togglePerk(String key) {
    final current = {...selectedPerks.value};
    if (current.contains(key)) {
      current.remove(key);
    } else {
      current.add(key);
    }
    selectedPerks.value = current;
    _applyFilters();
    notifyListeners();
  }

  void clearPerks() {
    if (selectedPerks.value.isEmpty) return;
    selectedPerks.value = <String>{};
    _applyFilters();
    notifyListeners();
  }

  void clearDuration() {
    if (selectedDuration.value == null) return;
    selectedDuration.value = null;
    _applyFilters();
    notifyListeners();
  }

  void resetAll() {
    selectedTag.value = null;
    selectedDuration.value = null;
    selectedPerks.value = <String>{};
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    Iterable<SubscriptionPlan> filtered = _all;
    final tag = selectedTag.value;
    final duration = selectedDuration.value;
    final perks = selectedPerks.value;
    if (tag != null) {
      filtered = filtered.where((plan) => plan.tagKey == tag);
    }
    if (duration != null) {
      filtered = filtered.where((plan) => plan.durationWeeks >= duration);
    }
    if (perks.isNotEmpty) {
      filtered = filtered.where((plan) {
        return perks.every((perk) => plan.perkKeys.contains(perk));
      });
    }
    final sorted = filtered.toList()
      ..sort((a, b) => a.pricePerWeek.compareTo(b.pricePerWeek));
    _filtered = sorted;
    _page = 0;
    final initial =
        _filtered.take(MockDataService.subscriptionPageSize).toList();
    plans.value = initial;
    _hasMore = _filtered.length > initial.length;
  }

  @override
  void dispose() {
    plans.dispose();
    isLoading.dispose();
    loadingMore.dispose();
    selectedTag.dispose();
    selectedDuration.dispose();
    selectedPerks.dispose();
    super.dispose();
  }
}

class ProfileNotifier extends ChangeNotifier {
  ProfileNotifier(this._dataService);

  final MockDataService _dataService;

  final ValueNotifier<List<UserAddress>> addresses = ValueNotifier([]);
  final ValueNotifier<List<PaymentMethod>> paymentMethods = ValueNotifier([]);
  final ValueNotifier<List<LoyaltyReward>> rewards = ValueNotifier([]);
  final ValueNotifier<List<String>> favoriteRestaurants = ValueNotifier([]);
  final ValueNotifier<double> loyaltyProgress = ValueNotifier(0);
  final ValueNotifier<int> loyaltyPoints = ValueNotifier(0);
  final ValueNotifier<int> loyaltyGoal = ValueNotifier(1200);
  final ValueNotifier<String> tier = ValueNotifier('Rose Gold');

  static const List<String> _tierCycle = ['Rose Gold', 'Saffron Elite', 'Crimson Icon'];

  UserProfile? _profile;
  bool _loading = false;
  bool _initialized = false;
  int _addressCounter = 0;
  int _paymentCounter = 0;
  int _tierIndex = 0;

  bool get isLoading => _loading;
  UserProfile? get profile => _profile;
  bool get canClaimMilestone => loyaltyPoints.value >= loyaltyGoal.value;

  Future<void> loadProfile({bool force = false}) async {
    if (_loading) return;
    if (_initialized && !force) return;
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 480));
    final data = _dataService.userProfile;
    _profile = data;
    addresses.value = data.addresses.map((address) => address).toList();
    paymentMethods.value = data.paymentMethods.map((method) => method).toList();
    rewards.value = data.rewards.map((reward) => reward).toList();
    favoriteRestaurants.value = List<String>.from(data.favoriteRestaurants);
    loyaltyGoal.value = data.nextTierPoints;
    loyaltyPoints.value = data.loyaltyPoints;
    tier.value = data.tier;
    _tierIndex = _tierCycle.indexOf(data.tier);
    if (_tierIndex < 0) {
      _tierIndex = 0;
      tier.value = _tierCycle.first;
    }
    loyaltyProgress.value = _computeProgress(loyaltyPoints.value, loyaltyGoal.value);
    _addressCounter = addresses.value.length;
    _paymentCounter = paymentMethods.value.length;
    _initialized = true;
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() => loadProfile(force: true);

  void setDefaultAddress(String id) {
    final updated = [
      for (final address in addresses.value) address.copyWith(isDefault: address.id == id)
    ];
    addresses.value = updated;
    _profile = _profile?.copyWith(addresses: updated);
    notifyListeners();
  }

  void addQuickAddress() {
    _addressCounter += 1;
    final newAddress = UserAddress(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      label: 'New Spot $_addressCounter',
      details: '456 Culinary Ave, Suite $_addressCounter',
      notes: 'Ring the bell upon arrival',
      isDefault: false,
    );
    addresses.value = [...addresses.value, newAddress];
    _profile = _profile?.copyWith(addresses: addresses.value);
    notifyListeners();
  }

  void setPrimaryPayment(String id) {
    final updated = [
      for (final method in paymentMethods.value)
        method.copyWith(isPrimary: method.id == id)
    ];
    paymentMethods.value = updated;
    _profile = _profile?.copyWith(paymentMethods: updated);
    notifyListeners();
  }

  void addMockPayment() {
    _paymentCounter += 1;
    final suffix = ((_paymentCounter * 873) % 9000) + 1000;
    final method = PaymentMethod(
      id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
      brand: _paymentCounter % 2 == 0 ? 'Visa' : 'Mastercard',
      last4: suffix.toString().padLeft(4, '0'),
      expiry: '0${(_paymentCounter % 9) + 1}/2${(_paymentCounter % 5) + 4}',
      isPrimary: paymentMethods.value.isEmpty,
    );
    paymentMethods.value = [...paymentMethods.value, method];
    _profile = _profile?.copyWith(paymentMethods: paymentMethods.value);
    notifyListeners();
  }

  void toggleRewardClaimed(String id) {
    final updated = [
      for (final reward in rewards.value)
        reward.id == id ? reward.copyWith(isClaimed: !reward.isClaimed) : reward
    ];
    rewards.value = updated;
    _profile = _profile?.copyWith(rewards: updated);
    notifyListeners();
  }

  void boostProgress([int points = 120]) {
    final totalPoints = loyaltyPoints.value + points;
    loyaltyPoints.value = totalPoints;
    loyaltyProgress.value = _computeProgress(loyaltyPoints.value, loyaltyGoal.value);
    _profile = _profile?.copyWith(
      loyaltyPoints: loyaltyPoints.value,
      spent: (_profile?.spent ?? 0) + points / 2,
    );
    notifyListeners();
  }

  void claimMilestone() {
    if (!canClaimMilestone) return;
    final remainder = loyaltyPoints.value - loyaltyGoal.value;
    loyaltyGoal.value += 400;
    loyaltyPoints.value = remainder;
    loyaltyProgress.value = _computeProgress(loyaltyPoints.value, loyaltyGoal.value);
    _tierIndex = (_tierIndex + 1) % _tierCycle.length;
    tier.value = _tierCycle[_tierIndex];
    _profile = _profile?.copyWith(
      tier: tier.value,
      loyaltyPoints: loyaltyPoints.value,
      nextTierPoints: loyaltyGoal.value,
    );
    notifyListeners();
  }

  void toggleFavoriteRestaurant(String restaurant) {
    final set = favoriteRestaurants.value.toSet();
    if (!set.add(restaurant)) {
      set.remove(restaurant);
    }
    final list = set.toList()..sort();
    favoriteRestaurants.value = list;
    _profile = _profile?.copyWith(favoriteRestaurants: list);
    notifyListeners();
  }

  double _computeProgress(int points, int goal) {
    if (goal <= 0) {
      return 0;
    }
    final ratio = points / goal;
    return ratio.clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    addresses.dispose();
    paymentMethods.dispose();
    rewards.dispose();
    favoriteRestaurants.dispose();
    loyaltyProgress.dispose();
    loyaltyPoints.dispose();
    loyaltyGoal.dispose();
    tier.dispose();
    super.dispose();
  }
}

class CartItem {
  const CartItem({required this.item, required this.quantity});

  final FoodItem item;
  final int quantity;

  CartItem copyWith({FoodItem? item, int? quantity}) =>
      CartItem(item: item ?? this.item, quantity: quantity ?? this.quantity);
}
