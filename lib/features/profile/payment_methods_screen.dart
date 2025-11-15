import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/notifiers.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key, required this.state});

  static const route = '/profile/payments';
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final notifier = state.profileNotifier;
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('payment_methods'))),
      body: AnimatedBuilder(
        animation: Listenable.merge([notifier, notifier.paymentMethods]),
        builder: (context, _) {
          if (notifier.isLoading && notifier.paymentMethods.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ValueListenableBuilder<List<PaymentMethod>>(
                valueListenable: notifier.paymentMethods,
                builder: (context, payments, __) {
                  if (payments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          Icon(Icons.credit_card_off, size: 64, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(loc.translate('empty_state'), style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final payment in payments)
                        _PaymentCard(
                          method: payment,
                          onMakeDefault: () {
                            notifier.setPrimaryPayment(payment.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  loc
                                      .translate('payment_primary_updated')
                                      .replaceFirst('%s', payment.brand),
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
                  notifier.addMockPayment();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.translate('payment_added'))),
                  );
                },
                icon: const Icon(Icons.add_card),
                label: Text(loc.translate('add_payment_method')),
              )
            ],
          );
        },
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.method, required this.onMakeDefault});

  final PaymentMethod method;
  final VoidCallback onMakeDefault;

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
        border: Border.all(
          color: method.isPrimary ? theme.colorScheme.primary.withOpacity(0.35) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: theme.shadowColor.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.brand, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('${loc.translate('ending_in')} ${method.last4}', style: theme.textTheme.bodyMedium),
                    if (method.expiry != '—')
                      Text('${loc.translate('expiry')}: ${method.expiry}', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (method.isPrimary)
                Chip(
                  label: Text(loc.translate('primary_payment')),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                  labelStyle: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: method.isPrimary ? null : onMakeDefault,
              icon: const Icon(Icons.verified_user),
              label: Text(loc.translate('make_default')),
            ),
          )
        ],
      ),
    );
  }
}
