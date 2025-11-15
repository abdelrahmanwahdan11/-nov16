import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/services/notifiers.dart';
import '../../core/utils/responsive.dart';
import '../auth/login_screen.dart';
import '../shell/shell_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const route = '/';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _page = 0;

  final List<Map<String, String>> _slides = [
    {
      'image': 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=900&q=80',
      'title': 'Delight in Every Bite',
      'subtitle': 'Discover curated meals crafted for your cravings.'
    },
    {
      'image': 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=900&q=80',
      'title': 'Fresh & Fast Delivery',
      'subtitle': 'Track your courier and enjoy 24/7 support.'
    },
    {
      'image': 'https://images.unsplash.com/photo-1600891964092-4316c288032e?auto=format&fit=crop&w=900&q=80',
      'title': 'Personalized For You',
      'subtitle': 'Smart recommendations and AI insights coming soon.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_controller.hasClients) return;
      _page = (_page + 1) % _slides.length;
      _controller.animateToPage(
        _page,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed(LoginScreen.route);
  }

  void _continueAsGuest() {
    final state = AppStateScope.of(context, listen: false);
    Navigator.of(context).pushReplacementNamed(ShellScreen.route, arguments: state);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final padding = EdgeInsets.symmetric(horizontal: context.responsiveHorizontal);

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (value) => setState(() => _page = value),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(slide['image']!, fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: padding.copyWith(top: context.responsiveVertical),
              child: Row(
                children: List.generate(_slides.length, (index) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      margin: EdgeInsetsDirectional.only(end: index == _slides.length - 1 ? 0 : 8),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _page ? theme.colorScheme.primary : Colors.white38,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: EdgeInsets.only(bottom: context.responsiveVertical),
              child: Padding(
                padding: padding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.constrainedWidth(520)),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(context.responsiveValue(18, 24)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: _SlideText(
                                key: ValueKey(_slides[_page]['title']),
                                title: _slides[_page]['title']!,
                                subtitle: _slides[_page]['subtitle']!,
                              ),
                            ),
                            SizedBox(height: context.responsiveValue(16, 24)),
                            SizedBox(
                              width: double.infinity,
                              child: PrimaryButton(
                                label: locale.translate('get_started'),
                                onPressed: _goToLogin,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: SecondaryButton(
                                label: locale.translate('guest_login'),
                                onPressed: _continueAsGuest,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.center,
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                ),
                                icon: const Icon(IconlyLight.arrow_down_2),
                                onPressed: () => _controller.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideText extends StatelessWidget {
  const _SlideText({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: onSurface,
            fontSize: context.scaleFont(theme.textTheme.headlineLarge?.fontSize ?? 28),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: onSurface.withOpacity(0.72),
            fontSize: context.scaleFont(theme.textTheme.bodyLarge?.fontSize ?? 16),
          ),
        ),
      ],
    );
  }
}
