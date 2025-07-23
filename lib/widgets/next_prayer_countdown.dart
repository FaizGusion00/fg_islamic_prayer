import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/prayer_provider.dart';
import '../utils/theme.dart';

class NextPrayerCountdown extends StatefulWidget {
  const NextPrayerCountdown({super.key});

  @override
  State<NextPrayerCountdown> createState() => _NextPrayerCountdownState();
}

class _NextPrayerCountdownState extends State<NextPrayerCountdown> {
  Timer? _timer;
  Duration? _timeRemaining;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        final prayerProvider = context.read<PrayerProvider>();
        setState(() {
          _timeRemaining = prayerProvider.getTimeUntilNextPrayer();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerProvider>(
      builder: (context, prayerProvider, child) {
        final nextPrayer = prayerProvider.getNextPrayer();
        final timeUntilNext = _timeRemaining ?? prayerProvider.getTimeUntilNextPrayer();
        
        if (nextPrayer == null || timeUntilNext == null) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [AppTheme.primaryTeal, AppTheme.emeraldGreen]
                  : [AppTheme.primaryTeal, AppTheme.emeraldGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Next Prayer Label
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Next Prayer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Prayer Name
              Text(
                nextPrayer,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Countdown Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeUnit(
                      timeUntilNext.inHours.toString().padLeft(2, '0'),
                      'Hours',
                    ),
                    _buildTimeSeparator(),
                    _buildTimeUnit(
                      (timeUntilNext.inMinutes % 60).toString().padLeft(2, '0'),
                      'Minutes',
                    ),
                    _buildTimeSeparator(),
                    _buildTimeUnit(
                      (timeUntilNext.inSeconds % 60).toString().padLeft(2, '0'),
                      'Seconds',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Motivational Text
              Text(
                _getMotivationalText(nextPrayer),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        ':',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getMotivationalText(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'Start your day with Allah\'s blessings';
      case 'dhuhr':
        return 'Take a moment to remember Allah';
      case 'asr':
        return 'Pause and connect with your Creator';
      case 'maghrib':
        return 'Thank Allah as the day comes to an end';
      case 'isha':
        return 'End your day in gratitude and peace';
      default:
        return 'Prepare your heart for prayer';
    }
  }
}