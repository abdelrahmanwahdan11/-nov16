import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/notifiers.dart';
import '../cart/cart_screen.dart';
import '../catalog/catalog_screen.dart';
import '../comparison/comparison_screen.dart';
import '../favorites/favorites_screen.dart';
import '../chat/chat_screen.dart';
import '../help/help_center_screen.dart';
import '../home/home_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../rewards/rewards_screen.dart';
import '../restaurant/restaurants_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../meal_planner/meal_planner_screen.dart';
import '../community/community_screen.dart';
import '../notifications/notifications_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key, required this.state});

  static const route = '/shell';
  final AppState state;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> with SingleTickerProviderStateMixin {
  final ValueNotifier<int> _currentIndex = ValueNotifier(0);
  final ValueNotifier<bool> _drawerOpen = ValueNotifier(false);

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  void _onItemTapped(int index) {
    _currentIndex.value = index;
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 420), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final pages = [
      HomeScreen(state: widget.state),
      RestaurantsScreen(state: widget.state),
      CartScreen(state: widget.state),
      ChatScreen(state: widget.state),
    ];

    return ValueListenableBuilder<bool>(
      valueListenable: _drawerOpen,
      builder: (context, drawerOpen, child) {
        return AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: drawerOpen ? 0.92 : 1,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: drawerOpen ? const Offset(0.2, 0.02) : Offset.zero,
            child: Scaffold(
              extendBody: true,
              appBar: AppBar(
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      _drawerOpen.value = true;
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                title: Text(loc.translate('app_title')),
                actions: [
                  ValueListenableBuilder<int>(
                    valueListenable: widget.state.notificationsNotifier.unreadCount,
                    builder: (context, unread, _) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(IconlyLight.notification),
                            onPressed: () => Navigator.of(context).pushNamed(NotificationsScreen.route),
                          ),
                          if (unread > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: unread > 0 ? 1 : 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    unread > 9 ? '9+' : '$unread',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(IconlyLight.search),
                    onPressed: () => Navigator.of(context).pushNamed(SearchScreen.route),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              drawerScrimColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              onDrawerChanged: (isOpen) => _drawerOpen.value = isOpen,
              drawer: _AppDrawer(state: widget.state),
              body: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return PageTransitionSwitcher(
                    transitionBuilder: (child, animation, secondaryAnimation) {
                      return FadeThroughTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        child: child,
                      );
                    },
                    child: pages[index],
                  );
                },
              ),
              bottomNavigationBar: _ShellBottomNavigation(
                currentIndexListenable: _currentIndex,
                onTap: _onItemTapped,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShellBottomNavigation extends StatelessWidget {
  const _ShellBottomNavigation({
    required this.currentIndexListenable,
    required this.onTap,
  });

  final ValueNotifier<int> currentIndexListenable;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentIndexListenable,
      builder: (context, currentIndex, _) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, -4)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                label: AppLocalizations.of(context).translate('home'),
                icon: IconlyLight.home,
                active: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                label: AppLocalizations.of(context).translate('restaurants'),
                icon: IconlyLight.discovery,
                active: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _FloatingNavItem(
                icon: IconlyBold.bag,
                label: AppLocalizations.of(context).translate('my_cart'),
                active: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                label: AppLocalizations.of(context).translate('chat'),
                icon: IconlyLight.message,
                active: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.icon, required this.active, required this.onTap});

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: active ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({required this.icon, required this.label, required this.active, required this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ]),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                  blurRadius: active ? 24 : 12,
                  spreadRadius: active ? 1 : 0,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.primary)),
      ],
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profileNotifier = state.profileNotifier;
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(32), bottomRight: Radius.circular(32))),
      child: SafeArea(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([profileNotifier, profileNotifier.loyaltyProgress, profileNotifier.tier]),
              builder: (context, _) {
                final profile = profileNotifier.profile;
                return Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(profile?.avatarUrl ?? 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile?.name ?? 'Foodly', style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 4),
                            Text(profile?.email ?? 'hello@foodly.app', style: theme.textTheme.bodySmall),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                minHeight: 6,
                                value: profileNotifier.loyaltyProgress.value,
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${loc.translate('loyalty_tier')}: ${profileNotifier.tier.value}',
                              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: ListView(
                children: [
                  _DrawerTile(label: loc.translate('home'), icon: IconlyLight.home, onTap: () => Navigator.of(context).pushReplacementNamed(HomeScreen.route)),
                  _DrawerTile(label: loc.translate('restaurants'), icon: IconlyLight.discovery, onTap: () => Navigator.of(context).pushReplacementNamed(RestaurantsScreen.route)),
                  _DrawerTile(label: loc.translate('catalog'), icon: IconlyLight.category, onTap: () => Navigator.of(context).pushNamed(CatalogScreen.route)),
                  _DrawerTile(label: loc.translate('comparison'), icon: IconlyBold.chart, onTap: () => Navigator.of(context).pushNamed(ComparisonScreen.route)),
                  _DrawerTile(label: loc.translate('rewards'), icon: IconlyBold.star, onTap: () => Navigator.of(context).pushNamed(RewardsScreen.route)),
                  _DrawerTile(label: loc.translate('community'), icon: IconlyBold.user, onTap: () => Navigator.of(context).pushNamed(CommunityScreen.route)),
                  _DrawerTile(label: loc.translate('meal_planner'), icon: IconlyLight.calendar, onTap: () => Navigator.of(context).pushNamed(MealPlannerScreen.route)),
                  _DrawerTile(label: loc.translate('orders'), icon: IconlyLight.document, onTap: () => Navigator.of(context).pushNamed(OrdersScreen.route)),
                  _DrawerTile(label: loc.translate('favorites'), icon: IconlyBold.heart, onTap: () => Navigator.of(context).pushNamed(FavoritesScreen.route)),
                  _DrawerTile(label: loc.translate('chat'), icon: IconlyLight.message, onTap: () => Navigator.of(context).pushNamed(ChatScreen.route)),
                  _DrawerTile(label: loc.translate('notifications'), icon: IconlyLight.notification, onTap: () => Navigator.of(context).pushNamed(NotificationsScreen.route)),
                  _DrawerTile(label: loc.translate('profile'), icon: IconlyLight.profile, onTap: () => Navigator.of(context).pushNamed(ProfileScreen.route)),
                  _DrawerTile(label: loc.translate('settings'), icon: IconlyLight.setting, onTap: () => Navigator.of(context).pushNamed(SettingsScreen.route)),
                  _DrawerTile(label: loc.translate('help_center'), icon: IconlyLight.info_square, onTap: () => Navigator.of(context).pushNamed(HelpCenterScreen.route)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyLarge),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }
}

