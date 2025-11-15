import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_localizations.dart';
import 'core/routes/app_router.dart';
import 'core/services/notifiers.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  runApp(AppStateScope(state: appState, child: const FoodDeliveryApp()));
}

class FoodDeliveryApp extends StatefulWidget {
  const FoodDeliveryApp({super.key});

  @override
  State<FoodDeliveryApp> createState() => _FoodDeliveryAppState();
}

class _FoodDeliveryAppState extends State<FoodDeliveryApp> {
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    final state = AppStateScope.of(context, listen: false);
    _router = AppRouter(state: state);
    state.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    return AnimatedBuilder(
      animation: state.themeNotifier,
      builder: (context, _) {
        return AnimatedBuilder(
          animation: state.localeNotifier,
          builder: (context, __) {
            final locale = state.localeNotifier.locale;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Foodly',
              themeMode: state.themeNotifier.themeMode,
              theme: AppTheme.light(
                primaryColor: state.themeNotifier.primaryColor,
              ),
              darkTheme: AppTheme.dark(
                primaryColor: state.themeNotifier.primaryColor,
              ),
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              builder: (context, child) {
                SystemChrome.setSystemUIOverlayStyle(
                  AppTheme.overlayStyle(state.themeNotifier.isDarkMode),
                );
                final mediaQuery = MediaQuery.of(context);
                final clampedScaler = mediaQuery.textScaler.clamp(
                  minScaleFactor: 0.9,
                  maxScaleFactor: 1.2,
                );
                final directionality = Directionality(
                  textDirection: AppLocalizations.directionOf(locale),
                  child: child ?? const SizedBox.shrink(),
                );
                return MediaQuery(
                  data: mediaQuery.copyWith(textScaler: clampedScaler),
                  child: ScrollConfiguration(
                    behavior: const _AppScrollBehavior(),
                    child: directionality,
                  ),
                );
              },
              onGenerateRoute: _router.onGenerateRoute,
              navigatorKey: _router.navigatorKey,
            );
          },
        );
      },
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
