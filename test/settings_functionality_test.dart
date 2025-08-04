import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/providers/settings_provider.dart';

void main() {
  group('Settings Functionality Tests', () {
    late SettingsProvider settingsProvider;

    setUp(() async {
      // Set up mock preferences
      SharedPreferences.setMockInitialValues({
        'dark_mode': false,
        'vibration_enabled': true,
        'location_enabled': true,
        'selected_language': 'en',
        'calculation_method': '2',
        'asr_method': '0',
        'notification_fajr': true,
        'notification_dhuhr': true,
        'notification_asr': true,
        'notification_maghrib': true,
        'notification_isha': true,
        'azan_enabled_fajr': true,
        'azan_enabled_dhuhr': true,
        'azan_enabled_asr': true,
        'azan_enabled_maghrib': true,
        'azan_enabled_isha': true,
        'full_azan_fajr': true,
        'full_azan_dhuhr': false,
        'full_azan_asr': false,
        'full_azan_maghrib': true,
        'full_azan_isha': true,
      });

      settingsProvider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 100)); // Allow initialization
    });

    test('Settings provider initialization', () {
      expect(settingsProvider, isNotNull);
      expect(settingsProvider.isDarkMode, isFalse);
      expect(settingsProvider.isVibrationEnabled, isTrue);
      expect(settingsProvider.isLocationEnabled, isTrue);
    });

    test('Dark mode toggle functionality', () async {
      expect(settingsProvider.isDarkMode, isFalse);
      
      await settingsProvider.toggleDarkMode();
      expect(settingsProvider.isDarkMode, isTrue);
      
      await settingsProvider.toggleDarkMode();
      expect(settingsProvider.isDarkMode, isFalse);
    });

    test('Vibration toggle functionality', () async {
      expect(settingsProvider.isVibrationEnabled, isTrue);
      
      await settingsProvider.toggleVibration();
      expect(settingsProvider.isVibrationEnabled, isFalse);
      
      await settingsProvider.toggleVibration();
      expect(settingsProvider.isVibrationEnabled, isTrue);
    });

    test('Location toggle functionality', () async {
      expect(settingsProvider.isLocationEnabled, isTrue);
      
      await settingsProvider.toggleLocation();
      expect(settingsProvider.isLocationEnabled, isFalse);
      
      await settingsProvider.toggleLocation();
      expect(settingsProvider.isLocationEnabled, isTrue);
    });

    test('Prayer notification toggle functionality', () async {
      expect(settingsProvider.isNotificationEnabled('fajr'), isTrue);
      
      await settingsProvider.toggleNotification('fajr');
      expect(settingsProvider.isNotificationEnabled('fajr'), isFalse);
      
      await settingsProvider.toggleNotification('fajr');
      expect(settingsProvider.isNotificationEnabled('fajr'), isTrue);
    });

    test('Azan toggle functionality', () async {
      expect(settingsProvider.isAzanEnabled('fajr'), isTrue);
      
      await settingsProvider.toggleAzan('fajr');
      expect(settingsProvider.isAzanEnabled('fajr'), isFalse);
      
      await settingsProvider.toggleAzan('fajr');
      expect(settingsProvider.isAzanEnabled('fajr'), isTrue);
    });

    test('Full azan toggle functionality', () async {
      expect(settingsProvider.isFullAzanEnabled('fajr'), isTrue);
      
      await settingsProvider.toggleFullAzan('fajr');
      expect(settingsProvider.isFullAzanEnabled('fajr'), isFalse);
      
      await settingsProvider.toggleFullAzan('fajr');
      expect(settingsProvider.isFullAzanEnabled('fajr'), isTrue);
    });

    test('Set azan sound functionality', () async {
      // Test silent notification
      settingsProvider.setAzanSound('fajr', false, false);
      expect(settingsProvider.isAzanEnabled('fajr'), isFalse);
      expect(settingsProvider.isFullAzanEnabled('fajr'), isFalse);
      
      // Test short azan
      settingsProvider.setAzanSound('fajr', true, false);
      expect(settingsProvider.isAzanEnabled('fajr'), isTrue);
      expect(settingsProvider.isFullAzanEnabled('fajr'), isFalse);
      
      // Test full azan
      settingsProvider.setAzanSound('fajr', true, true);
      expect(settingsProvider.isAzanEnabled('fajr'), isTrue);
      expect(settingsProvider.isFullAzanEnabled('fajr'), isTrue);
    });

    test('Language setting functionality', () async {
      expect(settingsProvider.selectedLanguage, equals('en'));
      
      await settingsProvider.setLanguage('ms');
      expect(settingsProvider.selectedLanguage, equals('ms'));
      
      await settingsProvider.setLanguage('en');
      expect(settingsProvider.selectedLanguage, equals('en'));
    });

    test('Calculation method setting functionality', () async {
      expect(settingsProvider.calculationMethod, equals('2'));
      
      await settingsProvider.setCalculationMethod('1');
      expect(settingsProvider.calculationMethod, equals('1'));
      
      await settingsProvider.setCalculationMethod('2');
      expect(settingsProvider.calculationMethod, equals('2'));
    });

    test('Asr method setting functionality', () async {
      expect(settingsProvider.asrMethod, equals('0'));
      
      await settingsProvider.setAsrMethod('1');
      expect(settingsProvider.asrMethod, equals('1'));
      
      await settingsProvider.setAsrMethod('0');
      expect(settingsProvider.asrMethod, equals('0'));
    });

    test('Settings export/import functionality', () async {
      final currentSettings = settingsProvider.getCurrentSettings();
      
      expect(currentSettings, isA<Map<String, dynamic>>());
      expect(currentSettings['dark_mode'], isFalse);
      expect(currentSettings['vibration_enabled'], isTrue);
      expect(currentSettings['selected_language'], equals('en'));
      expect(currentSettings['calculation_method'], equals('2'));
      expect(currentSettings['asr_method'], equals('0'));
      expect(currentSettings['notification_settings'], isA<Map<String, bool>>());
      expect(currentSettings['azan_settings'], isA<Map<String, bool>>());
      expect(currentSettings['full_azan_settings'], isA<Map<String, bool>>());
    });

    test('Reset to defaults functionality', () async {
      // Change some settings first
      await settingsProvider.toggleDarkMode();
      await settingsProvider.toggleVibration();
      await settingsProvider.setLanguage('ms');
      
      // Verify changes
      expect(settingsProvider.isDarkMode, isTrue);
      expect(settingsProvider.isVibrationEnabled, isFalse);
      expect(settingsProvider.selectedLanguage, equals('ms'));
      
      // Reset to defaults
      await settingsProvider.resetToDefaults();
      
      // Verify reset
      expect(settingsProvider.isDarkMode, isFalse);
      expect(settingsProvider.isVibrationEnabled, isTrue);
      expect(settingsProvider.selectedLanguage, equals('en'));
      expect(settingsProvider.calculationMethod, equals('2'));
      expect(settingsProvider.asrMethod, equals('0'));
    });

    test('Prayer display names', () {
      final displayNames = settingsProvider.prayerDisplayNames;
      
      expect(displayNames['fajr'], equals('Fajr'));
      expect(displayNames['dhuhr'], equals('Dhuhr'));
      expect(displayNames['asr'], equals('Asr'));
      expect(displayNames['maghrib'], equals('Maghrib'));
      expect(displayNames['isha'], equals('Isha'));
    });

    test('Available languages', () {
      final languages = settingsProvider.availableLanguages;
      
      expect(languages['en'], equals('English'));
      expect(languages['ar'], equals('العربية'));
      expect(languages['ms'], equals('Bahasa Melayu'));
      expect(languages['id'], equals('Bahasa Indonesia'));
    });

    test('Notification settings for all prayers', () {
      final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
      
      for (final prayer in prayers) {
        expect(settingsProvider.isNotificationEnabled(prayer), isTrue);
        expect(settingsProvider.isAzanEnabled(prayer), isTrue);
        
        // Test individual prayer settings
        expect(() async {
          await settingsProvider.toggleNotification(prayer);
        }, returnsNormally);
        
        expect(() async {
          await settingsProvider.toggleAzan(prayer);
        }, returnsNormally);
        
        expect(() async {
          await settingsProvider.toggleFullAzan(prayer);
        }, returnsNormally);
      }
    });

    test('Silent notification functionality', () async {
      // Test that silent notifications work correctly
      expect(settingsProvider.isAzanEnabled('fajr'), isTrue);
      
      // Set to silent
      settingsProvider.setAzanSound('fajr', false, false);
      expect(settingsProvider.isAzanEnabled('fajr'), isFalse);
      expect(settingsProvider.isFullAzanEnabled('fajr'), isFalse);
      
      // Verify notification is still enabled but azan is disabled
      expect(settingsProvider.isNotificationEnabled('fajr'), isTrue);
    });

    test('Short azan functionality', () async {
      // Test short azan setting
      settingsProvider.setAzanSound('fajr', true, false);
      expect(settingsProvider.isAzanEnabled('fajr'), isTrue);
      expect(settingsProvider.isFullAzanEnabled('fajr'), isFalse);
    });

    test('Full azan functionality', () async {
      // Test full azan setting
      settingsProvider.setAzanSound('fajr', true, true);
      expect(settingsProvider.isAzanEnabled('fajr'), isTrue);
      expect(settingsProvider.isFullAzanEnabled('fajr'), isTrue);
    });
  });
} 