import 'package:flutter/material.dart';

import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../restaurant/restaurant_details_screen.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key, required this.state});

  static const route = '/restaurants';
  final AppState state;

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  final MockDataService _dataService = MockDataService();
  final ScrollController _controller = ScrollController();
  List<Restaurant> _restaurants = [];
  bool _loading = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 120) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_loading) return;
    _loading = true;
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
    final nextItems = _dataService.restaurants.skip(_page * 4).take(4).toList();
    _restaurants = [..._restaurants, ...nextItems];
    _page += 1;
    _loading = false;
    setState(() {});
  }

  Future<void> _refresh() async {
    _restaurants = [];
    _page = 0;
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restaurants')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          controller: _controller,
          padding: const EdgeInsets.all(24),
          itemCount: _restaurants.isEmpty ? 4 : _restaurants.length + (_loading ? 1 : 0),
          itemBuilder: (context, index) {
            if (_restaurants.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: SkeletonLoader(height: 220, borderRadius: 28),
              );
            }
            if (index >= _restaurants.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final restaurant = _restaurants[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _RestaurantCard(restaurant: restaurant, state: widget.state),
            );
          },
        ),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant, required this.state});

  final Restaurant restaurant;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(RestaurantDetailsScreen.route, arguments: restaurant),
      child: Hero(
        tag: restaurant.id,
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: Image.network(restaurant.imageUrl, height: 130, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    RatingStars(rating: restaurant.rating, reviewCount: 220),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${restaurant.deliveryTime} min'),
                        Text('${restaurant.deliveryFee.toStringAsFixed(2)} delivery'),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
