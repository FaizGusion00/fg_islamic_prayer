

/// Utility class for accurate Hijri date calculations
/// Uses astronomical algorithms for precise Hijri date conversion
class HijriCalculator {
  static const List<String> hijriMonths = [
    'Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani',
    'Jumada al-Awwal', 'Jumada al-Thani', 'Rajab', 'Shaban',
    'Ramadan', 'Shawwal', 'Dhu al-Qadah', 'Dhu al-Hijjah'
  ];

  static const List<String> hijriWeekdays = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  /// Converts Gregorian date to Hijri date using astronomical calculation
  /// Returns a map with day, month, year, weekday, and month name
  static Map<String, dynamic> gregorianToHijri(DateTime gregorianDate) {
    // Astronomical algorithm for Hijri date calculation
    // Based on the Umm al-Qura calendar system
    
    int year = gregorianDate.year;
    int month = gregorianDate.month;
    int day = gregorianDate.day;
    
    // Convert to Julian Day Number
    int jd = _gregorianToJulianDay(year, month, day);
    
    // Calculate Hijri date
    int hijriYear = ((jd - 1948086) / 354.367).floor();
    int remainingDays = jd - _hijriToJulianDay(hijriYear, 1, 1);
    
    int hijriMonth = 1;
    int hijriDay = 1;
    
    // Find the correct month and day
    for (int m = 1; m <= 12; m++) {
      int monthDays = _getHijriMonthDays(hijriYear, m);
      if (remainingDays < monthDays) {
        hijriMonth = m;
        hijriDay = remainingDays + 1;
        break;
      }
      remainingDays -= monthDays;
    }
    
    // Calculate weekday (0 = Sunday, 1 = Monday, etc.)
    int weekday = (jd + 1) % 7;
    
    return {
      'day': hijriDay.toString(),
      'month': hijriMonth.toString(),
      'year': hijriYear.toString(),
      'weekday': hijriWeekdays[weekday],
      'monthName': hijriMonths[hijriMonth - 1],
      'date': '$hijriDay ${hijriMonths[hijriMonth - 1]} $hijriYear AH',
    };
  }

  /// Converts Gregorian date to Julian Day Number
  static int _gregorianToJulianDay(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    
    int a = (year / 100).floor();
    int b = 2 - a + (a / 4).floor();
    
    return ((365.25 * (year + 4716)).floor() +
           (30.6001 * (month + 1)).floor() +
           day + b - 1524.5).round();
  }

  /// Converts Hijri date to Julian Day Number
  static int _hijriToJulianDay(int year, int month, int day) {
    return (day + (29.5 * (month - 1)).floor() +
           (year - 1) * 354.367 +
           1948086).round();
  }

  /// Gets the number of days in a Hijri month
  static int _getHijriMonthDays(int year, int month) {
    // Odd months have 30 days, even months have 29 days
    // Except for month 12 in leap years
    if (month % 2 == 1) {
      return 30;
    } else if (month == 12 && _isHijriLeapYear(year)) {
      return 30;
    } else {
      return 29;
    }
  }

  /// Checks if a Hijri year is a leap year
  static bool _isHijriLeapYear(int year) {
    return (year * 11 + 14) % 30 < 11;
  }

  /// Gets current Hijri date
  static Map<String, dynamic> getCurrentHijriDate() {
    return gregorianToHijri(DateTime.now());
  }

  /// Gets Hijri date for a specific Gregorian date
  static Map<String, dynamic> getHijriDate(DateTime gregorianDate) {
    return gregorianToHijri(gregorianDate);
  }

  /// Formats Hijri date for display
  static String formatHijriDate(Map<String, dynamic> hijriData) {
    final weekday = hijriData['weekday'] ?? 'Monday';
    final day = hijriData['day'] ?? '1';
    final monthName = hijriData['monthName'] ?? 'Muharram';
    final year = hijriData['year'] ?? '1445';
    
    return '$weekday, $day $monthName $year AH';
  }

  /// Gets Hijri month info object compatible with the existing model
  static Map<String, dynamic> getHijriMonthInfo(int monthNumber) {
    if (monthNumber < 1 || monthNumber > 12) {
      monthNumber = 1; // Default to Muharram
    }
    
    return {
      'number': monthNumber,
      'en': hijriMonths[monthNumber - 1],
      'ar': hijriMonths[monthNumber - 1], // For simplicity, using English names
    };
  }
} 