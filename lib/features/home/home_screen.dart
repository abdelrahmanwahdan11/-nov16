import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/loyalty_progress_card.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/utils/responsive.dart';
import '../catalog/catalog_screen.dart';
import '../food_details/food_details_screen.dart';
import '../rewards/rewards_screen.dart';
import '../meal_planner/meal_planner_screen.dart';
import '../community/community_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.state});

  static const route = '/home';
  final AppState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 120) {
        widget.state.homeFeedNotifier.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await widget.state.homeFeedNotifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notifier = widget.state.homeFeedNotifier;
    final community = widget.state.communityNotifier;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              title: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=200&q=80'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate('deliver_to'),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                      ),
                      Row(
                        children: [
                          Text(loc.translate('sample_city'), style: theme.textTheme.bodyLarge),
                          const Icon(Icons.keyboard_arrow_down, size: 18),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(IconlyLight.search),
                    onPressed: () => Navigator.of(context).pushNamed(CatalogScreen.route),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: context.pagePadding,
              child: Column(
                children: [
                  _OfferBanner(theme: theme, loc: loc),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      widget.state.profileNotifier,
                      widget.state.profileNotifier.loyaltyProgress,
                      widget.state.profileNotifier.loyaltyPoints,
                      widget.state.profileNotifier.loyaltyGoal,
                      widget.state.profileNotifier.tier,
                    ]),
                    builder: (context, _) {
                      final profileNotifier = widget.state.profileNotifier;
                      if (profileNotifier.profile == null) {
                        if (profileNotifier.isLoading) {
                          return const SkeletonLoader(height: 160, borderRadius: 28);
                        }
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          LoyaltyProgressCard(
                            loc: loc,
                            tier: profileNotifier.tier.value,
                            progress: profileNotifier.loyaltyProgress.value,
                            points: profileNotifier.loyaltyPoints.value,
                            goal: profileNotifier.loyaltyGoal.value,
                            heroTag: 'loyalty-card',
                            onTap: () => Navigator.of(context).pushNamed(RewardsScreen.route),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      widget.state.mealPlannerNotifier,
                      widget.state.mealPlannerNotifier.days,
                      widget.state.mealPlannerNotifier.activeDayIndex,
                    ]),
                    builder: (context, _) {
                      final planner = widget.state.mealPlannerNotifier;
                      final days = planner.days.value;
                      if (planner.isLoading && days.isEmpty) {
                        return const SkeletonLoader(height: 160, borderRadius: 28);
                      }
                      if (days.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final active = planner.activeDayIndex.value.clamp(0, days.length - 1);
                      final day = days[active];
                      return Column(
                        children: [
                          _MealPlanPreview(
                            day: day,
                            loc: loc,
                            onTap: () => Navigator.of(context).pushNamed(MealPlannerScreen.route),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                  SectionHeader(
                    title: loc.translate('community'),
                    actionLabel: loc.translate('view_all'),
                    onActionPressed: () => Navigator.of(context).pushNamed(CommunityScreen.route),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 210,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: community.isLoading,
                      builder: (context, loadingCommunity, __) {
                        return ValueListenableBuilder<List<CommunityEvent>>(
                          valueListenable: community.events,
                          builder: (context, events, ___) {
                            if (loadingCommunity && events.isEmpty) {
                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (_, __) => const SkeletonLoader(
                                  width: 220,
                                  height: 200,
                                  borderRadius: 24,
                                ),
                                separatorBuilder: (_, __) => const SizedBox(width: 16),
                                itemCount: 3,
                              );
                            }
                            if (events.isEmpty) {
                              return Center(
                                child: Text(
                                  loc.translate('community_empty'),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              );
                            }
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: events.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 16),
                              itemBuilder: (context, index) {
                                final event = events[index];
                                return _CommunityPreviewCard(
                                  event: event,
                                  loc: loc,
                                  onTap: () => Navigator.of(context).pushNamed(CommunityScreen.route),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(
                    title: loc.translate('categories'),
                    actionLabel: loc.translate('view_all'),
                    onActionPressed: () => Navigator.of(context).pushNamed(CatalogScreen.route),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ValueListenableBuilder<List<Category>>(
                      valueListenable: notifier.categories,
                      builder: (context, categories, _) {
                        if (categories.isEmpty) {
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, __) => const SkeletonLoader(width: 100, height: 100, borderRadius: 24),
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemCount: 4,
                          );
                        }
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, index) {
                            final category = categories[index];
                            return _CategoryChip(category: category, onTap: () => Navigator.of(context).pushNamed(CatalogScreen.route));
                          },
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemCount: categories.length,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(title: loc.translate('popular_items'), actionLabel: loc.translate('view_all'), onActionPressed: () => Navigator.of(context).pushNamed(CatalogScreen.route)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 260,
                    child: ValueListenableBuilder<List<FoodItem>>(
                      valueListenable: notifier.popular,
                      builder: (context, items, _) {
                        if (items.isEmpty) {
                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, __) => const SkeletonLoader(width: 220, height: 240, borderRadius: 24),
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemCount: 3,
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _PopularCard(item: item, state: widget.state);
                          },
                        );
                      },
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: notifier.loadingMore,
                    builder: (context, loading, _) {
                      if (!loading) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: CircularProgressIndicator(color: theme.colorScheme.primary),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: notifier,
                    builder: (context, _) {
                      if (!notifier.hasMore && notifier.popular.value.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            loc.translate('no_more_results'),
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _OfferBanner extends StatelessWidget {
  const _OfferBanner({required this.theme, required this.loc});

  final ThemeData theme;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'offer_banner',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
          boxShadow: [
            BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 12)),
          ],
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.translate('offer_banner_title'),
              style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              loc.translate('offer_banner_subtitle'),
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(CatalogScreen.route),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(loc.translate('shop_now')),
            )
          ],
        ),
      ),
    );
  }
}

class _MealPlanPreview extends StatelessWidget {
  const _MealPlanPreview({required this.day, required this.loc, required this.onTap});

  final MealPlanDay day;
  final AppLocalizations loc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.18),
              theme.colorScheme.primary.withOpacity(0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(IconlyBold.calendar, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    loc.translate('weekly_focus'),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(loc.translate(day.day)),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                ),
                Chip(
                  label: Text(loc.translate(day.focusKey)),
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.16),
                ),
                Chip(
                  label: Text(loc.translate('daily_calories').replaceFirst('%d', day.totalCalories.toString())),
                  backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              loc.translate(day.tipKey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 54,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: day.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = day.items[index];
                  return Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.cardColor,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${loc.translate('currency_symbol')}${item.price.toStringAsFixed(2)}',
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
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

class _CommunityPreviewCard extends StatelessWidget {
  const _CommunityPreviewCard({required this.event, required this.loc, required this.onTap});

  final CommunityEvent event;
  final AppLocalizations loc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Image.network(event.imageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          loc.translate(event.scheduleKey),
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (event.isLive)
                        Icon(IconlyBold.play, size: 16, color: theme.colorScheme.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.translate(event.titleKey),
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.translate(event.descriptionKey),
                    style: theme.textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(
                          event.isVirtual
                              ? loc.translate('virtual_event')
                              : loc.translate('in_person_event'),
                        ),
                      ),
                      for (final key in event.highlightKeys.take(1))
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(loc.translate(key)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  const _CategoryChip({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(_hovered ? 0.2 : 0.05),
                blurRadius: _hovered ? 16 : 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(widget.category.iconUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.category.name, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularCard extends StatefulWidget {
  const _PopularCard({required this.item, required this.state});

  final FoodItem item;
  final AppState state;

  @override
  State<_PopularCard> createState() => _PopularCardState();
}

class _PopularCardState extends State<_PopularCard> {
  bool _hovered = false;

  void _openDetails() {
    Navigator.of(context).pushNamed(FoodDetailsScreen.route, arguments: widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      margin: const EdgeInsets.only(right: 16),
      width: 220,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(_hovered ? -0.05 : 0)
        ..rotateX(_hovered ? 0.03 : 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 10)),
        ],
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: _openDetails,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: widget.item.id,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: Image.network(widget.item.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    RatingStars(rating: widget.item.rating, reviewCount: widget.item.reviews),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${widget.item.price.toStringAsFixed(2)} USD', style: Theme.of(context).textTheme.titleMedium),
                        IconButton(
                          icon: const Icon(IconlyLight.plus, size: 20),
                          onPressed: () => widget.state.cartNotifier.add(widget.item),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
