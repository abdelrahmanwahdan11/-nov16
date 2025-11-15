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
  bool _loading = false;
  int _page = 0;

  bool get isLoading => _loading;

  Future<void> loadInitial() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    offers.value = _dataService.mockOffers;
    categories.value = _dataService.mockCategories;
    popular.value = _dataService.paginatePopular(_page);
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _page = 0;
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _page += 1;
    popular.value = [...popular.value, ..._dataService.paginatePopular(_page)];
    _loading = false;
    notifyListeners();
  }
}

class CatalogNotifier extends ChangeNotifier {
  CatalogNotifier(this._dataService);

  final MockDataService _dataService;
  final ValueNotifier<List<FoodItem>> items = ValueNotifier([]);
  final ValueNotifier<Set<String>> activeFilters = ValueNotifier({});
  final ValueNotifier<String?> sortOption = ValueNotifier(null);
  bool _loading = false;
  int _page = 0;

  Future<void> loadInitial() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    items.value = _dataService.paginateCatalog(_page);
    _loading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _page = 0;
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 450));
    _page += 1;
    items.value = [...items.value, ..._dataService.paginateCatalog(_page)];
    _loading = false;
    notifyListeners();
  }

  void toggleFilter(String filter) {
    final filters = Set<String>.from(activeFilters.value);
    if (!filters.add(filter)) {
      filters.remove(filter);
    }
    activeFilters.value = filters;
    items.value = _dataService.filterCatalog(filters, sortOption.value);
  }

  void updateSort(String option) {
    sortOption.value = option;
    items.value = _dataService.filterCatalog(activeFilters.value, option);
    notifyListeners();
  }
}

class SearchNotifier extends ChangeNotifier {
  SearchNotifier(this._dataService);

  final MockDataService _dataService;
  final ValueNotifier<List<String>> history = ValueNotifier([]);
  final ValueNotifier<List<FoodItem>> results = ValueNotifier([]);
  final TextEditingController controller = TextEditingController();
  bool _isSearching = false;

  bool get isSearching => _isSearching;

  void search(String query) {
    _isSearching = true;
    notifyListeners();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      results.value = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    if (!history.value.contains(trimmed)) {
      history.value = [trimmed, ...history.value.take(4)];
    }
    results.value = _dataService.searchFood(trimmed);
    _isSearching = false;
    notifyListeners();
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
}

class OrdersNotifier extends ChangeNotifier {
  OrdersNotifier(this._dataService);

  final MockDataService _dataService;
  final ValueNotifier<List<Order>> currentOrders = ValueNotifier([]);
  final ValueNotifier<List<Order>> historyOrders = ValueNotifier([]);
  bool _loading = false;

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
}

class CartItem {
  const CartItem({required this.item, required this.quantity});

  final FoodItem item;
  final int quantity;

  CartItem copyWith({FoodItem? item, int? quantity}) =>
      CartItem(item: item ?? this.item, quantity: quantity ?? this.quantity);
}
