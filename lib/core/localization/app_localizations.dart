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
      'catalog_title': 'Catalog',
      'deliver_to': 'Deliver to',
      'sample_city': 'San Francisco',
      'offer_banner_title': 'Up to 35% OFF',
      'offer_banner_subtitle': 'Delicious meals ready in minutes.',
      'fast_food': 'Fast Food',
      'sea_food': 'Sea Food',
      'dessert': 'Dessert',
      'crispy': 'Crispy',
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
      'ai_placeholder': 'AI will analyze this item later... stay tuned!',
      'load_more': 'Load more',
      'loading_more': 'Loading more...',
      'no_more_results': 'You have reached the end.',
      'minutes_delivery': 'min delivery',
      'empty_orders_message': 'No orders yet. Start exploring delicious meals.',
      'current': 'Current',
      'history': 'History',
      'track': 'Track',
      'order_updates': 'Order Updates',
      'offers_promotions': 'Offers & Promotions',
      'empty_favorites_title': 'Empty favorites',
      'empty_favorites_subtitle': 'Tap the heart icon on dishes to save them here.',
      'search_empty_subtitle': 'Try another keyword or explore categories.',
      'chat_title': 'Chat',
      'chat_intro': 'Hi Lina! Need help finding your next meal?',
      'chat_hint': 'Type your message...',
      'chat_bot_reply': 'Our concierge will respond shortly. Meanwhile, explore today\'s offers!',
      'send': 'Send',
      'best_match': 'Best match',
      'lowest_price': 'Lowest price',
      'highest_rating': 'Highest rating',
      'fastest_delivery': 'Fastest delivery',
      'view_more': 'View more'
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
      'catalog_title': 'الكتالوج',
      'deliver_to': 'التوصيل إلى',
      'sample_city': 'سان فرانسيسكو',
      'offer_banner_title': 'خصم حتى ٣٥٪',
      'offer_banner_subtitle': 'وجبات شهية جاهزة خلال دقائق.',
      'fast_food': 'وجبات سريعة',
      'sea_food': 'مأكولات بحرية',
      'dessert': 'حلويات',
      'crispy': 'مقرمشات',
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
      'ai_placeholder': 'سيقوم الذكاء الاصطناعي بتحليل هذا الطبق لاحقًا... ترقب!',
      'load_more': 'المزيد',
      'loading_more': 'جاري تحميل المزيد...',
      'no_more_results': 'لقد وصلت للنهاية.',
      'minutes_delivery': 'دقيقة للتوصيل',
      'empty_orders_message': 'لا توجد طلبات بعد. ابدأ باستكشاف الوجبات الشهية.',
      'current': 'الحالية',
      'history': 'السابق',
      'track': 'تتبع',
      'order_updates': 'تحديثات الطلب',
      'offers_promotions': 'العروض والتخفيضات',
      'empty_favorites_title': 'لا توجد عناصر مفضلة',
      'empty_favorites_subtitle': 'اضغط على أيقونة القلب لحفظ الأطباق هنا.',
      'search_empty_subtitle': 'جرّب كلمة أخرى أو استكشف الفئات.',
      'chat_title': 'الدردشة',
      'chat_intro': 'أهلًا لينا! هل تحتاجين مساعدة لاختيار وجبتك القادمة؟',
      'chat_hint': 'اكتبي رسالتك...',
      'chat_bot_reply': 'سيرد عليك المساعد قريبًا. في هذه الأثناء تصفحي عروض اليوم!',
      'send': 'إرسال',
      'best_match': 'الأفضل تطابقًا',
      'lowest_price': 'الأقل سعرًا',
      'highest_rating': 'الأعلى تقييمًا',
      'fastest_delivery': 'الأسرع توصيلًا',
      'view_more': 'عرض المزيد'
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
