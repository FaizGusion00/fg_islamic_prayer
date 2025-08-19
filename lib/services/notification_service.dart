// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Location tracking
  static Position? _currentPosition;
  static String? _currentLocationName;
  static StreamSubscription<Position>? _positionStream;
  
  // Notification scheduling
  static final Map<String, int> _prayerNotificationIds = {
    'fajr': 1,
    'dhuhr': 2,
    'asr': 3,
    'maghrib': 4,
    'isha': 5,
  };
  
  static final Map<String, int> _preReminderIds = {
    'fajr': 101,
    'dhuhr': 102,
    'asr': 103,
    'maghrib': 104,
    'isha': 105,
  };

  /// Initialize notification service with proper Android setup
  static Future<void> initialize() async {
    try {
      print('🔔 Initializing Notification Service...');
      
      // Initialize timezone
      tz_data.initializeTimeZones();
      
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestSoundPermission: true,
        requestBadgePermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      // Initialize notifications
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();
      
      // Create notification channels for Android
      await _createNotificationChannels();
      
      // Start location tracking
      await _startLocationTracking();
      
      print('✅ Notification Service initialized successfully');
    } catch (e) {
      print('❌ Error initializing Notification Service: $e');
    }
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    try {
      // Android permissions
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        // Request notification permission for Android 13+
        final granted = await androidPlugin.requestNotificationsPermission();
        print('🔔 Android notification permission: $granted');
        
        // Request exact alarm permission for Android 12+
        try {
          final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
          print('⏰ Exact alarms permission: $exactAlarmGranted');
        } catch (e) {
          print('⏰ Exact alarms permission not supported: $e');
        }
      }

      // iOS permissions
      final darwinPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (darwinPlugin != null) {
        final granted = await darwinPlugin.requestPermissions(
          alert: true,
          sound: true,
          badge: true,
        );
        print('🍎 iOS notification permissions: $granted');
      }
    } catch (e) {
      print('❌ Error requesting permissions: $e');
    }
  }

  /// Create notification channels for Android 8.0+
  static Future<void> _createNotificationChannels() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null && Platform.isAndroid) {
        // Prayer notification channels
        const prayerChannel = AndroidNotificationChannel(
          'prayer_notifications',
          'Prayer Time Notifications',
          description: 'Notifications for Islamic prayer times with Adhan',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('azan_short'),
          enableVibration: true,
          enableLights: true,
          showBadge: true,
          ledColor: Color.fromARGB(255, 0, 255, 0),
        );

        const fullAzanChannel = AndroidNotificationChannel(
          'full_azan_notifications',
          'Full Adhan Notifications',
          description: 'Prayer notifications with full Adhan recitation',
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('azan_full'),
          enableVibration: true,
          enableLights: true,
          showBadge: true,
          ledColor: Color.fromARGB(255, 0, 255, 0),
        );

        const silentChannel = AndroidNotificationChannel(
          'silent_notifications',
          'Silent Notifications',
          description: 'Silent prayer notifications with vibration only',
          importance: Importance.high,
          playSound: false,
          enableVibration: true,
          enableLights: true,
          showBadge: true,
        );

        const reminderChannel = AndroidNotificationChannel(
          'reminder_notifications',
          'Prayer Reminders',
          description: 'Pre-prayer reminder notifications',
          importance: Importance.high,
          playSound: false,
          enableVibration: true,
          enableLights: true,
        );

        // Create all channels
        await androidPlugin.createNotificationChannel(prayerChannel);
        await androidPlugin.createNotificationChannel(fullAzanChannel);
        await androidPlugin.createNotificationChannel(silentChannel);
        await androidPlugin.createNotificationChannel(reminderChannel);
        
        print('✅ Notification channels created successfully');
      }
    } catch (e) {
      print('❌ Error creating notification channels: $e');
    }
  }

  /// Start location tracking and auto-detection
  static Future<void> _startLocationTracking() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Location permission denied');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Location permission permanently denied');
        return;
      }

      // Get current position
      await _getCurrentLocation();
      
      // Start position stream for continuous updates
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100, // Update every 100 meters
        ),
      ).listen(
        (Position position) {
          _currentPosition = position;
          _updateLocationName(position);
          print('📍 Location updated: ${position.latitude}, ${position.longitude}');
        },
        onError: (error) {
          print('❌ Location stream error: $error');
        },
      );
      
      print('✅ Location tracking started');
    } catch (e) {
      print('❌ Error starting location tracking: $e');
    }
  }

  /// Get current location
  static Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      await _updateLocationName(_currentPosition!);
      print('📍 Current location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
    } catch (e) {
      print('❌ Error getting current location: $e');
    }
  }

  /// Update location name from coordinates
  static Future<void> _updateLocationName(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        _currentLocationName = '${place.locality ?? ''}, ${place.administrativeArea ?? ''}'.trim();
        if (_currentLocationName!.isEmpty) {
          _currentLocationName = place.country ?? 'Unknown Location';
        }
        print('📍 Location name: $_currentLocationName');
      }
    } catch (e) {
      print('❌ Error updating location name: $e');
      _currentLocationName = 'Unknown Location';
    }
  }

  /// Get current position (public access)
  static Position? get currentPosition => _currentPosition;
  
  /// Get current location name (public access)
  static String? get currentLocationName => _currentLocationName;

  /// Force refresh current location
  static Future<void> refreshLocation() async {
    await _getCurrentLocation();
  }

  /// Schedule prayer notification with proper Android handling
  static Future<void> schedulePrayerNotification(
    String prayerName,
    DateTime scheduledTime, {
    bool isFullAzan = false,
    bool enablePreReminder = true,
  }) async {
    try {
      print('🔔 Scheduling notification for $prayerName at $scheduledTime');
      
      final prefs = await SharedPreferences.getInstance();
      final isAzanEnabled = prefs.getBool('azan_enabled_${prayerName.toLowerCase()}') ?? true;
      final isVibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      final isNotificationEnabled = prefs.getBool('notification_${prayerName.toLowerCase()}') ?? true;

      if (!isNotificationEnabled) {
        print('❌ Notification disabled for $prayerName');
        return;
      }

      // Schedule pre-reminder if enabled
      if (enablePreReminder) {
        final preReminderTime = scheduledTime.subtract(const Duration(minutes: 30));
        if (preReminderTime.isAfter(DateTime.now())) {
          await _schedulePreReminder(prayerName, preReminderTime);
        }
      }

      // Determine notification channel and sound
      String channelId;
      String soundFile;
      
      if (!isAzanEnabled) {
        channelId = 'silent_notifications';
        soundFile = '';
      } else if (isFullAzan) {
        channelId = 'full_azan_notifications';
        soundFile = 'azan_full';
      } else {
        channelId = 'prayer_notifications';
        soundFile = 'azan_short';
      }

      // Create notification details
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelId == 'silent_notifications' ? 'Silent Notifications' : 'Prayer Notifications',
        channelDescription: 'Prayer time notifications',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: isVibrationEnabled,
        playSound: channelId != 'silent_notifications',
        sound: channelId != 'silent_notifications' ? RawResourceAndroidNotificationSound(soundFile) : null,
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
        timeoutAfter: 60000, // 1 minute timeout
      );

      final iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: channelId != 'silent_notifications',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      final notificationId = _prayerNotificationIds[prayerName.toLowerCase()] ?? 0;
      final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // Schedule the notification with exact timing
      await _notifications.zonedSchedule(
        notificationId,
        'Time for $prayerName Prayer',
        _getPrayerMessage(prayerName),
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: prayerName.toLowerCase(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ Prayer notification scheduled for $prayerName at $scheduledTime');
      
      // Also schedule audio playback for better reliability
      if (isAzanEnabled) {
        _scheduleAudioPlayback(prayerName, scheduledTime, isFullAzan);
      }
      
    } catch (e) {
      print('❌ Error scheduling prayer notification: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  /// Schedule pre-reminder notification
  static Future<void> _schedulePreReminder(String prayerName, DateTime reminderTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isVibrationEnabled = prefs.getBool('vibration_enabled') ?? true;

      final androidDetails = AndroidNotificationDetails(
        'reminder_notifications',
        'Prayer Reminders',
        channelDescription: 'Pre-prayer reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: isVibrationEnabled,
        playSound: false,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          'Reminder: $prayerName will begin in 30 minutes. Prepare yourself.',
          contentTitle: '$prayerName in 30 minutes',
          summaryText: 'FGIslamicPrayer Reminder',
        ),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        fullScreenIntent: false,
        ongoing: false,
        autoCancel: true,
        showWhen: true,
      );

      const iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      final notificationId = _preReminderIds[prayerName.toLowerCase()] ?? 100;
      final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);

      await _notifications.zonedSchedule(
        notificationId,
        '$prayerName in 30 minutes',
        'Reminder: $prayerName will begin in 30 minutes. Prepare yourself.',
        tzReminderTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'pre_${prayerName.toLowerCase()}',
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ Pre-reminder scheduled for $prayerName at $reminderTime');
    } catch (e) {
      print('❌ Error scheduling pre-reminder: $e');
    }
  }

  /// Schedule audio playback as backup
  static void _scheduleAudioPlayback(String prayerName, DateTime scheduledTime, bool isFullAzan) {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    
    if (difference.isNegative) {
      print('⚠️ Scheduled time is in the past, playing audio immediately');
      _playAzan(prayerName.toLowerCase(), isFullAzan);
    } else {
      Timer(difference, () {
        _playAzan(prayerName.toLowerCase(), isFullAzan);
      });
      print('🎵 Audio playback scheduled for $prayerName in ${difference.inMinutes} minutes');
    }
  }

  /// Play Adhan audio with proper error handling
  static Future<void> _playAzan(String prayerName, bool isFullAzan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAzanEnabled = prefs.getBool('azan_enabled_${prayerName.toLowerCase()}') ?? true;
      final isVibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      
      print('🎵 Playing Adhan for: $prayerName (Full: $isFullAzan)');
      
      // Trigger vibration first
      if (isVibrationEnabled) {
        try {
          HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 200));
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 200));
          HapticFeedback.heavyImpact();
          print('📳 Vibration triggered successfully');
        } catch (e) {
          print('❌ Error triggering vibration: $e');
        }
      }
      
      if (isAzanEnabled) {
        try {
          // Stop any currently playing audio
          await _audioPlayer.stop();
          
          // Set audio player settings
          await _audioPlayer.setReleaseMode(ReleaseMode.stop);
          await _audioPlayer.setVolume(1.0);
          
          // Determine audio file
          final azanFile = isFullAzan ? 'audio/azan_full.mp3' : 'audio/azan_short.mp3';
          print('🎵 Playing audio file: $azanFile');
          
          // Play the Adhan
          await _audioPlayer.play(AssetSource(azanFile));
          print('✅ Adhan playback started successfully');
          
        } catch (e) {
          print('❌ Error playing Adhan: $e');
          // Fallback to vibration pattern
          _playFallbackPattern();
        }
      } else {
        print('🔇 Adhan is disabled for $prayerName');
      }
    } catch (e) {
      print('❌ Error in _playAzan: $e');
    }
  }

  /// Fallback vibration pattern when audio fails
  static void _playFallbackPattern() {
    try {
      Timer.periodic(const Duration(milliseconds: 500), (timer) {
        HapticFeedback.heavyImpact();
        if (timer.tick >= 6) { // 3 seconds of vibration
          timer.cancel();
        }
      });
      print('📳 Fallback vibration pattern activated');
    } catch (e) {
      print('❌ Fallback pattern failed: $e');
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null) {
      print('👆 Notification tapped with payload: $payload');
      // Could navigate to specific screen or perform action
      if (payload.startsWith('pre_')) {
        // Pre-reminder tapped
        print('⏰ Pre-reminder notification tapped');
      } else {
        // Main prayer notification tapped
        print('🕌 Prayer notification tapped');
      }
    }
  }

  /// Get prayer message
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

  /// Test notification functionality
  static Future<void> showTestNotification({bool fullAzan = false}) async {
    try {
      await _notifications.cancel(999);
      await Future.delayed(const Duration(milliseconds: 500));
      
      final androidDetails = AndroidNotificationDetails(
        'prayer_notifications',
        'Prayer Notifications',
        channelDescription: 'Test notification',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        sound: fullAzan 
            ? const RawResourceAndroidNotificationSound('azan_full')
            : const RawResourceAndroidNotificationSound('azan_short'),
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: const BigTextStyleInformation(
          'This is a test prayer notification. If you can see this and hear the sound, notifications are working correctly!',
          contentTitle: 'Test Notification',
          summaryText: 'FGIslamicPrayer Test',
        ),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        fullScreenIntent: false,
        autoCancel: true,
        ongoing: false,
        showWhen: true,
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        999,
        'Test Notification',
        'Test prayer notification from FGIslamicPrayer',
        notificationDetails,
      );
      
      print('✅ Test notification sent successfully');
      
      // Test audio playback
      await Future.delayed(const Duration(seconds: 2));
      await _playAzan('test', fullAzan);
      
    } catch (e) {
      print('❌ Error showing test notification: $e');
    }
  }

  /// Test audio playback directly
  static Future<void> testAudioPlayback({bool fullAzan = false}) async {
    try {
      await _audioPlayer.stop();
      await _playAzan('test', fullAzan);
    } catch (e) {
      print('❌ Error testing audio playback: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling notifications: $e');
    }
  }

  /// Cancel specific prayer notification
  static Future<void> cancelPrayerNotification(String prayerName) async {
    try {
      final notificationId = _prayerNotificationIds[prayerName.toLowerCase()];
      if (notificationId != null) {
        await _notifications.cancel(notificationId);
        print('✅ Cancelled notification for $prayerName');
      }
    } catch (e) {
      print('❌ Error cancelling prayer notification: $e');
    }
  }

  /// Stop Adhan audio
  static Future<void> stopAzan() async {
    try {
      await _audioPlayer.stop();
      print('🔇 Adhan stopped');
    } catch (e) {
      print('❌ Error stopping Adhan: $e');
    }
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Update notification settings and reschedule
  static Future<void> updateNotificationSettings() async {
    try {
      await cancelAllNotifications();
      print('✅ Notification settings updated, all notifications cancelled');
      // Notifications will be rescheduled when prayer times are fetched
    } catch (e) {
      print('❌ Error updating notification settings: $e');
    }
  }

  /// Dispose resources
  static void dispose() {
    _positionStream?.cancel();
    _audioPlayer.dispose();
  }

  /// Check notification permissions (for compatibility)
  static Future<bool> checkNotificationPermissions() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final areNotificationsEnabled = await androidPlugin.areNotificationsEnabled();
        return areNotificationsEnabled ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Error checking notification permissions: $e');
      return false;
    }
  }

  /// Schedule pre-reminder notification (for compatibility)
  static Future<void> schedulePreReminderNotification(
    String prayerName,
    DateTime scheduledTime,
  ) async {
    try {
      final preReminderTime = scheduledTime.subtract(const Duration(minutes: 30));
      if (preReminderTime.isAfter(DateTime.now())) {
        await _schedulePreReminder(prayerName, preReminderTime);
      }
    } catch (e) {
      print('❌ Error scheduling pre-reminder notification: $e');
    }
  }
}