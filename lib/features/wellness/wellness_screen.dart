import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/skeleton_loader.dart';

class WellnessScreen extends StatefulWidget {
  const WellnessScreen({super.key, required this.state});

  static const route = '/wellness';

  final AppState state;

  @override
  State<WellnessScreen> createState() => _WellnessScreenState();
}

class _WellnessScreenState extends State<WellnessScreen> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 160) {
          widget.state.wellnessNotifier.loadMore();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await widget.state.wellnessNotifier.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final notifier = widget.state.wellnessNotifier;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('wellness')),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              notifier,
              notifier.programs,
              notifier.isLoading,
              notifier.loadingMore,
              notifier.selectedFocus,
            ]),
            builder: (context, _) {
              final programs = notifier.programs.value;
              final isLoading = notifier.isLoading.value;

              return CustomScrollView(
                controller: _controller,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate('wellness_title'),
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.translate('wellness_subtitle'),
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loc.translate('wellness_refresh_hint'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _FocusFilterChips(
                      focusKeys: notifier.focusKeys,
                      selected: notifier.selectedFocus.value,
                      onSelected: notifier.selectFocus,
                      loc: loc,
                    ),
                  ),
                  if (isLoading && programs.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          children: const [
                            SkeletonLoader(height: 220, borderRadius: 28),
                            SizedBox(height: 16),
                            SkeletonLoader(height: 220, borderRadius: 28),
                          ],
                        ),
                      ),
                    )
                  else if (programs.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: EmptyState(
                          title: loc.translate('wellness_empty_title'),
                          subtitle: loc.translate('wellness_empty_subtitle'),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final program = programs[index];
                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              index == 0 ? 16 : 0,
                              24,
                              16,
                            ),
                            child: _WellnessProgramCard(
                              program: program,
                              loc: loc,
                              onTap: () => _openProgramSheet(program),
                            ),
                          );
                        },
                        childCount: programs.length,
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: AnimatedOpacity(
                      opacity: notifier.loadingMore.value && programs.isNotEmpty
                          ? 1
                          : 0,
                      duration: const Duration(milliseconds: 240),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 32),
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
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      child: Text(
                        loc.translate('wellness_end_message'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openProgramSheet(WellnessProgram program) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final durationLabel = loc
        .translate('wellness_duration_days')
        .replaceFirst('%d', program.durationDays.toString());
    final hydrationLabel = loc
        .translate('wellness_metric_hydration')
        .replaceFirst('%d', program.hydrationGlasses.toString());
    final focusLabel = loc
        .translate('wellness_metric_focus')
        .replaceFirst('%d', program.mindfulnessMinutes.toString());
    final sleepLabel = loc
        .translate('wellness_metric_sleep')
        .replaceFirst('%d', program.sleepHours.toString());

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                    loc.translate('wellness_sheet_title'),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Hero(
                    tag: 'wellness-${program.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: AspectRatio(
                        aspectRatio: 3 / 2,
                        child: Image.network(
                          program.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(
                          IconlyLight.heart,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        backgroundColor:
                            theme.colorScheme.primary.withOpacity(0.12),
                        label: Text(
                          loc.translate(program.focusKey),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Chip(
                        avatar: Icon(
                          IconlyLight.time_circle,
                          size: 18,
                          color: theme.colorScheme.secondary,
                        ),
                        backgroundColor:
                            theme.colorScheme.secondary.withOpacity(0.12),
                        label: Text(
                          durationLabel,
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.translate(program.titleKey),
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.translate(program.subtitleKey),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.translate('wellness_benefits_title'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ...program.benefitKeys.map(
                    (benefit) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          IconlyLight.activity,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(loc.translate(benefit)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.translate('wellness_metrics_title'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricPill(
                        icon: IconlyLight.tick_square,
                        label: hydrationLabel,
                      ),
                      _MetricPill(
                        icon: IconlyLight.activity,
                        label: focusLabel,
                      ),
                      _MetricPill(
                        icon: IconlyLight.moon,
                        label: sleepLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: loc.translate('wellness_sheet_cta'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FocusFilterChips extends StatelessWidget {
  const _FocusFilterChips({
    required this.focusKeys,
    required this.selected,
    required this.onSelected,
    required this.loc,
  });

  final List<String> focusKeys;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = <String?>[null, ...focusKeys];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((key) {
          final bool isSelected = selected == key || (key == null && selected == null);
          final label =
              key == null ? loc.translate('wellness_focus_all') : loc.translate(key);
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onSelected(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? IconlyBold.heart : IconlyLight.heart,
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.textTheme.labelLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WellnessProgramCard extends StatelessWidget {
  const _WellnessProgramCard({
    required this.program,
    required this.loc,
    required this.onTap,
  });

  final WellnessProgram program;
  final AppLocalizations loc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final durationLabel = loc
        .translate('wellness_duration_days')
        .replaceFirst('%d', program.durationDays.toString());
    final hydrationLabel = loc
        .translate('wellness_metric_hydration')
        .replaceFirst('%d', program.hydrationGlasses.toString());
    final focusLabel = loc
        .translate('wellness_metric_focus')
        .replaceFirst('%d', program.mindfulnessMinutes.toString());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'wellness-${program.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        program.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        loc.translate(program.focusKey),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          IconlyLight.time_circle,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          durationLabel,
                          style: theme.textTheme.labelMedium,
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  loc.translate(program.titleKey),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.translate(program.subtitleKey),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: program.benefitKeys
                      .take(3)
                      .map((benefit) => _BenefitChip(
                            label: loc.translate(benefit),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(
                      IconlyLight.activity,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hydrationLabel,
                      style: theme.textTheme.labelMedium,
                    ),
                    const Spacer(),
                    Icon(
                      IconlyLight.heart,
                      size: 18,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      focusLabel,
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  const _BenefitChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
