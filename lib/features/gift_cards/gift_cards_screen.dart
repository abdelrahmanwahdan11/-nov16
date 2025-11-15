import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/adaptive_page.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/skeleton_loader.dart';

class GiftCardsScreen extends StatefulWidget {
  const GiftCardsScreen({super.key, required this.state});

  static const route = '/gift-cards';
  final AppState state;

  @override
  State<GiftCardsScreen> createState() => _GiftCardsScreenState();
}

class _GiftCardsScreenState extends State<GiftCardsScreen> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 160) {
          widget.state.giftCardsNotifier.loadMore();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await widget.state.giftCardsNotifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final notifier = widget.state.giftCardsNotifier;
    final mock = widget.state.mockDataService;
    final merged = Listenable.merge([
      notifier.cards,
      notifier.isLoading,
      notifier.loadingMore,
      notifier.selectedOccasion,
      notifier.selectedPerks,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('gift_cards')),
      ),
      body: AdaptivePage(
        scrollController: _controller,
        builder: (context, data) {
          return AnimatedBuilder(
            animation: merged,
            builder: (context, _) {
              final cards = notifier.cards.value;
              final isLoading = notifier.isLoading.value;
              final loadingMore = notifier.loadingMore.value;
              final hasMore = notifier.hasMore;

              return RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    data.sliver(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('gift_cards_title'),
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.translate('gift_cards_subtitle'),
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          _OccasionFilterRow(
                            dataService: mock,
                            notifier: notifier,
                            loc: loc,
                          ),
                          const SizedBox(height: 16),
                          _PerkFilterWrap(
                            dataService: mock,
                            notifier: notifier,
                            loc: loc,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    if (isLoading && cards.isEmpty)
                      data.sliver(
                        Column(
                          children: List.generate(
                            3,
                            (index) => const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: SkeletonLoader(height: 160, borderRadius: 28),
                            ),
                          ),
                        ),
                      )
                    else if (cards.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: data.wrap(
                          Center(
                            child: EmptyState(
                              title: loc.translate('gift_cards_empty_title'),
                              subtitle: loc.translate('gift_cards_empty_subtitle'),
                            ),
                          ),
                        ),
                      )
                    else
                      data.sliver(
                        Column(
                          children: [
                            for (var i = 0; i < cards.length; i++)
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: i == cards.length - 1 ? 0 : 20,
                                ),
                                child: i == 0
                                    ? AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 400),
                                        switchInCurve: Curves.easeOut,
                                        switchOutCurve: Curves.easeIn,
                                        child: _GiftCardFeatureCard(
                                          key: ValueKey(cards[i].id),
                                          card: cards[i],
                                          loc: loc,
                                        ),
                                      )
                                    : _GiftCardTile(card: cards[i], loc: loc),
                              ),
                          ],
                        ),
                      ),
                    if (loadingMore)
                      data.sliver(
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 12,
                              bottom: data.verticalPadding,
                            ),
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        withPadding: false,
                      ),
                    if (!hasMore && cards.isNotEmpty)
                      data.sliver(
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 8,
                              bottom: data.verticalPadding,
                            ),
                            child: Text(
                              loc.translate('gift_cards_end_message'),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        withPadding: false,
                      ),
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

class _OccasionFilterRow extends StatelessWidget {
  const _OccasionFilterRow({
    required this.dataService,
    required this.notifier,
    required this.loc,
  });

  final MockDataService dataService;
  final GiftCardsNotifier notifier;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final options = dataService.giftOccasionKeys;
    final theme = Theme.of(context);
    return ValueListenableBuilder<String?>(
      valueListenable: notifier.selectedOccasion,
      builder: (context, selected, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text(loc.translate('gift_cards_filter_all')),
                selected: selected == null,
                onSelected: (_) => notifier.selectOccasion(null),
                backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              const SizedBox(width: 12),
              ...options.map(
                (key) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                  child: ChoiceChip(
                    label: Text(loc.translate(key)),
                    selected: selected == key,
                    onSelected: (_) => notifier.selectOccasion(key),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PerkFilterWrap extends StatelessWidget {
  const _PerkFilterWrap({
    required this.dataService,
    required this.notifier,
    required this.loc,
  });

  final MockDataService dataService;
  final GiftCardsNotifier notifier;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final perks = dataService.giftPerkKeys;
    return ValueListenableBuilder<Set<String>>(
      valueListenable: notifier.selectedPerks,
      builder: (context, selected, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    loc.translate('gift_cards_perks_label'),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: selected.isEmpty ? null : notifier.clearPerks,
                  child: Text(loc.translate('gift_cards_clear_perks')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: perks
                  .map(
                    (key) => FilterChip(
                      label: Text(loc.translate(key)),
                      selected: selected.contains(key),
                      onSelected: (_) => notifier.togglePerk(key),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _GiftCardFeatureCard extends StatelessWidget {
  const _GiftCardFeatureCard({super.key, required this.card, required this.loc});

  final GiftCard card;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = loc.translate('currency_symbol_prefix');
    return Hero(
      tag: 'gift-card-${card.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                card.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutBack,
                        scale: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            '$currency${card.valueAmount}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      loc.translate(card.titleKey),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.translate(card.subtitleKey),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _GiftChip(label: loc.translate(card.occasionKey)),
                        _GiftChip(label: loc.translate(card.deliveryKey)),
                        _GiftChip(label: loc.translate(card.bonusKey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GiftCardTile extends StatelessWidget {
  const _GiftCardTile({required this.card, required this.loc});

  final GiftCard card;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = loc.translate('currency_symbol_prefix');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: 110,
              height: 110,
              child: Image.network(card.imageUrl, fit: BoxFit.cover),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate(card.titleKey),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.translate(card.subtitleKey),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _GiftChip(
                        label: loc.translate(card.bonusKey),
                        subtle: true,
                      ),
                      ...card.perkKeys
                          .take(2)
                          .map(
                            (perk) => _GiftChip(
                              label: loc.translate(perk),
                              subtle: true,
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$currency${card.valueAmount}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(IconlyBold.send, color: theme.colorScheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftChip extends StatelessWidget {
  const _GiftChip({required this.label, this.subtle = false});

  final String label;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = subtle
        ? theme.colorScheme.primary.withOpacity(0.08)
        : theme.colorScheme.primary.withOpacity(0.16);
    final color = subtle
        ? theme.colorScheme.primary
        : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(subtle ? 0.4 : 0.2),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

