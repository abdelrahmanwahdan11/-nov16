import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../food_details/food_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.state});

  static const route = '/search';
  final AppState state;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.state.searchNotifier;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('search'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _notifier.controller,
              onChanged: _notifier.search,
              decoration: InputDecoration(
                hintText: loc.translate('search_food'),
                prefixIcon: const Icon(IconlyLight.search),
                suffixIcon: IconButton(
                  icon: const Icon(IconlyLight.filter),
                  onPressed: () => _notifier.search(_notifier.controller.text),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<List<String>>(
              valueListenable: _notifier.history,
              builder: (context, history, _) {
                if (history.isEmpty) return const SizedBox.shrink();
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children: history
                        .map(
                          (item) => FilterChip(
                            label: Text(item),
                            onSelected: (_) {
                              _notifier.controller.text = item;
                              _notifier.search(item);
                            },
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<FoodItem>>(
                valueListenable: _notifier.results,
                builder: (context, results, _) {
                  if (_notifier.isSearching) {
                    return ListView.builder(
                      itemCount: 4,
                      itemBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: SkeletonLoader(height: 120, borderRadius: 24),
                      ),
                    );
                  }
                  if (results.isEmpty) {
                    return EmptyState(
                      title: loc.translate('empty_state'),
                      subtitle: loc.translate('search_empty_subtitle'),
                    );
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        margin: const EdgeInsets.only(bottom: 16),
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
                              Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          trailing: Text('${item.price.toStringAsFixed(2)} USD'),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
