import 'dart:async';
import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';
import 'shared_prefs_service.dart';
import 'mock_data_service.dart';

class AppState extends ChangeNotifier {
  AppState()
      : themeNotifier = ThemeNotifier(),
        localeNotifier = LocaleNotifier(),
        homeFeedNotifier = HomeFeedNotifier(MockDataService()),
        catalogNotifier = CatalogNotifier(MockDataService()),
        searchNotifier = SearchNotifier(MockDataService()),
        cartNotifier = CartNotifier(),
        comparisonNotifier = ComparisonNotifier(),
        favoritesNotifier = FavoritesNotifier(),
        ordersNotifier = OrdersNotifier(MockDataService());

  final ThemeNotifier themeNotifier;
  final LocaleNotifier localeNotifier;
  final HomeFeedNotifier homeFeedNotifier;
  final CatalogNotifier catalogNotifier;
  final SearchNotifier searchNotifier;
  final CartNotifier cartNotifier;
  final ComparisonNotifier comparisonNotifier;
  final FavoritesNotifier favoritesNotifier;
  final OrdersNotifier ordersNotifier;

  final SharedPrefsService prefs = SharedPrefsService();

  Future<void> bootstrap() async {
    await prefs.init();
    themeNotifier.applyPrefs(prefs);
    localeNotifier.applyPrefs(prefs);
    unawaited(homeFeedNotifier.loadInitial());
    unawaited(catalogNotifier.loadInitial());
    unawaited(ordersNotifier.loadInitial());
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

class CartItem {
  const CartItem({required this.item, required this.quantity});

  final FoodItem item;
  final int quantity;

  CartItem copyWith({FoodItem? item, int? quantity}) =>
      CartItem(item: item ?? this.item, quantity: quantity ?? this.quantity);
}
