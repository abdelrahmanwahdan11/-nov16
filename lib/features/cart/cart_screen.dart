import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/notifiers.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.state});

  static const route = '/cart';
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('my_cart'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You will get free delivery using this coupon!',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('FOODLYFREE', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(loc.translate('use_now')),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ValueListenableBuilder<List<CartItem>>(
                valueListenable: state.cartNotifier.items,
                builder: (context, items, _) {
                  if (items.isEmpty) {
                    return Center(child: Text(loc.translate('empty_state')));
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final cartItem = items[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(cartItem.item.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cartItem.item.name, style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  Text('${cartItem.item.price.toStringAsFixed(2)} USD'),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(IconlyLight.minus),
                                  onPressed: () => state.cartNotifier.updateQuantity(cartItem.item, -1),
                                ),
                                Text(cartItem.quantity.toString()),
                                IconButton(
                                  icon: const Icon(IconlyLight.plus),
                                  onPressed: () => state.cartNotifier.updateQuantity(cartItem.item, 1),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(IconlyLight.delete),
                              onPressed: () => state.cartNotifier.remove(cartItem.item),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ValueListenableBuilder<List<CartItem>>(
              valueListenable: state.cartNotifier.items,
              builder: (context, items, _) {
                final total = state.cartNotifier.total;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loc.translate('total'), style: Theme.of(context).textTheme.headlineSmall),
                        Text('${total.toStringAsFixed(2)} USD', style: Theme.of(context).textTheme.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: items.isEmpty ? null : () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text('${loc.translate('checkout')} (${items.length})'),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
