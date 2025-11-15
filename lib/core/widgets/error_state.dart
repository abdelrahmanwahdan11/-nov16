import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(IconlyBold.danger, size: 52, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(message, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ]
      ],
    );
  }
}
