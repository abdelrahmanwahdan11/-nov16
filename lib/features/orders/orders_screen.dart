import 'package:flutter/material.dart';

import '../../core/services/notifiers.dart';
import '../../core/widgets/skeleton_loader.dart';
import 'track_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.state});

  static const route = '/orders';
  final AppState state;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final notifier = widget.state.ordersNotifier;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Orders'),
          bottom: const TabBar(tabs: [Tab(text: 'Current'), Tab(text: 'History')]),
        ),
        body: TabBarView(
          children: [
            _OrdersList(
              ordersListenable: notifier.currentOrders,
              onRefresh: notifier.refresh,
              showTrack: true,
            ),
            _OrdersList(
              ordersListenable: notifier.historyOrders,
              onRefresh: notifier.refresh,
              showTrack: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({
    required this.ordersListenable,
    required this.onRefresh,
    required this.showTrack,
  });

  final ValueNotifier<List<Order>> ordersListenable;
  final Future<void> Function() onRefresh;
  final bool showTrack;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ValueListenableBuilder<List<Order>>(
        valueListenable: ordersListenable,
        builder: (context, orders, _) {
          if (orders.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: 4,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: SkeletonLoader(height: 120, borderRadius: 24),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Container(
                padding: const EdgeInsets.all(16),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order.id, style: Theme.of(context).textTheme.titleMedium),
                        Chip(label: Text(order.status)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(order.date.toLocal().toString().split(' ').first),
                    const SizedBox(height: 8),
                    Text('Total ${order.total.toStringAsFixed(2)} USD'),
                    if (showTrack) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(TrackOrderScreen.route, arguments: order),
                          child: const Text('Track'),
                        ),
                      )
                    ]
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
