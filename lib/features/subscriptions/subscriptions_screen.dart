import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/skeleton_loader.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key, required this.state});

  static const route = '/subscriptions';
  final AppState state;

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 160) {
          widget.state.subscriptionsNotifier.loadMore();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await widget.state.subscriptionsNotifier.refresh();
  }

  void _showPlanSheet(SubscriptionPlan plan) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final currency = loc.translate('currency_symbol_prefix');
    final durationLabel =
        loc.translate('subscriptions_duration_weeks').replaceFirst('%d', plan.durationWeeks.toString());
    final priceLabel = loc
        .translate('subscriptions_price_per_week')
        .replaceFirst('%s', '$currency${plan.pricePerWeek.toStringAsFixed(0)}');
    final highlight = plan.highlightKey != null ? loc.translate(plan.highlightKey!) : null;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.translate('subscriptions_sheet_title'),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Hero(
                    tag: 'subscription-${plan.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: AspectRatio(
                        aspectRatio: 3 / 2,
                        child: Image.network(
                          plan.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (highlight != null) ...[
                    Chip(
                      avatar: Icon(
                        IconlyLight.activity,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                      label: Text(
                        highlight,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    loc.translate(plan.titleKey),
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.translate(plan.descriptionKey),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(IconlyLight.time_circle, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(durationLabel, style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      Icon(IconlyLight.wallet, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(priceLabel, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.translate('subscriptions_perks_title'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...plan.perkKeys.map(
                    (perk) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          IconlyLight.star,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        loc.translate(perk),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(IconlyBold.tick_square),
                    label: Text(loc.translate('subscriptions_sheet_cta')),
                  ),
                ],
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
    final notifier = widget.state.subscriptionsNotifier;
    final mock = widget.state.mockDataService;
    final merged = Listenable.merge([
      notifier,
      notifier.plans,
      notifier.isLoading,
      notifier.loadingMore,
      notifier.selectedTag,
      notifier.selectedDuration,
      notifier.selectedPerks,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('subscriptions')),
        actions: [
          TextButton.icon(
            onPressed: notifier.resetAll,
            icon: const Icon(IconlyLight.refresh),
            label: Text(loc.translate('subscriptions_clear_filters')),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: merged,
        builder: (context, _) {
          final plans = notifier.plans.value;
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
                          loc.translate('subscriptions_title'),
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          loc.translate('subscriptions_subtitle'),
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        _TagFilterRow(
                          loc: loc,
                          notifier: notifier,
                          tags: mock.subscriptionTagKeys,
                          selected: notifier.selectedTag.value,
                        ),
                        const SizedBox(height: 16),
                        _DurationFilterRow(
                          notifier: notifier,
                          loc: loc,
                          options: mock.subscriptionDurations,
                          selected: notifier.selectedDuration.value,
                        ),
                        const SizedBox(height: 16),
                        _PerkFilterWrap(
                          notifier: notifier,
                          loc: loc,
                          perks: mock.subscriptionPerkKeys,
                          selected: notifier.selectedPerks.value,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.translate('subscriptions_refresh_hint'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                if (isLoading && plans.isEmpty) ...[
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index.isOdd) {
                            return const SizedBox(height: 20);
                          }
                          return const SkeletonLoader(
                            height: 240,
                            borderRadius: 32,
                          );
                        },
                        childCount: 3 * 2 - 1,
                      ),
                    ),
                  ),
                ] else if (plans.isEmpty) ...[
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Center(
                        child: EmptyState(
                          title: loc.translate('subscriptions_empty_title'),
                          subtitle: loc.translate('subscriptions_empty_subtitle'),
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
                          if (index.isOdd) {
                            return const SizedBox(height: 20);
                          }
                          final plan = plans[index ~/ 2];
                          return _SubscriptionCard(
                            plan: plan,
                            loc: loc,
                            onTap: () => _showPlanSheet(plan),
                          );
                        },
                        childCount: plans.isEmpty ? 0 : plans.length * 2 - 1,
                      ),
                    ),
                  ),
                ],
                if (loadingMore) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: vertical, top: 12),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
                if (!hasMore && plans.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: vertical, top: 8),
                      child: Center(
                        child: Text(
                          loc.translate('subscriptions_refresh_hint'),
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

class _TagFilterRow extends StatelessWidget {
  const _TagFilterRow({
    required this.loc,
    required this.notifier,
    required this.tags,
    required this.selected,
  });

  final AppLocalizations loc;
  final SubscriptionsNotifier notifier;
  final List<String> tags;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TagChip(
            label: loc.translate('subscriptions_filter_all'),
            selected: selected == null,
            onSelected: () => notifier.selectTag(null),
            theme: theme,
          ),
          const SizedBox(width: 12),
          ...tags.map(
            (tag) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 12),
              child: _TagChip(
                label: loc.translate(tag),
                selected: selected == tag,
                onSelected: () => notifier.selectTag(tag),
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: theme.colorScheme.primary.withOpacity(0.16),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: selected ? theme.colorScheme.primary : theme.textTheme.labelLarge?.color,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _DurationFilterRow extends StatelessWidget {
  const _DurationFilterRow({
    required this.notifier,
    required this.loc,
    required this.options,
    required this.selected,
  });

  final SubscriptionsNotifier notifier;
  final AppLocalizations loc;
  final List<int> options;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options
          .map(
            (weeks) => FilterChip(
              label: Text(
                loc.translate('subscriptions_duration_weeks').replaceFirst('%d', weeks.toString()),
              ),
              selected: selected == weeks,
              onSelected: (value) => notifier.selectDuration(value ? weeks : null),
              selectedColor: theme.colorScheme.secondaryContainer.withOpacity(0.28),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          )
          .toList(),
    );
  }
}

class _PerkFilterWrap extends StatelessWidget {
  const _PerkFilterWrap({
    required this.notifier,
    required this.loc,
    required this.perks,
    required this.selected,
  });

  final SubscriptionsNotifier notifier;
  final AppLocalizations loc;
  final List<String> perks;
  final Set<String> selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: perks
          .map(
            (perk) => FilterChip(
              label: Text(loc.translate(perk)),
              selected: selected.contains(perk),
              onSelected: (_) => notifier.togglePerk(perk),
              selectedColor: theme.colorScheme.primary.withOpacity(0.14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          )
          .toList(),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.plan, required this.loc, required this.onTap});

  final SubscriptionPlan plan;
  final AppLocalizations loc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final currency = loc.translate('currency_symbol_prefix');
    final priceLabel =
        loc.translate('subscriptions_price_per_week').replaceFirst('%s', '$currency${plan.pricePerWeek.toStringAsFixed(0)}');
    final durationLabel =
        loc.translate('subscriptions_duration_weeks').replaceFirst('%d', plan.durationWeeks.toString());
    final highlight = plan.highlightKey != null ? loc.translate(plan.highlightKey!) : null;

    final child = _SubscriptionCardBody(
      plan: plan,
      loc: loc,
      onTap: onTap,
      priceLabel: priceLabel,
      durationLabel: durationLabel,
      highlight: highlight,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
    );
  }
}

class _SubscriptionCardBody extends StatelessWidget {
  const _SubscriptionCardBody({
    required this.plan,
    required this.loc,
    required this.onTap,
    required this.priceLabel,
    required this.durationLabel,
    required this.highlight,
  });

  final SubscriptionPlan plan;
  final AppLocalizations loc;
  final VoidCallback onTap;
  final String priceLabel;
  final String durationLabel;
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'subscription-${plan.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Image.network(
                    plan.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedOpacity(
                    opacity: highlight == null ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    child: highlight == null
                        ? const SizedBox.shrink()
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              highlight!,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                  if (highlight != null) const SizedBox(height: 12),
                  Text(
                    loc.translate(plan.titleKey),
                    style: theme.textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.translate(plan.descriptionKey),
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.22),
                        avatar: const Icon(IconlyLight.category, size: 18),
                        label: Text(loc.translate(plan.tagKey)),
                      ),
                      Chip(
                        avatar: const Icon(IconlyLight.time_circle, size: 18),
                        label: Text(durationLabel),
                      ),
                      Chip(
                        avatar: const Icon(IconlyLight.wallet, size: 18),
                        label: Text(priceLabel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: plan.perkKeys
                        .map(
                          (perk) => _SubscriptionPerkChip(
                            label: loc.translate(perk),
                            theme: theme,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        loc.translate('subscriptions_explore_cta'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        IconlyLight.arrow_right,
                        color: theme.colorScheme.primary,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onTap,
                        icon: const Icon(IconlyLight.info_circle),
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

class _SubscriptionPerkChip extends StatelessWidget {
  const _SubscriptionPerkChip({required this.label, required this.theme});

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium,
      ),
    );
  }
}
