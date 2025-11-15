import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/services/notifiers.dart';
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
                  Positioned(
                    bottom: 160,
                    left: 24,
                    right: 24,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        key: ValueKey(slide['title']),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide['title']!,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(color: Colors.white, shadows: const [Shadow(color: Colors.black54, blurRadius: 8)]),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            slide['subtitle']!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 24,
            left: 24,
            right: 24,
            child: Row(
              children: List.generate(_slides.length, (index) {
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    margin: EdgeInsetsDirectional.only(end: index == _slides.length - 1 ? 0 : 8),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _page ? Theme.of(context).colorScheme.primary : Colors.white38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(label: locale.translate('get_started'), onPressed: _goToLogin),
                const SizedBox(height: 16),
                SecondaryButton(label: locale.translate('guest_login'), onPressed: _continueAsGuest),
                const SizedBox(height: 24),
                IconButton(
                  icon: const Icon(IconlyLight.arrow_down_2, color: Colors.white),
                  onPressed: () => _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
