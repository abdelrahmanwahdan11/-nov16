import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/services/notifiers.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key, required this.state});

  static const route = '/help';
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final faqs = const [
      {'q': 'How to track my order?', 'a': 'Use the Track button in Orders to view live status.'},
      {'q': 'Can I schedule deliveries?', 'a': 'Scheduling is coming soon. Stay tuned!'},
      {'q': 'Where do I apply coupons?', 'a': 'On the cart screen you can use your coupons and deals.'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ...faqs.map(
            (faq) => ExpansionTile(
              title: Text(faq['q']!),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(faq['a']!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(IconlyBold.chat, size: 48),
                      SizedBox(height: 12),
                      Text('Chat with support (coming soon)'),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(IconlyBold.chat),
            label: const Text('Chat with support'),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
          )
        ],
      ),
    );
  }
}
