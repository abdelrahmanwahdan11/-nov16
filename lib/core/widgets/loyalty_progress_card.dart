import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class LoyaltyProgressCard extends StatelessWidget {
  const LoyaltyProgressCard({
    super.key,
    required this.loc,
    required this.tier,
    required this.progress,
    required this.points,
    required this.goal,
    this.heroTag,
    this.onTap,
  });

  final AppLocalizations loc;
  final String tier;
  final double progress;
  final int points;
  final int goal;
  final String? heroTag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = progress.clamp(0.0, 1.0);
    final percent = (ratio * 100).round();

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 14),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('rewards'),
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            tier,
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: ratio,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${loc.translate('points_earned')}: $points/$goal',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('$percent%', style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(loc.translate('view_rewards'), style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                ],
              ),
            ),
          )
        ],
      ),
    );

    if (heroTag != null) {
      card = Hero(tag: heroTag!, child: Material(type: MaterialType.transparency, child: card));
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}
