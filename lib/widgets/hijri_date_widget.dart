import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/prayer_provider.dart';
import '../utils/theme.dart';
import '../services/hijri_date_service.dart';

class HijriDateWidget extends StatefulWidget {
  const HijriDateWidget({super.key});

  @override
  State<HijriDateWidget> createState() => _HijriDateWidgetState();
}

class _HijriDateWidgetState extends State<HijriDateWidget> {
  Map<String, dynamic>? _hijriData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHijriDate();
  }

  Future<void> _loadHijriDate() async {
    try {
      final hijriData = await HijriDateService.getCurrentHijriDate();
      if (mounted) {
        setState(() {
          _hijriData = hijriData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<PrayerProvider>(
      builder: (context, prayerProvider, child) {
        final prayerTimes = prayerProvider.prayerTimes;
        final gregorianDate = prayerTimes?.date?.gregorian;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal).withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Calendar Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              
              // Date Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gregorian Date
                    Text(
                      _getGregorianDateString(gregorianDate),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    
                    // Hijri Date
                    if (_isLoading)
                      Text(
                        'Loading Hijri date...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else if (_hijriData != null)
                      Text(
                        HijriDateService.formatHijriDate(_hijriData!),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      Text(
                        'Hijri date unavailable',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Islamic Calendar Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.mosque_outlined,
                  color: isDarkMode ? AppTheme.primaryGold : AppTheme.primaryTeal,
                  size: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGregorianDateString(dynamic gregorianDate) {
    if (gregorianDate != null) {
      try {
        final day = gregorianDate.day ?? DateTime.now().day.toString();
        final month = gregorianDate.month ?? _getCurrentMonthName();
        final year = gregorianDate.year ?? DateTime.now().year.toString();
        final weekday = gregorianDate.weekday ?? _getCurrentWeekdayName();
        
        return '$weekday, $day $month $year';
      } catch (e) {
        // Fallback to current date
        return DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
      }
    }
    
    // Fallback to current date
    return DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
  }



  String _getCurrentMonthName() {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[DateTime.now().month - 1];
  }

  String _getCurrentWeekdayName() {
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return weekdays[DateTime.now().weekday - 1];
  }
}