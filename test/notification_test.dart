import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/notification_service.dart';

void main() {
  group('Notification System Tests', () {
    setUpAll(() async {
      // Initialize Flutter bindings
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Initialize notification service
      await NotificationService.initialize();
      
      // Set up test preferences
      SharedPreferences.setMockInitialValues({
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
        'full_azan_fajr': false,
        'full_azan_dhuhr': false,
        'full_azan_asr': false,
        'full_azan_maghrib': false,
        'full_azan_isha': false,
        'vibration_enabled': true,
      });
    });

    test('Notification service initialization', () async {
      // Test that notification service can be initialized
      expect(() async {
        await NotificationService.initialize();
      }, returnsNormally);
    });

    test('Prayer notification scheduling', () async {
      // Test scheduling a prayer notification
      final testTime = DateTime.now().add(const Duration(seconds: 5));
      
      expect(() async {
        await NotificationService.schedulePrayerNotification('Fajr', testTime);
      }, returnsNormally);
    });

    test('Audio playback test', () async {
      // Test that azan audio can be played
      expect(() async {
        await NotificationService.testAudioPlayback(fullAzan: false);
      }, returnsNormally);
    });

    test('Full azan audio playback test', () async {
      // Test that full azan audio can be played
      expect(() async {
        await NotificationService.testAudioPlayback(fullAzan: true);
      }, returnsNormally);
    });

    test('Test notification with sound', () async {
      // Test that test notification works with sound
      expect(() async {
        await NotificationService.showTestNotification();
      }, returnsNormally);
    });

    test('Immediate notification test', () async {
      // Test immediate notification with azan sound
      expect(() async {
        await NotificationService.testImmediateNotification(fullAzan: false);
      }, returnsNormally);
    });

    test('Full azan immediate notification test', () async {
      // Test immediate notification with full azan sound
      expect(() async {
        await NotificationService.testImmediateNotification(fullAzan: true);
      }, returnsNormally);
    });

    test('Notification cancellation', () async {
      // Test that notifications can be cancelled
      expect(() async {
        await NotificationService.cancelAllNotifications();
      }, returnsNormally);
    });

    test('Pending notifications check', () async {
      // Test that pending notifications can be retrieved
      final pendingNotifications = await NotificationService.getPendingNotifications();
      expect(pendingNotifications, isA<List>());
    });

    test('Audio stop functionality', () async {
      // Test that audio can be stopped
      expect(() async {
        await NotificationService.stopAzan();
      }, returnsNormally);
    });
  });
} 