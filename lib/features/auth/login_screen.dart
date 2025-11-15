import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/services/notifiers.dart';
import '../shell/shell_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../core/utils/responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = true;
  bool _obscure = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final state = AppStateScope.of(context, listen: false);
    Navigator.of(context).pushReplacementNamed(ShellScreen.route, arguments: state);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: AnimatedPadding(
        duration: const Duration(milliseconds: 400),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: context.pagePadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.translate('login'), style: theme.textTheme.headlineLarge),
                const SizedBox(height: 12),
                Text('Welcome back! Discover new tastes today.', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 32),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: 1,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: loc.translate('email'),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) => value != null && value.contains('@') ? null : 'Enter valid email',
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSlide(
                  duration: const Duration(milliseconds: 400),
                  offset: const Offset(0, 0),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
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
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(value: _rememberMe, onChanged: (value) => setState(() => _rememberMe = value ?? false)),
                    Text(loc.translate('remember_me')),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed(ForgotPasswordScreen.route),
                      child: Text(loc.translate('forgot_password')),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(label: loc.translate('login'), onPressed: _submit, icon: IconlyBold.login),
                const SizedBox(height: 16),
                SecondaryButton(
                  label: loc.translate('signup'),
                  onPressed: () => Navigator.of(context).pushNamed(SignUpScreen.route),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    final state = AppStateScope.of(context, listen: false);
                    Navigator.of(context).pushReplacementNamed(ShellScreen.route, arguments: state);
                  },
                  child: Text(loc.translate('guest_login')),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
