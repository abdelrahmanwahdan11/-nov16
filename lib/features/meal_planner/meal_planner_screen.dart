import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/skeleton_loader.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key, required this.state});

  static const route = '/meal-planner';
  final AppState state;

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = widget.state.mealPlannerNotifier;
      if (!notifier.isLoading && notifier.days.value.isEmpty) {
        notifier.loadPlan();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final notifier = widget.state.mealPlannerNotifier;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('meal_planner')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: loc.translate('rotate_plan'),
            onPressed: notifier.isLoading
                ? null
                : () {
                    notifier.rotatePlan();
                    if (_pageController.hasClients) {
                      _pageController.jumpToPage(0);
                    }
                  },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          notifier,
          notifier.days,
          notifier.activeDayIndex,
          notifier.preparedMeals,
          notifier.autoPilot,
        ]),
        builder: (context, _) {
          final days = notifier.days.value;
          if (notifier.isLoading && days.isEmpty) {
            return _MealPlannerSkeleton(padding: context.pagePadding);
          }

          if (days.isEmpty) {
            return Center(child: Text(loc.translate('empty_meal_plan')));
          }

          final activeIndex = notifier.activeDayIndex.value.clamp(0, days.length - 1);
          final pageHeight = context.responsiveValue(360, 430, 520);

          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView(
              padding: context.pagePadding,
              children: [
                _AutoPilotCard(notifier: notifier, loc: loc),
                const SizedBox(height: 24),
                Text(
                  loc.translate('weekly_focus'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _DaySelector(
                  days: days,
                  activeIndex: activeIndex,
                  onSelected: (index) {
                    if (index == activeIndex) return;
                    notifier.goToDay(index);
                    if (_pageController.hasClients) {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  loc: loc,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: pageHeight,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: notifier.goToDay,
                    itemCount: days.length,
                    itemBuilder: (context, index) {
                      final day = days[index];
                      final prepared = notifier.preparedMeals.value;
                      return _DayCard(
                        day: day,
                        loc: loc,
                        prepared: prepared,
                        onToggle: notifier.togglePrepared,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AutoPilotCard extends StatelessWidget {
  const _AutoPilotCard({required this.notifier, required this.loc});

  final MealPlannerNotifier notifier;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.colorScheme.primaryContainer.withOpacity(theme.brightness == Brightness.dark ? 0.4 : 0.8),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withOpacity(0.18), blurRadius: 30, offset: const Offset(0, 18)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.translate('auto_pilot'), style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
                const SizedBox(height: 6),
                Text(
                  loc.translate('auto_pilot_subtitle'),
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer.withOpacity(0.76)),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: notifier.autoPilot,
            builder: (context, enabled, _) {
              return Switch(
                value: enabled,
                onChanged: notifier.toggleAutoPilot,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.days,
    required this.activeIndex,
    required this.onSelected,
    required this.loc,
  });

  final List<MealPlanDay> days;
  final int activeIndex;
  final ValueChanged<int> onSelected;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++)
            Padding(
              padding: EdgeInsetsDirectional.only(end: i == days.length - 1 ? 0 : 12),
              child: ChoiceChip(
                label: Text(loc.translate(days[i].day)),
                selected: i == activeIndex,
                onSelected: (_) => onSelected(i),
                avatar: days[i].isPrepDay ? const Icon(IconlyBold.calendar) : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.loc,
    required this.prepared,
    required this.onToggle,
  });

  final MealPlanDay day;
  final AppLocalizations loc;
  final Set<String> prepared;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: theme.shadowColor.withOpacity(0.08), blurRadius: 30, offset: const Offset(0, 18)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(loc.translate(day.day), style: theme.textTheme.titleLarge),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.colorScheme.primary.withOpacity(0.12),
                    ),
                    child: Text(
                      loc.translate(day.focusKey),
                      style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                loc.translate(day.tipKey),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(IconlyLight.time_circle, size: 18),
                  const SizedBox(width: 8),
                  Text(loc.translate('daily_calories').replaceFirst('%d', day.totalCalories.toString())),
                  const Spacer(),
                  if (day.isPrepDay)
                    Chip(
                      label: Text(loc.translate('prep_day')),
                      backgroundColor: theme.colorScheme.secondary.withOpacity(0.16),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = day.items[index];
                    final isPrepared = prepared.contains(item.id);
                    return _MealTile(
                      item: item,
                      loc: loc,
                      prepared: isPrepared,
                      onToggle: onToggle,
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemCount: day.items.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({
    required this.item,
    required this.loc,
    required this.prepared,
    required this.onToggle,
  });

  final FoodItem item;
  final AppLocalizations loc;
  final bool prepared;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: prepared ? theme.colorScheme.primary.withOpacity(0.12) : theme.colorScheme.surfaceVariant.withOpacity(0.32),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(item.imageUrl, width: 68, height: 68, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(IconlyBold.time_circle, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text('${item.deliveryTime} ${loc.translate('minutes_delivery')}'),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          Checkbox(
            value: prepared,
            onChanged: (_) => onToggle(item.id),
          ),
        ],
      ),
    );
  }
}

class _MealPlannerSkeleton extends StatelessWidget {
  const _MealPlannerSkeleton({required this.padding});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: const [
        SkeletonLoader(height: 140, borderRadius: 28),
        SizedBox(height: 24),
        SkeletonLoader(height: 48, borderRadius: 16),
        SizedBox(height: 16),
        SkeletonLoader(height: 320, borderRadius: 28),
      ],
    );
  }
}
