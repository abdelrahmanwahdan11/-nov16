import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/skeleton_loader.dart';

class ChefsScreen extends StatefulWidget {
  const ChefsScreen({super.key, required this.state});

  static const route = '/chefs';
  final AppState state;

  @override
  State<ChefsScreen> createState() => _ChefsScreenState();
}

class _ChefsScreenState extends State<ChefsScreen> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 160) {
          widget.state.chefsNotifier.loadMore();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await widget.state.chefsNotifier.refresh();
  }

  void _showChefDetails(ChefProfile chef) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final mediaQuery = MediaQuery.of(context);
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: mediaQuery.viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Center(
            child: Hero(
              tag: 'chef_${chef.id}',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: context.constrainedWidth(560),
                  ),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: NetworkImage(chef.imageUrl),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.translate(chef.nameKey),
                                  style: theme.textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc.translate(chef.titleKey),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  loc
                                      .translate('chefs_experience_years')
                                      .replaceFirst('%d',
                                          chef.experienceYears.toString()),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        loc.translate('chefs_detail_story'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.translate(chef.storyKey),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        loc.translate('chefs_detail_specialties'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final key in chef.specialtyKeys)
                            Chip(
                              label: Text(loc.translate(key)),
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.1),
                              labelStyle: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final key in chef.highlightKeys)
                            Chip(
                              avatar: Icon(
                                IconlyLight.star,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              label: Text(loc.translate(key)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: loc.translate('chefs_detail_cta'),
                              onPressed: () {},
                              icon: IconlyBold.message,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SecondaryButton(
                              label: loc.translate('chefs_detail_secondary'),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notifier = widget.state.chefsNotifier;
    final mock = widget.state.mockDataService;
    final merged = Listenable.merge([
      notifier,
      notifier.profiles,
      notifier.isLoading,
      notifier.loadingMore,
      notifier.selectedCuisines,
      notifier.selectedSpecialties,
      notifier.selectedExperience,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('chefs')),
      ),
      body: AnimatedBuilder(
        animation: merged,
        builder: (context, _) {
          final profiles = notifier.profiles.value;
          final isLoading = notifier.isLoading.value;
          final loadingMore = notifier.loadingMore.value;
          final hasMore = notifier.hasMore;
          final horizontal = context.responsiveHorizontal;
          final vertical = context.responsiveVertical;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _controller,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: context.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('chefs_title'),
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.translate('chefs_subtitle'),
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        _CuisineFilterWrap(
                          notifier: notifier,
                          loc: loc,
                          dataService: mock,
                        ),
                        const SizedBox(height: 16),
                        _SpecialtyFilterWrap(
                          notifier: notifier,
                          loc: loc,
                          dataService: mock,
                        ),
                        const SizedBox(height: 16),
                        _ExperienceFilterRow(
                          notifier: notifier,
                          loc: loc,
                          dataService: mock,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            onPressed: notifier.clearFilters,
                            icon: const Icon(Icons.refresh),
                            label: Text(loc.translate('chefs_clear_filters')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading && profiles.isEmpty) ...[
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: SkeletonLoader(
                            height: 200,
                            borderRadius: 32,
                            width: double.infinity,
                          ),
                        ),
                        childCount: 3,
                      ),
                    ),
                  ),
                ] else if (profiles.isEmpty) ...[
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Center(
                        child: EmptyState(
                          title: loc.translate('chefs_empty_title'),
                          subtitle: loc.translate('chefs_empty_subtitle'),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: horizontal,
                      right: horizontal,
                      bottom: vertical,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final chef = profiles[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == profiles.length - 1 ? 0 : 20,
                            ),
                            child: _ChefCard(
                              chef: chef,
                              loc: loc,
                              theme: theme,
                              onTap: () => _showChefDetails(chef),
                            ),
                          );
                        },
                        childCount: profiles.length,
                      ),
                    ),
                  ),
                ],
                if (loadingMore) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ],
                if (!hasMore && profiles.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: vertical, top: 8),
                      child: Center(
                        child: Text(
                          loc.translate('chefs_end_message'),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CuisineFilterWrap extends StatelessWidget {
  const _CuisineFilterWrap({
    required this.notifier,
    required this.loc,
    required this.dataService,
  });

  final ChefsNotifier notifier;
  final AppLocalizations loc;
  final MockDataService dataService;

  @override
  Widget build(BuildContext context) {
    final items = dataService.chefCuisineKeys;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilterChip(
          label: Text(loc.translate('chefs_filter_all_cuisines')),
          selected: notifier.selectedCuisines.value.isEmpty,
          onSelected: (_) => notifier.clearCuisines(),
        ),
        for (final key in items)
          FilterChip(
            label: Text(loc.translate(key)),
            selected: notifier.selectedCuisines.value.contains(key),
            onSelected: (_) => notifier.toggleCuisine(key),
          ),
      ],
    );
  }
}

