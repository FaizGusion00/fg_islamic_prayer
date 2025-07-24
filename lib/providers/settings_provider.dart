import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isVibrationEnabled = true;
  bool _isLocationEnabled = true;
  
  // Notification settings for each prayer
  Map<String, bool> _notificationEnabled = {
    'fajr': true,
    'sunrise': false,
    'dhuha': false,
    'dhuhr': true,
    'asr': true,
    'maghrib': true,
    'isha': true,
    'imsak': false,
  };
  
  // Azan settings for each prayer
  Map<String, bool> _azanEnabled = {
    'fajr': true,
    'sunrise': false,
    'dhuha': false,
    'dhuhr': true,
    'asr': true,
    'maghrib': true,
    'isha': true,
    'imsak': false,
  };
  
  // Full azan vs short tone for each prayer
  Map<String, bool> _fullAzan = {
    'fajr': true,
    'sunrise': false,
    'dhuha': false,
    'dhuhr': false,
    'asr': false,
    'maghrib': true,
    'isha': true,
    'imsak': false,
  };
  
  String _selectedLanguage = 'en';
  String _calculationMethod = '2'; // Islamic Society of North America
  String _asrMethod = '0'; // Shafi
  
  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isVibrationEnabled => _isVibrationEnabled;
  bool get isLocationEnabled => _isLocationEnabled;
  Map<String, bool> get notificationEnabled => _notificationEnabled;
  Map<String, bool> get azanEnabled => _azanEnabled;
  Map<String, bool> get fullAzan => _fullAzan;
  String get selectedLanguage => _selectedLanguage;
  String get calculationMethod => _calculationMethod;
  String get asrMethod => _asrMethod;
  
  // Available languages
  final Map<String, String> availableLanguages = {
    'en': 'English',
    'ar': 'العربية',
    'ms': 'Bahasa Melayu',
    'id': 'Bahasa Indonesia',
  };
  
  // Prayer names for display
  final Map<String, String> prayerDisplayNames = {
    'fajr': 'Fajr',
    'sunrise': 'Sunrise',
    'dhuha': 'Dhuha',
    'dhuhr': 'Dhuhr',
    'asr': 'Asr',
    'maghrib': 'Maghrib',
    'isha': 'Isha',
    'imsak': 'Imsak',
  };

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    _isVibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    _isLocationEnabled = prefs.getBool('location_enabled') ?? true;
    _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    _calculationMethod = prefs.getString('calculation_method') ?? '2';
    _asrMethod = prefs.getString('asr_method') ?? '0';
    
    // Load notification settings
    for (String prayer in _notificationEnabled.keys) {
      _notificationEnabled[prayer] = prefs.getBool('notification_$prayer') ?? true;
      _azanEnabled[prayer] = prefs.getBool('azan_enabled_$prayer') ?? true;
      _fullAzan[prayer] = prefs.getBool('full_azan_$prayer') ?? 
          (prayer == 'fajr' || prayer == 'maghrib' || prayer == 'isha');
    }
    
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _isVibrationEnabled = !_isVibrationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', _isVibrationEnabled);
    await NotificationService.updateNotificationSettings();
    notifyListeners();
  }

  Future<void> toggleLocation() async {
    _isLocationEnabled = !_isLocationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_enabled', _isLocationEnabled);
    notifyListeners();
  }

  Future<void> toggleNotification(String prayer) async {
    _notificationEnabled[prayer] = !(_notificationEnabled[prayer] ?? true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_$prayer', _notificationEnabled[prayer]!);
    
    if (!_notificationEnabled[prayer]!) {
      await NotificationService.cancelPrayerNotification(prayer);
    } else {
      await NotificationService.updateNotificationSettings();
    }
    
    notifyListeners();
  }

  Future<void> toggleAzan(String prayer) async {
    _azanEnabled[prayer] = !(_azanEnabled[prayer] ?? true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('azan_enabled_$prayer', _azanEnabled[prayer]!);
    await NotificationService.updateNotificationSettings();
    notifyListeners();
  }

  Future<void> toggleFullAzan(String prayer) async {
    _fullAzan[prayer] = !(_fullAzan[prayer] ?? true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('full_azan_$prayer', _fullAzan[prayer]!);
    await NotificationService.updateNotificationSettings();
    notifyListeners();
  }

  void setAzanSound(String prayer, bool azanEnabled, bool fullAzan) async {
    _azanEnabled[prayer] = azanEnabled;
    _fullAzan[prayer] = fullAzan;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('azan_enabled_$prayer', azanEnabled);
    await prefs.setBool('full_azan_$prayer', fullAzan);
    await NotificationService.updateNotificationSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
    notifyListeners();
  }

  Future<void> setCalculationMethod(String method) async {
    _calculationMethod = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calculation_method', method);
    notifyListeners();
  }

  Future<void> setAsrMethod(String method) async {
    _asrMethod = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('asr_method', method);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Reset all settings to defaults
    _isDarkMode = false;
    _isVibrationEnabled = true;
    _isLocationEnabled = true;
    _selectedLanguage = 'en';
    _calculationMethod = '2';
    _asrMethod = '0';
    
    // Reset notification settings
    for (String prayer in _notificationEnabled.keys) {
      _notificationEnabled[prayer] = true;
      _azanEnabled[prayer] = true;
      _fullAzan[prayer] = prayer == 'fajr' || prayer == 'maghrib' || prayer == 'isha';
    }
    
    // Clear all preferences
    await prefs.clear();
    
    // Save default settings
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setBool('vibration_enabled', _isVibrationEnabled);
    await prefs.setBool('location_enabled', _isLocationEnabled);
    await prefs.setString('selected_language', _selectedLanguage);
    await prefs.setString('calculation_method', _calculationMethod);
    await prefs.setString('asr_method', _asrMethod);
    
    for (String prayer in _notificationEnabled.keys) {
      await prefs.setBool('notification_$prayer', _notificationEnabled[prayer]!);
      await prefs.setBool('azan_enabled_$prayer', _azanEnabled[prayer]!);
      await prefs.setBool('full_azan_$prayer', _fullAzan[prayer]!);
    }
    
    await NotificationService.updateNotificationSettings();
    notifyListeners();
  }

  Future<void> exportSettings() async {
    // This could be implemented to export settings to a file
    // For now, we'll just return the current settings as a map
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Import settings from map
    if (settings.containsKey('dark_mode')) {
      _isDarkMode = settings['dark_mode'] ?? false;
      await prefs.setBool('dark_mode', _isDarkMode);
    }
    
    if (settings.containsKey('vibration_enabled')) {
      _isVibrationEnabled = settings['vibration_enabled'] ?? true;
      await prefs.setBool('vibration_enabled', _isVibrationEnabled);
    }
    
    if (settings.containsKey('location_enabled')) {
      _isLocationEnabled = settings['location_enabled'] ?? true;
      await prefs.setBool('location_enabled', _isLocationEnabled);
    }
    
    if (settings.containsKey('selected_language')) {
      _selectedLanguage = settings['selected_language'] ?? 'en';
      await prefs.setString('selected_language', _selectedLanguage);
    }
    
    if (settings.containsKey('calculation_method')) {
      _calculationMethod = settings['calculation_method'] ?? '2';
      await prefs.setString('calculation_method', _calculationMethod);
    }
    
    if (settings.containsKey('asr_method')) {
      _asrMethod = settings['asr_method'] ?? '0';
      await prefs.setString('asr_method', _asrMethod);
    }
    
    await NotificationService.updateNotificationSettings();
    notifyListeners();
  }

  Map<String, dynamic> getCurrentSettings() {
    return {
      'dark_mode': _isDarkMode,
      'vibration_enabled': _isVibrationEnabled,
      'location_enabled': _isLocationEnabled,
      'selected_language': _selectedLanguage,
      'calculation_method': _calculationMethod,
      'asr_method': _asrMethod,
      'notification_settings': _notificationEnabled,
      'azan_settings': _azanEnabled,
      'full_azan_settings': _fullAzan,
    };
  }

  bool isNotificationEnabled(String prayer) {
    return _notificationEnabled[prayer] ?? true;
  }

  bool isAzanEnabled(String prayer) {
    return _azanEnabled[prayer] ?? true;
  }

  bool isFullAzanEnabled(String prayer) {
    return _fullAzan[prayer] ?? true;
  }
}