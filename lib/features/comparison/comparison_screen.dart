import 'package:flutter/material.dart';

import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/empty_state.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key, required this.state});

  static const route = '/comparison';
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comparison')),
      body: ValueListenableBuilder<List<FoodItem>>(
        valueListenable: state.comparisonNotifier.selected,
        builder: (context, selected, _) {
          if (selected.isEmpty) {
            return const Center(
              child: EmptyState(
                title: 'No items selected',
                subtitle: 'Choose meals from catalog or restaurants to compare.',
              ),
            );
          }
          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: selected
                      .map(
                        (item) => Container(
                          width: 200,
                          margin: const EdgeInsetsDirectional.only(end: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                child: Image.network(item.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 8),
                                    Text('${item.price.toStringAsFixed(2)} USD', style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 8),
                                    Text('Rating: ${item.rating.toStringAsFixed(1)}'),
                                    const SizedBox(height: 8),
                                    Text('Delivery: ${item.deliveryTime} min'),
                                    const SizedBox(height: 8),
                                    Text('Ingredients: ${item.ingredients.join(', ')}'),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: state.comparisonNotifier.clear,
                  child: const Text('Clear comparison'),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
