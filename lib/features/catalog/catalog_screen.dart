import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../food_details/food_details_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.state});

  static const route = '/catalog';
  final AppState state;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ScrollController _controller = ScrollController();
  final List<String> filters = const ['Fast Food', 'Sea Food', 'Dessert'];
  final List<String> sortOptions = const ['Best match', 'Lowest price', 'Highest rating', 'Fastest delivery'];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 100) {
        widget.state.catalogNotifier.loadMore();
      }
    });
  }

  Future<void> _refresh() async {
    await widget.state.catalogNotifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = widget.state.catalogNotifier;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.filter),
            onPressed: () => _showSortSheet(context),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ValueListenableBuilder<List<FoodItem>>(
          valueListenable: notifier.items,
          builder: (context, items, _) {
            return ListView(
              controller: _controller,
              padding: const EdgeInsets.all(24),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: filters
                      .map(
                        (f) => FilterChip(
                          label: Text(f),
                          selected: notifier.activeFilters.value.contains(f),
                          onSelected: (_) => notifier.toggleFilter(f),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                if (items.isEmpty)
                  Column(
                    children: List.generate(
                      4,
                      (index) => const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: SkeletonLoader(height: 120, borderRadius: 24),
                      ),
                    ),
                  )
                else
                  ...items.map((item) => _CatalogCard(item: item, state: widget.state)).toList(),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => notifier.loadMore(),
                    child: const Text('Load more'),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    final notifier = widget.state.catalogNotifier;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sortOptions
                .map(
                  (option) => RadioListTile<String>(
                    value: option,
                    groupValue: notifier.sortOption.value,
                    onChanged: (value) {
                      notifier.updateSort(value!);
                      Navigator.of(context).pop();
                    },
                    title: Text(option),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.item, required this.state});

  final FoodItem item;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: ListTile(
        onTap: () => Navigator.of(context).pushNamed(FoodDetailsScreen.route, arguments: item),
        leading: Hero(
          tag: item.id,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(item.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
          ),
        ),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            RatingStars(rating: item.rating, reviewCount: item.reviews),
            const SizedBox(height: 4),
            Text('${item.deliveryTime} min delivery'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${item.price.toStringAsFixed(2)} USD'),
            IconButton(
              icon: const Icon(IconlyLight.plus),
              onPressed: () => state.cartNotifier.add(item),
            ),
          ],
        ),
      ),
    );
  }
}
