import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/utils/responsive.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const route = '/signup';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _obscureConfirm = true;
  final _passwordController = TextEditingController();

  String get _strengthLabel {
    final text = _passwordController.text;
    if (text.length >= 10 && text.contains(RegExp(r'[0-9]')) && text.contains(RegExp(r'[!@#%^&*]'))) {
      return 'Strong';
    }
    if (text.length >= 6) {
      return 'Medium';
    }
    return 'Weak';
  }

  Color get _strengthColor {
    switch (_strengthLabel) {
      case 'Strong':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: context.pagePadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.translate('signup'), style: theme.textTheme.headlineLarge),
              const SizedBox(height: 12),
              Text('Join Foodly and explore premium dishes crafted for you.', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 32),
              TextFormField(
                decoration: InputDecoration(labelText: loc.translate('name'), prefixIcon: const Icon(Icons.person_outline)),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: loc.translate('email'), prefixIcon: const Icon(Icons.email_outlined)),
                validator: (value) => value != null && value.contains('@') ? null : 'Enter valid email',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: loc.translate('phone'), prefixIcon: const Icon(Icons.phone_outlined)),
                validator: (value) => value != null && value.length >= 9 ? null : 'Enter valid phone',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: loc.translate('password'),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? IconlyLight.show : IconlyLight.hide),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (value) => value != null && value.length >= 6 ? null : 'Minimum 6 characters',
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _strengthColor.withOpacity(0.25),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _strengthLabel == 'Strong'
                      ? 1
                      : _strengthLabel == 'Medium'
                          ? 0.6
                          : 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _strengthColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(_strengthLabel, style: theme.textTheme.bodySmall?.copyWith(color: _strengthColor)),
              const SizedBox(height: 16),
              TextFormField(
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_open_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? IconlyLight.show : IconlyLight.hide),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (value) => value == _passwordController.text ? null : 'Password mismatch',
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: loc.translate('signup'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pushReplacementNamed(LoginScreen.route);
                  }
                },
                icon: IconlyBold.login,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
