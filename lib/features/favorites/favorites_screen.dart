import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/empty_state.dart';
import '../food_details/food_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.state});

  static const route = '/favorites';
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final service = MockDataService();
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('favorites'))),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: state.favoritesNotifier.favorites,
        builder: (context, favorites, _) {
          if (favorites.isEmpty) {
            return Center(
              child: EmptyState(
                title: loc.translate('empty_favorites_title'),
                subtitle: loc.translate('empty_favorites_subtitle'),
              ),
            );
          }
          final items = service.itemsByIds(favorites);
          return RefreshIndicator(
            onRefresh: () async {
              await state.catalogNotifier.refresh();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  onTap: () => Navigator.of(context).pushNamed(FoodDetailsScreen.route, arguments: item),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  title: Text(item.name),
                  subtitle: Text('${item.price.toStringAsFixed(2)} USD'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => state.favoritesNotifier.toggle(item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
