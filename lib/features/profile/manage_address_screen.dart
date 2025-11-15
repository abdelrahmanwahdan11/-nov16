import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';
import '../../core/widgets/skeleton_loader.dart';

class ManageAddressScreen extends StatelessWidget {
  const ManageAddressScreen({super.key, required this.state});

  static const route = '/profile/addresses';
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final notifier = state.profileNotifier;

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('manage_address'))),
      body: AnimatedBuilder(
        animation: Listenable.merge([notifier, notifier.addresses]),
        builder: (context, _) {
          if (notifier.isLoading && notifier.addresses.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: notifier.refresh,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                ValueListenableBuilder<List<UserAddress>>(
                  valueListenable: notifier.addresses,
                  builder: (context, addresses, __) {
                    if (addresses.isEmpty) {
                      return Column(
                        children: [
                          const SkeletonLoader(height: 160, borderRadius: 28),
                          const SizedBox(height: 16),
                          Text(
                            loc.translate('empty_state'),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        for (final address in addresses)
                          _AddressCard(
                            address: address,
                            onMakeDefault: () {
                              notifier.setDefaultAddress(address.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    loc
                                        .translate('address_default_updated')
                                        .replaceFirst('%s', address.label),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    notifier.addQuickAddress();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.translate('address_added'))),
                    );
                  },
                  icon: const Icon(Icons.add_location_alt_rounded),
                  label: Text(loc.translate('add_address')),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onMakeDefault});

  final UserAddress address;
  final VoidCallback onMakeDefault;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.cardColor,
        border: Border.all(
          color: address.isDefault ? theme.colorScheme.primary.withOpacity(0.35) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(address.label, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(address.details, style: theme.textTheme.bodyMedium),
                    if (address.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(address.notes, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                    ]
                  ],
                ),
              ),
              if (address.isDefault)
                Chip(
                  label: Text(AppLocalizations.of(context).translate('default')),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: address.isDefault ? null : onMakeDefault,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(AppLocalizations.of(context).translate('set_default')),
            ),
          )
        ],
      ),
    );
  }
}
