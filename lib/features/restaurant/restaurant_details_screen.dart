import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/rating_stars.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  const RestaurantDetailsScreen({super.key, required this.state, required this.restaurant});

  static const route = '/restaurant-details';
  final AppState state;
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: restaurant.id,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(restaurant.imageUrl, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(restaurant.name),
            ),
            actions: [
              IconButton(
                icon: const Icon(IconlyLight.heart),
                onPressed: () => state.favoritesNotifier.toggle(restaurant.menu.first),
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RatingStars(rating: restaurant.rating, reviewCount: 340),
                      const SizedBox(width: 16),
                      Chip(label: Text('${restaurant.deliveryTime} min')),
                      const SizedBox(width: 8),
                      Chip(label: Text('${restaurant.deliveryFee.toStringAsFixed(2)} delivery')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Menu', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: restaurant.menu.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = restaurant.menu[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: ListTile(
                          leading: Hero(
                            tag: item.id,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(item.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                            ),
                          ),
                          title: Text(item.name),
                          subtitle: Text('${item.deliveryTime} min • ${item.rating.toStringAsFixed(1)} ★'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${item.price.toStringAsFixed(2)} USD'),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(IconlyLight.plus, size: 18),
                                    onPressed: () => state.cartNotifier.add(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(IconlyLight.switch_icon, size: 18),
                                    onPressed: () => state.comparisonNotifier.toggle(item),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
