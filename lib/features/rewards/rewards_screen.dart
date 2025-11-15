import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/loyalty_progress_card.dart';
import '../../core/utils/responsive.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key, required this.state});

  static const route = '/rewards';
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final notifier = state.profileNotifier;
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('rewards'))),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          notifier,
          notifier.rewards,
          notifier.loyaltyPoints,
          notifier.loyaltyGoal,
          notifier.loyaltyProgress,
          notifier.tier,
        ]),
        builder: (context, _) {
          if (notifier.isLoading && notifier.rewards.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final points = notifier.loyaltyPoints.value;
          final goal = notifier.loyaltyGoal.value;
          final remaining = points >= goal ? 0 : goal - points;
          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView(
              padding: context.pagePadding,
              children: [
                LoyaltyProgressCard(
                  loc: loc,
                  tier: notifier.tier.value,
                  progress: notifier.loyaltyProgress.value,
                  points: points,
                  goal: goal,
                  heroTag: 'loyalty-card',
                ),
                const SizedBox(height: 20),
                Text(loc.translate('progress_to_next'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  remaining == 0
                      ? loc.translate('milestone_ready')
                      : loc.translate('points_remaining').replaceFirst('%d', remaining.toString()),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          notifier.boostProgress(140);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(loc.translate('boost_ready'))),
                          );
                        },
                        icon: const Icon(Icons.flash_on),
                        label: Text(loc.translate('boost_progress')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: notifier.canClaimMilestone
                            ? () {
                                notifier.claimMilestone();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(loc.translate('milestone_claimed'))),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.celebration),
                        label: Text(loc.translate('claim_reward')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(loc.translate('available_rewards'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ValueListenableBuilder<List<LoyaltyReward>>(
                  valueListenable: notifier.rewards,
                  builder: (context, rewards, __) {
                    return Column(
                      children: [
                        for (final reward in rewards)
                          _RewardTile(
                            reward: reward,
                            onToggle: () {
                              final nextClaimed = !reward.isClaimed;
                              notifier.toggleRewardClaimed(reward.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    nextClaimed
                                        ? loc.translate('reward_unlocked')
                                        : loc.translate('reward_saved'),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.reward, required this.onToggle});

  final LoyaltyReward reward;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(reward.iconUrl, width: 72, height: 72, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(reward.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 10),
                Text('${reward.pointsRequired} ${loc.translate('points')}', style: theme.textTheme.labelMedium),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onToggle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: reward.isClaimed ? theme.colorScheme.secondary : theme.colorScheme.primary,
                    ),
                    child: Text(reward.isClaimed ? loc.translate('claimed') : loc.translate('claim')),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
