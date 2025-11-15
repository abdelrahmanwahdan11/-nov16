import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/rating_stars.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../catalog/catalog_screen.dart';
import '../food_details/food_details_screen.dart';

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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _OfferBanner(theme: theme, loc: loc),
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
