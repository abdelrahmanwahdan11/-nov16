import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/skeleton_loader.dart';

class CateringScreen extends StatefulWidget {
  const CateringScreen({super.key, required this.state});

  static const route = '/catering';
  final AppState state;

  @override
  State<CateringScreen> createState() => _CateringScreenState();
}

class _CateringScreenState extends State<CateringScreen> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 160) {
          widget.state.cateringNotifier.loadMore();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await widget.state.cateringNotifier.refresh();
  }

  void _showPackageDetails(CateringPackage package) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final price = package.pricePerGuest.toStringAsFixed(0);
    final rating = package.rating.toStringAsFixed(1);
    final priceLabel =
        loc.translate('catering_price_from').replaceFirst('%s', price);
    final ratingLabel =
        loc.translate('catering_rating_label').replaceFirst('%s', rating);
    final guestRange = '${package.minGuests}-${package.maxGuests}';
    final guestLabel =
        loc.translate('catering_guest_range').replaceFirst('%s', guestRange);
    final leadLabel =
        loc.translate('catering_lead_time').replaceFirst('%d', package.leadTimeDays.toString());

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.6,
          maxChildSize: 0.92,
          builder: (context, controller) {
            return ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: ListView(
                controller: controller,
                padding: EdgeInsets.only(
                  left: context.responsiveHorizontal,
                  right: context.responsiveHorizontal,
                  top: 24,
                  bottom: context.responsiveVertical + 16,
                ),
                children: [
                  Hero(
                    tag: 'catering_${package.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          package.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.translate(package.titleKey),
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.translate(package.subtitleKey),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _DetailChip(
                        icon: IconlyLight.ticket,
                        label: priceLabel,
                      ),
                      _DetailChip(
                        icon: IconlyLight.star,
                        label: ratingLabel,
                      ),
                      _DetailChip(
                        icon: IconlyLight.user,
                        label: guestLabel,
                      ),
                      _DetailChip(
                        icon: IconlyLight.time_circle,
                        label: leadLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.translate('catering_modal_highlights'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: package.highlightKeys
                        .map((key) => Chip(
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.12),
                              label: Text(
                                loc.translate(key),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.translate('catering_modal_cuisines'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: package.cuisineKeys
                        .map((key) => Chip(
                              label: Text(loc.translate(key)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(loc.translate('catering_modal_cta')),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(loc.translate('catering_modal_secondary')),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    loc.translate('catering_modal_note'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.72),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notifier = widget.state.cateringNotifier;
    final mock = widget.state.mockDataService;
    final animation = Listenable.merge([
      notifier.packages,
      notifier.isLoading,
      notifier.loadingMore,
      notifier.selectedOccasion,
      notifier.selectedCuisine,
      notifier.selectedServiceStyle,
      notifier.selectedHeadcount,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('catering')),
      ),
      body: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final packages = notifier.packages.value;
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
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      vertical,
                      horizontal,
                      16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('catering_title'),
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.translate('catering_subtitle'),
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        _OccasionFilterRow(
                          loc: loc,
                          dataService: mock,
                          selected: notifier.selectedOccasion.value,
                          onSelected: notifier.selectOccasion,
                        ),
                        const SizedBox(height: 16),
                        _CuisineFilterWrap(
                          loc: loc,
                          dataService: mock,
                          selected: notifier.selectedCuisine.value,
                          onSelected: notifier.selectCuisine,
                        ),
                        const SizedBox(height: 16),
                        _ServiceHeadcountSection(
                          loc: loc,
                          dataService: mock,
                          selectedService: notifier.selectedServiceStyle.value,
                          selectedHeadcount: notifier.selectedHeadcount.value,
                          onServiceSelected: notifier.selectServiceStyle,
                          onHeadcountSelected: notifier.selectHeadcount,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton.icon(
                            onPressed: notifier.selectedOccasion.value == null &&
                                    notifier.selectedCuisine.value == null &&
                                    notifier.selectedServiceStyle.value == null &&
                                    notifier.selectedHeadcount.value == null
                                ? null
                                : notifier.clearFilters,
                            icon: const Icon(Icons.refresh),
                            label: Text(loc.translate('catering_clear_filters')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading && packages.isEmpty) ...[
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 18),
                          child: SkeletonLoader(
                            height: 200,
                            borderRadius: 28,
                          ),
                        ),
                        childCount: 3,
                      ),
                    ),
                  ),
                ] else if (packages.isEmpty) ...[
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Center(
                        child: EmptyState(
                          title: loc.translate('catering_empty_title'),
                          subtitle: loc.translate('catering_empty_subtitle'),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      0,
                      horizontal,
                      vertical,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final package = packages[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == packages.length - 1 ? 0 : 20,
                            ),
                            child: _CateringPackageCard(
                              package: package,
                              loc: loc,
                              onTap: () => _showPackageDetails(package),
                            ),
                          );
                        },
                        childCount: packages.length,
                      ),
                    ),
                  ),
                ],
                if (loadingMore) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: vertical, top: 12),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ],
                if (!hasMore && packages.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: vertical,
                        top: 8,
                      ),
                      child: Center(
                        child: Text(
                          loc.translate('catering_end_message'),
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

class _OccasionFilterRow extends StatelessWidget {
  const _OccasionFilterRow({
    required this.loc,
    required this.dataService,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations loc;
  final MockDataService dataService;
  final String? selected;
  final void Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    final occasions = dataService.cateringOccasionKeys;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: Text(loc.translate('catering_filter_all_occasions')),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 12),
          ...occasions.map(
            (key) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ChoiceChip(
                label: Text(loc.translate(key)),
                selected: selected == key,
                onSelected: (_) => onSelected(key),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CuisineFilterWrap extends StatelessWidget {
  const _CuisineFilterWrap({
    required this.loc,
    required this.dataService,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations loc;
  final MockDataService dataService;
  final String? selected;
  final void Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    final cuisines = dataService.cateringCuisineKeys;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('catering_filter_all_cuisines'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cuisines
              .map(
                (key) => FilterChip(
                  label: Text(loc.translate(key)),
                  selected: selected == key,
                  onSelected: (_) => onSelected(key),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ServiceHeadcountSection extends StatelessWidget {
  const _ServiceHeadcountSection({
    required this.loc,
    required this.dataService,
    required this.selectedService,
    required this.selectedHeadcount,
    required this.onServiceSelected,
    required this.onHeadcountSelected,
  });

  final AppLocalizations loc;
  final MockDataService dataService;
  final String? selectedService;
  final String? selectedHeadcount;
  final void Function(String?) onServiceSelected;
  final void Function(String?) onHeadcountSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final services = dataService.cateringServiceStyleKeys;
    final headcounts = dataService.cateringHeadcountRanges.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(IconlyLight.discovery, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(loc.translate('catering_service_label'),
                style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: services
              .map(
                (key) => ChoiceChip(
                  label: Text(loc.translate(key)),
                  selected: selectedService == key,
                  onSelected: (_) => onServiceSelected(key),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(IconlyLight.user, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(loc.translate('catering_headcount_label'),
                style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: headcounts
              .map(
                (key) => ChoiceChip(
                  label: Text(loc.translate(key)),
                  selected: selectedHeadcount == key,
                  onSelected: (_) => onHeadcountSelected(key),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _CateringPackageCard extends StatelessWidget {
  const _CateringPackageCard({
    required this.package,
    required this.loc,
    required this.onTap,
  });

  final CateringPackage package;
  final AppLocalizations loc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = package.pricePerGuest.toStringAsFixed(0);
    final priceLabel =
        loc.translate('catering_price_from').replaceFirst('%s', price);
    final rating = package.rating.toStringAsFixed(1);
    final ratingLabel =
        loc.translate('catering_rating_label').replaceFirst('%s', rating);
    final guestRange = '${package.minGuests}-${package.maxGuests}';
    final guestLabel =
        loc.translate('catering_guest_range').replaceFirst('%s', guestRange);

    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'catering_${package.id}',
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.08),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      package.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              loc.translate(package.titleKey),
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(IconlyLight.arrow_right_2,
                              color: theme.colorScheme.primary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.translate(package.subtitleKey),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _DetailChip(
                            icon: IconlyLight.ticket,
                            label: priceLabel,
                          ),
                          _DetailChip(
                            icon: IconlyLight.star,
                            label: ratingLabel,
                          ),
                          _DetailChip(
                            icon: IconlyLight.user,
                            label: guestLabel,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: package.highlightKeys
                            .take(3)
                            .map(
                              (key) => Chip(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                backgroundColor:
                                    theme.colorScheme.primary.withOpacity(0.08),
                                label: Text(
                                  loc.translate(key),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
