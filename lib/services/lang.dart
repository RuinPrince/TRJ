import 'package:flutter/material.dart';

class AppLanguage extends ChangeNotifier {
  // Singleton pattern so the same instance is shared across the whole app
  static final AppLanguage _instance = AppLanguage._internal();
  factory AppLanguage() => _instance;
  AppLanguage._internal();

  // Default language
  String _currentLanguage = 'en'; 
  String get currentLanguage => _currentLanguage;

  // Toggle function
  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'en' ? 'ta' : 'en';
    notifyListeners(); // Tells the UI to rebuild instantly
  }

  // Translation helper
  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key; // Fallback to key if not found
  }

  // --- TRANSLATION DICTIONARY ---
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'brand_name': 'THANGA ROJA\nJEWELLERS',
      'language_toggle': 'தமிழ்',
      'customer_login': 'Customer Login',
      'login_subtitle': 'Securely access your gold savings account',
      'username_email': 'USERNAME OR EMAIL',
      'password': 'PASSWORD',
      'sign_in': 'SIGN IN',
      'forgot_password_q': 'Forgot Password?',
      'remember_me': 'Remember me',
      'dont_have_account': "Don't have an account? ",
      'register_here': 'Register here',
      'dashboard': 'Dashboard',
      'home': 'HOME',
      'schemes': 'SCHEMES',
      'pay': 'PAY',
      'profile': 'PROFILE',
      'logout': 'LOGOUT',
      'total_investment': 'TOTAL INVESTMENT',
      'quick_actions': 'Quick Actions',
      'pay_now': 'Pay Now',
      'receipts': 'Receipts',
      'support': 'Support',
    },
    'ta': {
      'brand_name': 'தங்க ரோஜா\nஜுவல்லர்ஸ்',
      'language_toggle': 'English',
      'customer_login': 'வாடிக்கையாளர் உள்நுழைவு',
      'login_subtitle': 'உங்கள் தங்க சேமிப்பு கணக்கை பாதுகாப்பாக அணுகவும்',
      'username_email': 'பயனர்பெயர் அல்லது மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'sign_in': 'உள்நுழைக',
      'forgot_password_q': 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?',
      'remember_me': 'என்னை நினைவில் கொள்க',
      'dont_have_account': "கணக்கு இல்லையா? ",
      'register_here': 'இங்கே பதிவு செய்யவும்',
      'dashboard': 'முகப்பு',
      'home': 'முகப்பு',
      'schemes': 'திட்டங்கள்',
      'pay': 'செலுத்து',
      'profile': 'சுயவிவரம்',
      'logout': 'வெளியேறு',
      'total_investment': 'மொத்த முதலீடு',
      'quick_actions': 'விரைவான செயல்பாடுகள்',
      'pay_now': 'இப்போது செலுத்து',
      'receipts': 'ரசீதுகள்',
      'support': 'உதவி',
    }
  };
}

// Global helper function for cleaner UI code
String tr(String key) => AppLanguage().translate(key);