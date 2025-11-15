import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/notifiers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.state});

  static const route = '/settings';
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final themeNotifier = state.themeNotifier;
    final localeNotifier = state.localeNotifier;
    final theme = Theme.of(context);
    final primaryOptions = [
      const Color(0xFFFF007A),
      const Color(0xFFFF5722),
      const Color(0xFFFFC107),
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SwitchListTile(
            value: themeNotifier.isDarkMode,
            onChanged: (value) {
              themeNotifier.toggleDarkMode(value);
              themeNotifier.persist(state.prefs);
            },
            title: Text(loc.translate('dark_mode')),
          ),
          const SizedBox(height: 16),
          Text(loc.translate('primary_color'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ValueListenableBuilder<Color>(
            valueListenable: themeNotifier.primaryColorNotifier,
            builder: (context, color, _) {
              return Wrap(
                spacing: 12,
                children: primaryOptions
                    .map(
                      (c) => GestureDetector(
                        onTap: () {
                          themeNotifier.updatePrimary(c);
                          themeNotifier.persist(state.prefs);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: color == c ? Colors.white : Colors.transparent, width: 3),
                            boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 8, spreadRadius: color == c ? 1 : 0)],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(loc.translate('language'), style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Column(
            children: AppLocalizations.supportedLocales
                .map(
                  (locale) => RadioListTile<Locale>(
                    title: Text(locale.languageCode == 'en' ? 'English' : 'العربية'),
                    value: locale,
                    groupValue: localeNotifier.locale,
                    onChanged: (value) {
                      if (value != null) {
                        localeNotifier.switchLocale(value);
                        localeNotifier.persist(state.prefs);
                      }
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          SwitchListTile(value: true, onChanged: (_) {}, title: Text(loc.translate('order_updates'))),
          SwitchListTile(value: false, onChanged: (_) {}, title: Text(loc.translate('offers_promotions'))),
        ],
      ),
    );
  }
}
