import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

/// Advanced caching service for prayer times and other data
class CacheService {
  static const String _prayerTimesKey = 'cached_prayer_times';
  static const String _locationKey = 'cached_location';
  static const String _settingsKey = 'cached_settings';
  static const Duration _defaultExpiry = Duration(hours: 6);
  
  /// Cache prayer times with expiration
  static Future<void> cachePrayerTimes(Map<String, dynamic> prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': prayerTimes,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': DateTime.now().add(_defaultExpiry).millisecondsSinceEpoch,
    };
    await prefs.setString(_prayerTimesKey, jsonEncode(cacheData));
  }
  
  /// Get cached prayer times if valid
  static Future<Map<String, dynamic>?> getCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prayerTimesKey);
    
    if (cached != null) {
      try {
        final cacheData = jsonDecode(cached) as Map<String, dynamic>;
        final expiry = DateTime.fromMillisecondsSinceEpoch(cacheData['expiry']);
        
        if (DateTime.now().isBefore(expiry)) {
          return cacheData['data'] as Map<String, dynamic>;
        } else {
          // Cache expired, remove it
          await prefs.remove(_prayerTimesKey);
        }
      } catch (e) {
        // Invalid cache data, remove it
        await prefs.remove(_prayerTimesKey);
      }
    }
    return null;
  }
  
  /// Cache location data
  static Future<void> cacheLocation(Map<String, dynamic> location) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': location,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
    };
    await prefs.setString(_locationKey, jsonEncode(cacheData));
  }
  
  /// Get cached location if valid
  static Future<Map<String, dynamic>?> getCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_locationKey);
    
    if (cached != null) {
      try {
        final cacheData = jsonDecode(cached) as Map<String, dynamic>;
        final expiry = DateTime.fromMillisecondsSinceEpoch(cacheData['expiry']);
        
        if (DateTime.now().isBefore(expiry)) {
          return cacheData['data'] as Map<String, dynamic>;
        } else {
          await prefs.remove(_locationKey);
        }
      } catch (e) {
        await prefs.remove(_locationKey);
      }
    }
    return null;
  }
  
  /// Clear all cached data
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prayerTimesKey);
    await prefs.remove(_locationKey);
    await prefs.remove(_settingsKey);
  }
  
  /// Get cache size info
  static Future<Map<String, int>> getCacheInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith('cached_')).toList();
    
    int totalSize = 0;
    for (final key in cacheKeys) {
      final value = prefs.getString(key);
      if (value != null) {
        totalSize += value.length;
      }
    }
    
    return {
      'totalKeys': cacheKeys.length,
      'totalSize': totalSize,
    };
  }
} 