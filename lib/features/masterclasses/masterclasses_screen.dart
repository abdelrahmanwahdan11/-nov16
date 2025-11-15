import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/adaptive_page.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/skeleton_loader.dart';

class MasterclassesScreen extends StatefulWidget {
  const MasterclassesScreen({super.key, required this.state});

  static const route = '/masterclasses';

  final AppState state;

  @override
  State<MasterclassesScreen> createState() => _MasterclassesScreenState();
}

class _MasterclassesScreenState extends State<MasterclassesScreen> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 160) {
          widget.state.masterclassesNotifier.loadMore();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() => widget.state.masterclassesNotifier.refresh();

  void _openMasterclassSheet(Masterclass masterclass, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.92,
          initialChildSize: 0.86,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Hero(
                    tag: masterclass.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Image.network(
                          masterclass.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.translate(masterclass.titleKey),
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.translate(masterclass.subtitleKey),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(IconlyLight.time_circle,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        loc
                            .translate('masterclasses_duration_label')
                            .replaceFirst('%d',
                                masterclass.durationMinutes.toString()),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      Icon(IconlyLight.calendar,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          loc.translate(masterclass.scheduleKey),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.translate('masterclasses_modal_overview'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: masterclass.highlightKeys
                        .map(
                          (key) => Chip(
                            label: Text(loc.translate(key)),
                            backgroundColor: theme
                                .colorScheme.primary
                                .withOpacity(0.08),
                            labelStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.translate('masterclasses_modal_takeaways'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...masterclass.takeawayKeys.map(
                    (key) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.translate(key),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.translate('masterclasses_modal_requirements'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...masterclass.requirementKeys.map(
                    (key) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(IconlyLight.work,
                              size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.translate(key),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.translate('masterclasses_modal_instructor'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant
                          .withOpacity(theme.brightness == Brightness.dark
                              ? 0.35
                              : 0.6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.12),
                              child: Icon(IconlyBold.user,
                                  color: theme.colorScheme.primary),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loc.translate(masterclass.instructorKey),
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    loc.translate(masterclass.instructorStoryKey),
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: loc.translate('masterclasses_modal_cta'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(IconlyLight.send),
                    label: Text(loc.translate('masterclasses_modal_secondary')),
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
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final notifier = widget.state.masterclassesNotifier;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('masterclasses')),
        actions: [
          AnimatedBuilder(
            animation: Listenable.merge([
              notifier.selectedLevel,
              notifier.selectedCuisine,
              notifier.selectedFormat,
            ]),
            builder: (context, _) {
              final hasFilters = notifier.selectedLevel.value != null ||
                  notifier.selectedCuisine.value != null ||
                  notifier.selectedFormat.value != null;
              if (!hasFilters) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: notifier.clearFilters,
                child: Text(loc.translate('catering_clear_filters')),
              );
            },
          ),
        ],
      ),
      body: AdaptivePage(
        scrollController: _controller,
        builder: (context, data) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                notifier,
                notifier.classes,
                notifier.isLoading,
                notifier.loadingMore,
                notifier.selectedLevel,
                notifier.selectedCuisine,
                notifier.selectedFormat,
              ]),
              builder: (context, _) {
                final items = notifier.classes.value;
                final isLoading = notifier.isLoading.value;

                return CustomScrollView(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    data.sliver(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('masterclasses_title'),
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.translate('masterclasses_subtitle'),
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loc.translate('masterclasses_home_subtitle'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    data.sliver(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FilterRow(
                            label: loc.translate('masterclasses_filter_all_levels'),
                            keys: notifier.levelKeys,
                            selected: notifier.selectedLevel.value,
                            onSelected: notifier.selectLevel,
                            loc: loc,
                          ),
                          const SizedBox(height: 12),
                          _FilterRow(
                            label: loc.translate('masterclasses_filter_all_cuisines'),
                            keys: notifier.cuisineKeys,
                            selected: notifier.selectedCuisine.value,
                            onSelected: notifier.selectCuisine,
                            loc: loc,
                          ),
                          const SizedBox(height: 12),
                          _FilterRow(
                            label: loc.translate('masterclasses_filter_all_formats'),
                            keys: notifier.formatKeys,
                            selected: notifier.selectedFormat.value,
                            onSelected: notifier.selectFormat,
                            loc: loc,
                          ),
                        ],
                      ),
                    ),
                    if (isLoading && items.isEmpty)
                      data.sliver(
                        Column(
                          children: const [
                            SkeletonLoader(height: 220, borderRadius: 28),
                            SizedBox(height: 16),
                            SkeletonLoader(height: 220, borderRadius: 28),
                          ],
                        ),
                      )
                    else if (items.isEmpty)
                      data.sliver(
                        EmptyState(
                          title: loc.translate('masterclasses_empty_title'),
                          subtitle: loc.translate('masterclasses_empty_subtitle'),
                        ),
                      )
                    else
                      data.sliver(
                        Column(
                          children: [
                            for (var i = 0; i < items.length; i++)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: i == 0 ? 24 : 12,
                                  bottom: 12,
                                ),
                                child: _MasterclassCard(
                                  masterclass: items[i],
                                  loc: loc,
                                  onTap: () => _openMasterclassSheet(items[i], loc),
                                ),
                              ),
                          ],
                        ),
                      ),
                    data.sliver(
                      AnimatedOpacity(
                        opacity: notifier.loadingMore.value && items.isNotEmpty ? 1 : 0,
                        duration: const Duration(milliseconds: 240),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 32, top: 16),
                          child: Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      withPadding: false,
                    ),
                    data.sliver(
                      Padding(
                        padding: EdgeInsets.only(bottom: data.verticalPadding + 12),
                        child: Text(
                          loc.translate('masterclasses_end_message'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.label,
    required this.keys,
    required this.selected,
    required this.onSelected,
    required this.loc,
  });

  final String label;
  final List<String> keys;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: keys
              .map(
                (key) => FilterChip(
                  label: Text(loc.translate(key)),
                  selected: selected == key,
                  onSelected: (_) => onSelected(key),
                  backgroundColor: theme.colorScheme.surfaceVariant
                      .withOpacity(theme.brightness == Brightness.dark ? 0.25 : 0.6),
                  selectedColor: theme.colorScheme.primary.withOpacity(0.16),
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: selected == key
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight: selected == key ? FontWeight.w600 : null,
                  ),
                  showCheckmark: false,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MasterclassCard extends StatefulWidget {
  const _MasterclassCard({
    required this.masterclass,
    required this.loc,
    required this.onTap,
  });

  final Masterclass masterclass;
  final AppLocalizations loc;
  final VoidCallback onTap;

  @override
  State<_MasterclassCard> createState() => _MasterclassCardState();
}

class _MasterclassCardState extends State<_MasterclassCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classItem = widget.masterclass;
    final loc = widget.loc;
    final levelLabel = loc.translate(classItem.levelKey);
    final cuisineLabel = loc.translate(classItem.cuisineKey);
    final formatLabel = loc.translate(classItem.formatKey);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: _pressed ? 8 : 18,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Hero(
                  tag: classItem.id,
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      classItem.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: Chip(
                    label: Text(levelLabel),
                    backgroundColor:
                        Theme.of(context).colorScheme.surface.withOpacity(0.72),
                    labelStyle: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  right: 18,
                  child: Chip(
                    avatar: Icon(
                      IconlyLight.discovery,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(formatLabel),
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.16),
                    labelStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 18,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.translate(classItem.titleKey),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.translate(classItem.scheduleKey),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Wrap(
                          key: ValueKey(classItem.availableSpots),
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _InfoPill(
                              icon: IconlyLight.shield_done,
                              label: cuisineLabel,
                            ),
                            _InfoPill(
                              icon: IconlyLight.time_circle,
                              label: loc
                                  .translate('masterclasses_duration_label')
                                  .replaceFirst('%d',
                                      classItem.durationMinutes.toString()),
                            ),
                            _InfoPill(
                              icon: IconlyLight.activity,
                              label: loc
                                  .translate('masterclasses_spots_label')
                                  .replaceFirst('%d',
                                      classItem.availableSpots.toString()),
                            ),
                          ],
                        ),
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

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
