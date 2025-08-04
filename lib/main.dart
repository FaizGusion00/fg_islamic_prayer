import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;
import 'providers/prayer_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/qibla_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/donation_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/license_screen.dart';
import 'utils/theme.dart';
import 'services/notification_service.dart';
import 'utils/performance_optimizer.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone data
  tz.initializeTimeZones();
  
  // Initialize notifications
  await NotificationService.initialize();
  
  // Initialize performance optimizations
  await PerformanceOptimizer.initialize();
  
  // Request permissions
  await _requestPermissions();
  
  runApp(const FGIslamicPrayerApp());
}

Future<void> _requestPermissions() async {
  await Permission.location.request();
  if (Platform.isAndroid) {
    // Request notification permission for Android 13+
    if (await Permission.notification.isDenied || await Permission.notification.isRestricted) {
      final status = await Permission.notification.request();
      print('Notification permission status: ' + status.toString());
    } else {
      print('Notification permission already granted or not required.');
    }
  }
}

class FGIslamicPrayerApp extends StatelessWidget {
  const FGIslamicPrayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => QiblaProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'FGIslamicPrayer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/qibla': (context) => const QiblaScreen(),
              '/donation': (context) => const DonationScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/license': (context) => const LicenseScreen(),
            },
          );
        },
      ),
    );
  }
}