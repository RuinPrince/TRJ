import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Singleton pattern to ensure we only have one instance of the service
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  // Keys
  static const String _keyMetalRates = 'cache_metal_rates';
  static const String _keyFlashMessage = 'session_flash_message';
  static const String _keyPrefixSchemes = 'cache_schemes_';

  /// Initialize the SharedPreferences instance.
  /// Call this once in your main.dart before runApp()
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==========================================
  // 1. METAL RATES CACHE (Replaces metal_rates_cache.json)
  // ==========================================
  
  /// Saves the live metal rates to local storage
  Future<void> saveMetalRates({
    required double gold,
    required double silver,
    required String source,
  }) async {
    final Map<String, dynamic> data = {
      'gold': gold,
      'silver': silver,
      'source': source,
      'last_updated': DateTime.now().toIso8601String(),
    };
    
    await _prefs?.setString(_keyMetalRates, jsonEncode(data));
  }

  /// Retrieves cached metal rates. Returns null if expired or not found.
  /// Default expiry is set to 1 hour (configurable).
  Map<String, dynamic>? getMetalRates({int expiryMinutes = 60}) {
    final String? jsonString = _prefs?.getString(_keyMetalRates);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final DateTime lastUpdated = DateTime.parse(data['last_updated']);
      
      // Check if cache has expired
      if (DateTime.now().difference(lastUpdated).inMinutes > expiryMinutes) {
        clearCache(_keyMetalRates); // Auto-cleanup expired cache
        return null;
      }
      
      return data;
    } catch (e) {
      print('Error parsing metal rates cache: $e');
      return null;
    }
  }

  // ==========================================
  // 2. GENERIC CACHE MANAGEMENT (Replaces cache.php)
  // ==========================================

  /// Save generic JSON data (like Active Schemes) to cache
  Future<void> saveGenericCache(String key, Map<String, dynamic> data) async {
    final payload = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs?.setString(key, jsonEncode(payload));
  }

  /// Clears a specific cache file/key (Equivalent to cache.php ?action=delete)
  Future<void> clearCache(String key) async {
    await _prefs?.remove(key);
  }

  /// Clears all cached schemes (Equivalent to cache.php ?action=clear_schemes)
  Future<void> clearAllSchemesCache() async {
    if (_prefs == null) return;
    
    final keys = _prefs!.getKeys();
    for (String key in keys) {
      if (key.startsWith(_keyPrefixSchemes)) {
        await _prefs!.remove(key);
      }
    }
  }

  /// Clears the entire system cache (Equivalent to cache.php ?action=clear_all)
  Future<void> clearAllCache() async {
    // We only want to clear cache keys, NOT auth tokens or user preferences
    if (_prefs == null) return;
    
    final keys = _prefs!.getKeys();
    for (String key in keys) {
      if (key.startsWith('cache_')) {
        await _prefs!.remove(key);
      }
    }
  }

  // ==========================================
  // 3. FLASH MESSAGES (Replaces session.php setFlash/getFlash)
  // ==========================================
  // Note: In Flutter, you usually use ScaffoldMessenger for immediate alerts.
  // This is only needed if you want a message to survive a hard app reboot.

  Future<void> setFlashMessage(String type, String message) async {
    final data = {
      'type': type, // 'success', 'error', 'warning', 'info'
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _prefs?.setString(_keyFlashMessage, jsonEncode(data));
  }

  /// Retrieves and immediately deletes the flash message (Read-Once)
  Map<String, dynamic>? consumeFlashMessage() {
    final String? jsonString = _prefs?.getString(_keyFlashMessage);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final DateTime timestamp = DateTime.parse(data['timestamp']);
      
      // Clear it so it only shows once
      _prefs?.remove(_keyFlashMessage);

      // Only return if it's less than 5 seconds old (matching your PHP logic)
      if (DateTime.now().difference(timestamp).inSeconds < 5) {
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}