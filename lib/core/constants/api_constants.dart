import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

class ApiConstants {
  // A private constructor prevents this class from being instantiated.
  // We only want to use it to hold static constant values.
  ApiConstants._();

  // ==========================================
  // 1. FIREBASE CONFIGURATION
  // ==========================================
  // Note: If you used the FlutterFire CLI, a lot of this might be in 
  // firebase_options.dart. But if you need manual strings:
  static const String firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID';
  static const String firebaseWebApiKey = 'YOUR_FIREBASE_WEB_API_KEY';

  // ==========================================
  // 2. CASHFREE PAYMENT GATEWAY
  // ==========================================
  // IMPORTANT: Only put your public APP ID here for the Flutter SDK.
  // NEVER put your Cashfree Secret Key in Flutter. That belongs in Firebase Cloud Functions.
  static const String cashfreeAppId = 'YOUR_CASHFREE_APP_ID';
  
  // FIXED: Using the official CFEnvironment enum instead of a raw String
  // Change to CFEnvironment.PRODUCTION when your app goes live
  static const CFEnvironment cashfreeEnvironment = CFEnvironment.SANDBOX; 

  // ==========================================
  // 3. BASE URLs
  // ==========================================
  // If you are connecting to any external APIs outside of Firebase
  static const String externalApiBaseUrl = 'https://api.example.com/v1/';

  // ==========================================
  // 4. LANGUAGE & REGION (from includes/lang)
  // ==========================================
  static const String appName = 'Thanga Roja Jewellers';
  static const String defaultCurrencySymbol = '₹';
  static const String defaultCurrencyCode = 'INR';
  static const String defaultLanguage = 'en';

  // Quick fallback strings if needed before fully implementing localization
  static const String genericErrorMsg = 'Something went wrong. Please try again.';
  static const String networkErrorMsg = 'Please check your internet connection.';

  // ==========================================
  // 5. APP CONFIGURATION & LIMITS (from includes/config)
  // ==========================================
  static const int maxPaginationLimit = 20;
  static const String supportEmail = 'trjmadurai@gmail.com';
  static const String supportPhone = '+91 98658 42294';
}