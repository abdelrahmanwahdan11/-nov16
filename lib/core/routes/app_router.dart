import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/catalog/catalog_screen.dart';
import '../../features/comparison/comparison_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/food_details/food_details_screen.dart';
import '../../features/help/help_center_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/orders/track_order_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/manage_address_screen.dart';
import '../../features/profile/payment_methods_screen.dart';
import '../../features/rewards/rewards_screen.dart';
import '../../features/meal_planner/meal_planner_screen.dart';
import '../../features/restaurant/restaurant_details_screen.dart';
import '../../features/restaurant/restaurants_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shell/shell_screen.dart';
import '../services/mock_data_service.dart';
import '../services/notifiers.dart';

class AppRouter {
  AppRouter({required this.state});

  final AppState state;
  final navigatorKey = GlobalKey<NavigatorState>();

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    Widget builder() {
      switch (settings.name) {
        case OnboardingScreen.route:
          return const OnboardingScreen();
        case LoginScreen.route:
          return const LoginScreen();
        case SignUpScreen.route:
          return const SignUpScreen();
        case ForgotPasswordScreen.route:
          return const ForgotPasswordScreen();
        case ShellScreen.route:
          return ShellScreen(state: state);
        case HomeScreen.route:
          return HomeScreen(state: state);
        case RestaurantsScreen.route:
          return RestaurantsScreen(state: state);
        case RestaurantDetailsScreen.route:
          return RestaurantDetailsScreen(state: state, restaurant: settings.arguments as Restaurant);
        case CatalogScreen.route:
          return CatalogScreen(state: state);
        case SearchScreen.route:
          return SearchScreen(state: state);
        case FoodDetailsScreen.route:
          return FoodDetailsScreen(state: state, item: settings.arguments as FoodItem);
        case ComparisonScreen.route:
          return ComparisonScreen(state: state);
        case CartScreen.route:
          return CartScreen(state: state);
        case ChatScreen.route:
          return ChatScreen(state: state);
        case OrdersScreen.route:
          return OrdersScreen(state: state);
        case TrackOrderScreen.route:
          return TrackOrderScreen(order: settings.arguments as Order);
        case ProfileScreen.route:
          return ProfileScreen(state: state);
        case ManageAddressScreen.route:
          return ManageAddressScreen(state: state);
        case PaymentMethodsScreen.route:
          return PaymentMethodsScreen(state: state);
        case SettingsScreen.route:
          return SettingsScreen(state: state);
        case FavoritesScreen.route:
          return FavoritesScreen(state: state);
        case HelpCenterScreen.route:
          return HelpCenterScreen(state: state);
        case RewardsScreen.route:
          return RewardsScreen(state: state);
        case MealPlannerScreen.route:
          return MealPlannerScreen(state: state);
        default:
          return const OnboardingScreen();
      }
    }

    return PageRouteBuilder(
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => builder(),
    );
  }
}
