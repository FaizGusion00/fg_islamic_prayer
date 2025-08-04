// ignore_for_file: unused_local_variable

import 'dart:async';
// ignore: unused_import
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions
    await _requestPermissions();
    
    // Create notification channels
    await _createNotificationChannels();
  }

  static Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      // Request notification permission for Android 13+
      final granted = await androidPlugin.requestNotificationsPermission();
      print('Notification permission granted: $granted');
      
      // For exact alarm permissions, we'll rely on the AndroidManifest.xml declarations
      // The app already has SCHEDULE_EXACT_ALARM and USE_EXACT_ALARM permissions declared
      print('Notification permissions requested');
    }
  }

  static Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    // Only create notification channels on Android 8.0+ (API 26+)
    if (androidPlugin != null && Platform.isAndroid && (await _getAndroidSdkInt()) >= 26) {
      try {
        // High priority channel for prayer times with custom sound
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'prayer_notifications',
          'Prayer Time Notifications',
          description: 'Notifications for Islamic prayer times with Azan',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('azan_short'),
          enableVibration: true,
          enableLights: true,
          showBadge: true,
          ledColor: Color.fromARGB(255, 0, 255, 0),
        );
        
        // Channel for prayer times without sound (fallback)
        const AndroidNotificationChannel silentChannel = AndroidNotificationChannel(
          'prayer_notifications_silent',
          'Prayer Time Notifications (Silent)',
          description: 'Silent prayer time notifications with vibration only',
          importance: Importance.max,
          playSound: false,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
          ledColor: Color.fromARGB(255, 0, 255, 0),
        );
        
        // Channel for reminders
        const reminderChannel = AndroidNotificationChannel(
          'reminders',
          'Prayer Reminders',
          description: 'Reminder notifications',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );
        
        // Create a test notification channel
        const testChannel = AndroidNotificationChannel(
          'test_notifications',
          'Test Notifications',
          description: 'Test notification for prayer times',
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound('azan_short'),
          enableVibration: true,
          enableLights: true,
          showBadge: true,
        );
        
        await androidPlugin.createNotificationChannel(channel);
        await androidPlugin.createNotificationChannel(silentChannel);
        await androidPlugin.createNotificationChannel(reminderChannel);
        await androidPlugin.createNotificationChannel(testChannel);
        print('Notification channels created successfully');
      } catch (e) {
        print('Error creating notification channels: $e');
      }
    }
  }

  // Helper to get Android SDK version
  static Future<int> _getAndroidSdkInt() async {
    try {
      final methodChannel = const MethodChannel('com.fgcompany.fgislamic_prayer/sdk');
      final sdkInt = await methodChannel.invokeMethod<int>('getSdkInt');
      return sdkInt ?? 30;
    } catch (_) {
      return 30;
    }
  }

  static void _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null) {
      // Handle notification tap - could navigate to specific screen
      await _playAzan(payload);
    }
  }

  static Future<void> schedulePrayerNotification(
    String prayerName,
    DateTime scheduledTime,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAzanEnabled = prefs.getBool('azan_enabled_${prayerName.toLowerCase()}') ?? true;
      final isFullAzan = prefs.getBool('full_azan_${prayerName.toLowerCase()}') ?? true;
      final isVibrationEnabled = prefs.getBool('vibration_enabled') ?? true;

      int sdkInt = 30;
      if (Platform.isAndroid) {
        sdkInt = await _getAndroidSdkInt();
      }

      // For exact alarm scheduling, we'll rely on AndroidManifest.xml permissions
      // and handle any scheduling errors gracefully
      bool canScheduleExact = true;

      AndroidNotificationDetails androidDetails;
      String channelId = 'prayer_notifications';
      
      try {
        if (Platform.isAndroid && sdkInt < 26) {
          // For old Android, do not set channel or custom sound
          androidDetails = AndroidNotificationDetails(
            channelId,
            'Prayer Time Notifications',
            channelDescription: 'Notifications for Islamic prayer times',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: isVibrationEnabled,
            playSound: isAzanEnabled,
            sound: null, // Use default sound for old Android
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: BigTextStyleInformation(
              _getPrayerMessage(prayerName),
              contentTitle: 'Time for $prayerName Prayer',
              summaryText: 'FGIslamicPrayer',
            ),
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,
            fullScreenIntent: true,
            ongoing: false,
            autoCancel: false,
            showWhen: true,
            timeoutAfter: 60000,
          );
        } else {
          // For Android 8.0+ handle different notification types
          if (isAzanEnabled) {
            // User wants azan sound
            try {
              androidDetails = AndroidNotificationDetails(
                channelId,
                'Prayer Time Notifications',
                channelDescription: 'Notifications for Islamic prayer times',
                importance: Importance.max,
                priority: Priority.high,
                enableVibration: isVibrationEnabled,
                playSound: true,
                sound: isFullAzan 
                    ? const RawResourceAndroidNotificationSound('azan_full')
                    : const RawResourceAndroidNotificationSound('azan_short'),
                icon: '@mipmap/ic_launcher',
                largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                styleInformation: BigTextStyleInformation(
                  _getPrayerMessage(prayerName),
                  contentTitle: 'Time for $prayerName Prayer',
                  summaryText: 'FGIslamicPrayer',
                ),
                category: AndroidNotificationCategory.reminder,
                visibility: NotificationVisibility.public,
                fullScreenIntent: true,
                ongoing: false,
                autoCancel: false,
                showWhen: true,
                timeoutAfter: 60000,
              );
            } catch (soundError) {
              print('Error with sound notification, falling back to silent: $soundError');
              // Fallback to silent channel with separate audio playback
              channelId = 'prayer_notifications_silent';
              androidDetails = AndroidNotificationDetails(
                channelId,
                'Prayer Time Notifications (Silent)',
                channelDescription: 'Silent prayer time notifications with vibration only',
                importance: Importance.max,
                priority: Priority.high,
                enableVibration: isVibrationEnabled,
                playSound: false,
                icon: '@mipmap/ic_launcher',
                largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                styleInformation: BigTextStyleInformation(
                  _getPrayerMessage(prayerName),
                  contentTitle: 'Time for $prayerName Prayer',
                  summaryText: 'FGIslamicPrayer',
                ),
                category: AndroidNotificationCategory.reminder,
                visibility: NotificationVisibility.public,
                fullScreenIntent: true,
                ongoing: false,
                autoCancel: false,
                showWhen: true,
                timeoutAfter: 60000,
              );
            }
          } else {
            // User wants silent notification (no azan sound)
            channelId = 'prayer_notifications_silent';
            androidDetails = AndroidNotificationDetails(
              channelId,
              'Prayer Time Notifications (Silent)',
              channelDescription: 'Silent prayer time notifications with vibration only',
              importance: Importance.max,
              priority: Priority.high,
              enableVibration: isVibrationEnabled,
              playSound: false,
              icon: '@mipmap/ic_launcher',
              largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
              styleInformation: BigTextStyleInformation(
                _getPrayerMessage(prayerName),
                contentTitle: 'Time for $prayerName Prayer',
                summaryText: 'FGIslamicPrayer',
              ),
              category: AndroidNotificationCategory.reminder,
              visibility: NotificationVisibility.public,
              fullScreenIntent: true,
              ongoing: false,
              autoCancel: false,
              showWhen: true,
              timeoutAfter: 60000,
            );
          }
        }
      } catch (e) {
        print('Error creating notification details: $e');
        // Ultimate fallback
        androidDetails = AndroidNotificationDetails(
          'prayer_notifications_silent',
          'Prayer Time Notifications',
          channelDescription: 'Notifications for Islamic prayer times',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: isVibrationEnabled,
          playSound: false,
          icon: '@mipmap/ic_launcher',
        );
      }

      final notificationDetails = NotificationDetails(android: androidDetails);
      final notificationId = _getPrayerNotificationId(prayerName);
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // Schedule the notification
      if (canScheduleExact) {
        await _notifications.zonedSchedule(
          notificationId,
          'Time for $prayerName Prayer',
          _getPrayerMessage(prayerName),
          tzScheduledTime,
          notificationDetails,
          payload: prayerName.toLowerCase(),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        print('Prayer notification scheduled for $prayerName at $scheduledTime');
      } else {
        print('Cannot schedule exact alarms, using approximate scheduling');
        // Fallback to approximate scheduling
        await _notifications.zonedSchedule(
          notificationId,
          'Time for $prayerName Prayer',
          _getPrayerMessage(prayerName),
          tzScheduledTime,
          notificationDetails,
          payload: prayerName.toLowerCase(),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
      
      // If using silent notification channel but user wants azan, schedule audio playback separately
      if (channelId == 'prayer_notifications_silent' && isAzanEnabled) {
        _scheduleAudioPlayback(prayerName, scheduledTime, isFullAzan);
      }
      
    } catch (e) {
      print('Error scheduling prayer notification: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }
  
  static void _scheduleAudioPlayback(String prayerName, DateTime scheduledTime, bool isFullAzan) {
    // Schedule a timer to play audio at the specified time
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    
    if (difference.isNegative) {
      print('Scheduled time is in the past, playing audio immediately');
      _playAzan(prayerName.toLowerCase());
    } else {
      Timer(difference, () {
        _playAzan(prayerName.toLowerCase());
      });
      print('Audio playback scheduled for $prayerName in ${difference.inMinutes} minutes');
    }
  }

  static Future<void> _playAzan(String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    final isAzanEnabled = prefs.getBool('azan_enabled_${prayerName.toLowerCase()}') ?? true;
    final isFullAzan = prefs.getBool('full_azan_${prayerName.toLowerCase()}') ?? true;
    final isVibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
    
    print('_playAzan called for: $prayerName');
    print('Azan enabled: $isAzanEnabled, Full azan: $isFullAzan, Vibration: $isVibrationEnabled');
    
    // Always trigger vibration first if enabled
    if (isVibrationEnabled) {
      try {
        HapticFeedback.heavyImpact();
        print('Vibration triggered successfully');
        
        // Additional vibration pattern for prayer time
        await Future.delayed(const Duration(milliseconds: 200));
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        HapticFeedback.heavyImpact();
      } catch (e) {
        print('Error triggering vibration: $e');
      }
    }
    
    if (isAzanEnabled) {
      try {
        final azanFile = isFullAzan ? 'audio/azan_full.mp3' : 'audio/azan_short.mp3';
        print('Attempting to play azan file: $azanFile');
        
        // Stop any currently playing audio first
        await _audioPlayer.stop();
        
        // Set audio player settings for better compatibility
        await _audioPlayer.setReleaseMode(ReleaseMode.stop);
        await _audioPlayer.setVolume(1.0);
        
        // Play the azan
        await _audioPlayer.play(AssetSource(azanFile));
        print('Azan playback started successfully for: $azanFile');
        
      } catch (e) {
        print('Error playing azan: $e');
        print('Stack trace: ${StackTrace.current}');
        
        // Fallback: try to play a simple beep sound
        try {
          print('Attempting fallback beep sound...');
          // Try system notification sound
          HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          HapticFeedback.heavyImpact();
          print('Fallback beep pattern completed');
        } catch (fallbackError) {
          print('Fallback beep also failed: $fallbackError');
        }
      }
    } else {
      print('Azan is disabled for $prayerName');
    }
  }



  static String _getPrayerMessage(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'It\'s time for Fajr prayer. Start your day with Allah\'s blessings.';
      case 'dhuhr':
        return 'It\'s time for Dhuhr prayer. Take a break and connect with Allah.';
      case 'asr':
        return 'It\'s time for Asr prayer. Remember Allah in the afternoon.';
      case 'maghrib':
        return 'It\'s time for Maghrib prayer. Thank Allah as the day ends.';
      case 'isha':
        return 'It\'s time for Isha prayer. End your day with gratitude to Allah.';
      default:
        return 'It\'s time for $prayerName prayer. Remember Allah.';
    }
  }

  static int _getPrayerNotificationId(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 1;
      case 'dhuhr':
        return 2;
      case 'asr':
        return 3;
      case 'maghrib':
        return 4;
      case 'isha':
        return 5;
      default:
        return 0;
    }
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> cancelPrayerNotification(String prayerName) async {
    await _notifications.cancel(_getPrayerNotificationId(prayerName));
  }



  static Future<void> showTestNotification() async {
    try {
      // Cancel any existing test notification first
      await _notifications.cancel(999);
      
      // Wait a moment before showing new notification
      await Future.delayed(const Duration(milliseconds: 500));
      
      final androidDetails = AndroidNotificationDetails(
         'test_notifications',
         'Test Notifications',
         channelDescription: 'Test notification for prayer times',
         importance: Importance.max,
         priority: Priority.max,
         enableVibration: true,
         playSound: true,
         sound: RawResourceAndroidNotificationSound('azan_short'),
         icon: '@mipmap/ic_launcher',
         largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
         styleInformation: BigTextStyleInformation(
           'This is a test prayer notification from FGIslamicPrayer. If you can see this and hear the sound, notifications are working correctly!',
           contentTitle: 'Test Notification',
           summaryText: 'FGIslamicPrayer Test',
         ),
         category: AndroidNotificationCategory.reminder,
         visibility: NotificationVisibility.public,
         fullScreenIntent: false,
         autoCancel: true,
         ongoing: false,
         showWhen: true,
         when: DateTime.now().millisecondsSinceEpoch,
       );

      final notificationDetails = NotificationDetails(
         android: androidDetails,
       );

      await _notifications.show(
        999,
        'Test Notification',
        'This is a test prayer notification from FGIslamicPrayer',
        notificationDetails,
      );
      
      print('Test notification sent successfully');
    } catch (e) {
      print('Error showing test notification: $e');
    }
    
    print('Test notification sent');
  }

  // Test audio playback directly
  static Future<void> testAudioPlayback({bool fullAzan = false}) async {
    try {
      final azanFile = fullAzan ? 'audio/azan_full.mp3' : 'audio/azan_short.mp3';
      print('Attempting to play: $azanFile');
      
      await _audioPlayer.stop(); // Stop any currently playing audio
      await _audioPlayer.play(AssetSource(azanFile));
      
      print('Audio playback started successfully for: $azanFile');
    } catch (e) {
      print('Error playing audio: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  // Test notification with immediate trigger
  static Future<void> testImmediateNotification({bool fullAzan = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final androidDetails = AndroidNotificationDetails(
        'test_notifications',
        'Test Notifications',
        channelDescription: 'Immediate test notification',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        sound: fullAzan 
            ? const RawResourceAndroidNotificationSound('azan_full')
            : const RawResourceAndroidNotificationSound('azan_short'),
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          fullAzan 
              ? 'Testing full Azan notification - this should play the complete Azan audio'
              : 'Testing short Azan notification - this should play a short tone',
          contentTitle: fullAzan ? 'Full Azan Test' : 'Short Azan Test',
          summaryText: 'FGIslamicPrayer Audio Test',
        ),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
        autoCancel: false,
        timeoutAfter: 30000,
      );

      var notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        fullAzan ? 998 : 997,
        fullAzan ? 'Full Azan Test' : 'Short Azan Test',
        fullAzan 
            ? 'Testing full Azan - should play complete audio'
            : 'Testing short Azan - should play short tone',
        notificationDetails,
        payload: 'test_${fullAzan ? 'full' : 'short'}',
      );
      
      print('${fullAzan ? 'Full' : 'Short'} Azan test notification sent');
      
      // Also test direct audio playback
      await Future.delayed(const Duration(seconds: 2));
      await testAudioPlayback(fullAzan: fullAzan);
      
    } catch (e) {
      print('Error sending test notification: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  static Future<void> scheduleReminderNotification(
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'reminders',
      'Prayer Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> stopAzan() async {
    await _audioPlayer.stop();
  }

  static Future<void> updateNotificationSettings() async {
    // Cancel all existing notifications
    await cancelAllNotifications();
    
    // Notifications will be rescheduled when prayer times are fetched again
  }


}