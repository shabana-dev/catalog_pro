import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Product Catalogue',
      'app_slogan': 'ELEGANCE IN EVERY CLICK',
      'login': 'Login',
      'username': 'Username',
      'password': 'Password',
      'products': 'Products',
      'favourites': 'Favourites',
      'settings': 'Settings',
      'logout': 'Logout',
      'language': 'Language',
      'search_hint': 'Search products...',
      'offline': 'You are offline',
      'retry': 'Retry',
      'no_products': 'No products found',
      'no_favourites': 'No favourites yet',
      'scan_qr': 'Scan QR Code',
      'camera_permission': 'Camera access is required to scan QR codes. Please enable it in settings.',
      'cancel': 'Cancel',
      'open_settings': 'Open Settings',
      'simulator_type_code': 'Simulator? Enter Product ID:',
      'brand': 'Brand',
      'description': 'Description',
      'price': 'Price',
      'rating': 'Rating',
      'error': 'Error',
      'grant_permission': 'Grant Permission',
      'invalid_auth': 'Invalid username or password',
      'product_not_found': 'product not found',
      'invalid_qr': 'this QR code is not a product',
      'added_to_favourites': 'Added to favourites',
      'removed_from_favourites': 'Removed from favourites',
      'logout_confirm_title': 'Logout',
      'logout_confirm_message': 'Are you sure you want to log out?',
      'logged_out_message': 'Logged out successfully',
      'welcome_back': 'Welcome back! Please enter your details.',
      'sign_in_continue': 'Please sign in to continue',
      'review': 'Review',
      'add_to_cart': 'ADD TO CART',
      'enter_username': 'Please enter your username',
      'enter_password': 'Please enter your password',
    },
    'ar': {
      'app_name': 'كتالوج المنتجات',
      'app_slogan': 'الأناقة في كل نقرة',
      'login': 'تسجيل الدخول',
      'username': 'اسم المستخدم',
      'password': 'كلمة المرور',
      'products': 'المنتجات',
      'favourites': 'المفضلات',
      'settings': 'الإعدادات',
      'logout': 'تسجيل الخروج',
      'language': 'اللغة',
      'search_hint': 'بحث عن منتجات...',
      'offline': 'أنت غير متصل بالإنترنت',
      'retry': 'إعادة المحاولة',
      'no_products': 'لم يتم العثور على منتجات',
      'no_favourites': 'لا توجد مفضلات بعد',
      'scan_qr': 'مسح رمز QR',
      'camera_permission': 'مطلوب الوصول إلى الكاميرا لمسح رموز QR. يرجى تفعيلها في الإعدادات.',
      'cancel': 'إلغاء',
      'open_settings': 'افتح الإعدادات',
      'simulator_type_code': 'محاكي؟ أدخل معرف المنتج:',
      'brand': 'الماركة',
      'description': 'الوصف',
      'price': 'السعر',
      'rating': 'التقييم',
      'error': 'خطأ',
      'grant_permission': 'منح الإذن',
      'invalid_auth': 'اسم المستخدم أو كلمة المرور غير صحيحة',
      'product_not_found': 'المنتج غير موجود',
      'invalid_qr': 'رمز QR هذا ليس منتجًا',
      'added_to_favourites': 'تمت الإضافة إلى المفضلات',
      'removed_from_favourites': 'تمت الإزالة من المفضلات',
      'logout_confirm_title': 'تسجيل الخروج',
      'logout_confirm_message': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'logged_out_message': 'تم تسجيل الخروج بنجاح',
      'welcome_back': 'مرحبًا بعودتك! يرجى إدخال بياناتك.',
      'sign_in_continue': 'يرجى تسجيل الدخول للمتابعة',
      'review': 'مراجعة',
      'add_to_cart': 'أضف إلى السلة',
      'enter_username': 'يرجى إدخال اسم المستخدم',
      'enter_password': 'يرجى إدخال كلمة المرور',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
