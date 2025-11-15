import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(IconlyLight.info_square, size: 48, color: theme.colorScheme.primary.withOpacity(0.6)),
        const SizedBox(height: 12),
        Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
        ]
      ],
    );
  }
}
