import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/utils/responsive.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const route = '/forgot-password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _controller = TextEditingController();

  void _submit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 48, color: Colors.green),
            const SizedBox(height: 12),
            Text('Check your inbox to reset password', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: context.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loc.translate('forgot_password'), style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 12),
            Text('Enter your email and we will send a reset link.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: loc.translate('email'), prefixIcon: const Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 32),
            PrimaryButton(label: loc.translate('apply'), onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
