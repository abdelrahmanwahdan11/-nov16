import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/services/notifiers.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.state});

  static const route = '/profile';
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lina Bright', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text('@linabright', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text('15k+ Spend', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...[
            _ProfileTile(icon: IconlyLight.location, label: 'Manage Address', onTap: () {}),
            _ProfileTile(icon: IconlyLight.wallet, label: 'Payment', onTap: () {}),
            _ProfileTile(icon: IconlyLight.document, label: 'Orders', onTap: () {}),
            _ProfileTile(icon: IconlyLight.discount, label: 'Offer', onTap: () {}),
            _ProfileTile(icon: IconlyLight.info_square, label: 'Help Center', onTap: () {}),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushNamed(SettingsScreen.route),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Logout'),
          )
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
