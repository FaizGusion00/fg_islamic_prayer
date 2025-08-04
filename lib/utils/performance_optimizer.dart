import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Performance optimization utilities for the Islamic Prayer app
class PerformanceOptimizer {
  static const String _cacheKey = 'app_performance_cache';
  static const Duration _cacheExpiry = Duration(hours: 6);
  
  /// Cache for frequently accessed data
  static final Map<String, dynamic> _memoryCache = {};
  static Timer? _cacheCleanupTimer;
  
  /// Initialize performance optimizations
  static Future<void> initialize() async {
    _startCacheCleanupTimer();
    await _loadCachedData();
  }
  
  /// Cache data with expiration
  static void cacheData(String key, dynamic data, {Duration? expiry}) {
    final expiryTime = DateTime.now().add(expiry ?? _cacheExpiry);
    _memoryCache[key] = {
      'data': data,
      'expiry': expiryTime.millisecondsSinceEpoch,
    };
  }
  
  /// Get cached data if not expired
  static T? getCachedData<T>(String key) {
    final cached = _memoryCache[key];
    if (cached != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(cached['expiry']);
      if (DateTime.now().isBefore(expiry)) {
        return cached['data'] as T;
      } else {
        _memoryCache.remove(key);
      }
    }
    return null;
  }
  
  /// Clear expired cache entries
  static void _cleanupCache() {
    final now = DateTime.now();
    _memoryCache.removeWhere((key, value) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(value['expiry']);
      return now.isAfter(expiry);
    });
  }
  
  /// Start cache cleanup timer
  static void _startCacheCleanupTimer() {
    _cacheCleanupTimer?.cancel();
    _cacheCleanupTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _cleanupCache();
    });
  }
  
  /// Load cached data from SharedPreferences
  static Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        // Parse and load cached data
        // Implementation depends on your data structure
      }
    } catch (e) {
      // Handle cache loading errors
    }
  }
  
  /// Optimize image loading
  static Widget optimizeImage(String imagePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: (width ?? 300).round(),
      cacheHeight: (height ?? 300).round(),
      filterQuality: FilterQuality.medium,
    );
  }
  
  /// Optimize list building
  static List<Widget> buildOptimizedList<T>({
    required List<T> items,
    required Widget Function(T item, int index) builder,
    int? itemCount,
  }) {
    final count = itemCount ?? items.length;
    return List.generate(count, (index) {
      return builder(items[index], index);
    });
  }
  
  /// Dispose resources
  static void dispose() {
    _cacheCleanupTimer?.cancel();
    _memoryCache.clear();
  }
} 