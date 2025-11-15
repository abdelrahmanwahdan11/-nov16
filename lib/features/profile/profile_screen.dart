import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/loyalty_progress_card.dart';
import '../favorites/favorites_screen.dart';
import '../help/help_center_screen.dart';
import '../orders/orders_screen.dart';
import '../rewards/rewards_screen.dart';
import '../settings/settings_screen.dart';
import 'manage_address_screen.dart';
import 'payment_methods_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.state});

  static const route = '/profile';
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final notifier = state.profileNotifier;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('profile'))),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          notifier,
          notifier.loyaltyProgress,
          notifier.loyaltyPoints,
          notifier.tier,
          notifier.favoriteRestaurants,
        ]),
        builder: (context, _) {
          final profile = notifier.profile;
          if (profile == null && notifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (profile == null) {
            return Center(child: Text(loc.translate('empty_state')));
          }
          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _ProfileHeader(profile: profile, tier: notifier.tier.value, loc: loc),
                const SizedBox(height: 24),
                LoyaltyProgressCard(
                  loc: loc,
                  tier: notifier.tier.value,
                  progress: notifier.loyaltyProgress.value,
                  points: notifier.loyaltyPoints.value,
                  goal: notifier.loyaltyGoal.value,
                  heroTag: 'loyalty-card',
                  onTap: () => Navigator.of(context).pushNamed(RewardsScreen.route),
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<List<String>>(
                  valueListenable: notifier.favoriteRestaurants,
                  builder: (context, favorites, __) {
                    if (favorites.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.translate('favorite_restaurants'), style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final name in favorites)
                              ChoiceChip(
                                label: Text(name),
                                selected: true,
                                onSelected: (_) => notifier.toggleFavoriteRestaurant(name),
                              )
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
                _ProfileTile(
                  icon: IconlyLight.location,
                  label: loc.translate('manage_address'),
                  onTap: () => Navigator.of(context).pushNamed(ManageAddressScreen.route),
                ),
                _ProfileTile(
                  icon: IconlyLight.wallet,
                  label: loc.translate('payment_methods'),
                  onTap: () => Navigator.of(context).pushNamed(PaymentMethodsScreen.route),
                ),
                _ProfileTile(
                  icon: IconlyLight.document,
                  label: loc.translate('orders'),
                  onTap: () => Navigator.of(context).pushNamed(OrdersScreen.route),
                ),
                _ProfileTile(
                  icon: IconlyBold.heart,
                  label: loc.translate('favorites'),
                  onTap: () => Navigator.of(context).pushNamed(FavoritesScreen.route),
                ),
                _ProfileTile(
                  icon: IconlyLight.info_square,
                  label: loc.translate('help_center'),
                  onTap: () => Navigator.of(context).pushNamed(HelpCenterScreen.route),
                ),
                _ProfileTile(
                  icon: IconlyLight.setting,
                  label: loc.translate('settings'),
                  onTap: () => Navigator.of(context).pushNamed(SettingsScreen.route),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.translate('logout_message'))),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: Text(loc.translate('logout')),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.tier, required this.loc});

  final UserProfile profile;
  final String tier;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 12)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(profile.avatarUrl)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(profile.handle, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  '${loc.translate('lifetime_spend')}: ${profile.spent.toStringAsFixed(0)}+',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
          Chip(
            label: Text('${loc.translate('loyalty_tier')}: $tier'),
            backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
            labelStyle: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
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
