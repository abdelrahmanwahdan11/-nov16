import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static TextDirection directionOf(Locale locale) =>
      locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  static const _localizedValues = {
    'en': {
      'app_title': 'Foodly',
      'login': 'Login',
      'signup': 'Create account',
      'guest_login': 'Continue as guest',
      'home': 'Home',
      'restaurants': 'Restaurants',
      'my_cart': 'My Cart',
      'chat': 'Chat',
      'offers': 'Offers',
      'categories': 'Categories',
      'popular_items': 'Popular Items',
      'search_food': 'Search for food...',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'primary_color': 'Primary Color',
      'language': 'Language',
      'comparison': 'Comparison',
      'catalog': 'Catalog',
      'ai_info': 'AI Info',
      'favorites': 'Favorites',
      'orders': 'Orders',
      'help_center': 'Help Center',
      'profile': 'Profile',
      'pull_to_refresh': 'Pull to refresh',
      'empty_state': 'Nothing here yet',
      'retry': 'Retry',
      'search': 'Search',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'phone': 'Phone',
      'remember_me': 'Remember me',
      'forgot_password': 'Forgot password?',
      'get_started': 'Get Started',
      'shop_now': 'Shop Now',
      'view_all': 'View all',
      'add_to_cart': 'Add to Cart',
      'add_to_comparison': 'Add to Comparison',
      'add_to_favorites': 'Add to Favorites',
      'checkout': 'Checkout',
      'total': 'Total',
      'apply': 'Apply',
      'use_now': 'Use Now',
      'ai_placeholder': 'AI will analyze this item later... stay tuned!'
    },
    'ar': {
      'app_title': 'فودلي',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'guest_login': 'الدخول كضيف',
      'home': 'الرئيسية',
      'restaurants': 'المطاعم',
      'my_cart': 'سلة المشتريات',
      'chat': 'الدردشة',
      'offers': 'العروض',
      'categories': 'الفئات',
      'popular_items': 'الأطباق الشائعة',
      'search_food': 'ابحث عن طعام...',
      'settings': 'الإعدادات',
      'dark_mode': 'الوضع الداكن',
      'primary_color': 'اللون الرئيسي',
      'language': 'اللغة',
      'comparison': 'المقارنة',
      'catalog': 'الكتالوج',
      'ai_info': 'معلومات بالذكاء الاصطناعي',
      'favorites': 'المفضلة',
      'orders': 'الطلبات',
      'help_center': 'مركز المساعدة',
      'profile': 'الملف الشخصي',
      'pull_to_refresh': 'اسحب للتحديث',
      'empty_state': 'لا يوجد محتوى بعد',
      'retry': 'إعادة المحاولة',
      'search': 'بحث',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'name': 'الاسم',
      'phone': 'الهاتف',
      'remember_me': 'تذكرني',
      'forgot_password': 'نسيت كلمة المرور؟',
      'get_started': 'ابدأ الآن',
      'shop_now': 'تسوق الآن',
      'view_all': 'عرض الكل',
      'add_to_cart': 'أضف إلى السلة',
      'add_to_comparison': 'أضف إلى المقارنة',
      'add_to_favorites': 'أضف إلى المفضلة',
      'checkout': 'الدفع',
      'total': 'الإجمالي',
      'apply': 'تطبيق',
      'use_now': 'استخدم الآن',
      'ai_placeholder': 'سيقوم الذكاء الاصطناعي بتحليل هذا الطبق لاحقًا... ترقب!'
    }
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.contains(Locale(locale.languageCode));

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