class _SpecialtyFilterWrap extends StatelessWidget {
  const _SpecialtyFilterWrap({
    required this.notifier,
    required this.loc,
    required this.dataService,
  });

  final ChefsNotifier notifier;
  final AppLocalizations loc;
  final MockDataService dataService;

  @override
  Widget build(BuildContext context) {
    final items = dataService.chefSpecialtyKeys;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilterChip(
          label: Text(loc.translate('chefs_filter_all_specialties')),
          selected: notifier.selectedSpecialties.value.isEmpty,
          onSelected: (_) => notifier.clearSpecialties(),
        ),
        for (final key in items)
          FilterChip(
            label: Text(loc.translate(key)),
            selected: notifier.selectedSpecialties.value.contains(key),
            onSelected: (_) => notifier.toggleSpecialty(key),
          ),
      ],
    );
  }
}

class _ExperienceFilterRow extends StatelessWidget {
  const _ExperienceFilterRow({
    required this.notifier,
    required this.loc,
    required this.dataService,
  });

  final ChefsNotifier notifier;
  final AppLocalizations loc;
  final MockDataService dataService;

  @override
  Widget build(BuildContext context) {
    final thresholds = dataService.chefExperienceThresholds;
    return Wrap(
      spacing: 12,
      children: [
        ChoiceChip(
          label: Text(loc.translate('chefs_experience_filter_all')),
          selected: notifier.selectedExperience.value == null,
          onSelected: (_) => notifier.selectExperience(null),
        ),
        for (final value in thresholds)
          ChoiceChip(
            label: Text(loc.translate('chefs_experience_filter_$value')),
            selected: notifier.selectedExperience.value == value,
            onSelected: (_) => notifier.selectExperience(value),
          ),
      ],
    );
  }
}

class _ChefCard extends StatefulWidget {
  const _ChefCard({
    required this.chef,
    required this.loc,
    required this.theme,
    required this.onTap,
  });

  final ChefProfile chef;
  final AppLocalizations loc;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  State<_ChefCard> createState() => _ChefCardState();
}

class _ChefCardState extends State<_ChefCard> {
  double _tilt = 0;

  void _updateTilt(Offset offset) {
    setState(() {
      _tilt = offset.dx / 120;
    });
  }

  void _resetTilt() {
    setState(() {
      _tilt = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chef = widget.chef;
    final loc = widget.loc;
    final theme = widget.theme;
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: (details) => _updateTilt(details.delta),
      onPanEnd: (_) => _resetTilt(),
      onPanCancel: _resetTilt,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(_tilt * 0.05),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              child: Hero(
                tag: 'chef_${chef.id}',
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    chef.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate(chef.nameKey),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.translate(chef.titleKey),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        IconlyBold.star,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc
                            .translate('chefs_rating_label')
                            .replaceFirst('%s', chef.rating.toStringAsFixed(1)),
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final key in chef.cuisineKeys.take(2))
                        Chip(label: Text(loc.translate(key))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.translate(chef.storyKey),
                    style: theme.textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: widget.onTap,
                      icon: const Icon(IconlyLight.arrow_right_circle),
                      label: Text(loc.translate('chefs_detail_title')),
                    ),
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
