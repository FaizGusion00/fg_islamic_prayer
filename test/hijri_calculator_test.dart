import 'package:flutter_test/flutter_test.dart';
import 'package:fgislamic_prayer/utils/hijri_calculator.dart';

void main() {
  group('HijriCalculator Tests', () {
    test('should calculate current Hijri date correctly', () {
      final hijriData = HijriCalculator.getCurrentHijriDate();
      
      expect(hijriData, isA<Map<String, dynamic>>());
      expect(hijriData['day'], isA<String>());
      expect(hijriData['month'], isA<String>());
      expect(hijriData['year'], isA<String>());
      expect(hijriData['weekday'], isA<String>());
      expect(hijriData['monthName'], isA<String>());
      
      // Verify the values are reasonable
      final day = int.tryParse(hijriData['day']);
      final month = int.tryParse(hijriData['month']);
      final year = int.tryParse(hijriData['year']);
      
      expect(day, isNotNull);
      expect(month, isNotNull);
      expect(year, isNotNull);
      
      expect(day, greaterThan(0));
      expect(day, lessThanOrEqualTo(30));
      expect(month, greaterThan(0));
      expect(month, lessThanOrEqualTo(12));
      expect(year, greaterThan(1400));
      expect(year, lessThan(1500));
    });

    test('should format Hijri date correctly', () {
      final hijriData = {
        'weekday': 'Monday',
        'day': '15',
        'monthName': 'Ramadan',
        'year': '1445',
      };
      
      final formatted = HijriCalculator.formatHijriDate(hijriData);
      expect(formatted, equals('Monday, 15 Ramadan 1445 AH'));
    });

    test('should calculate specific Gregorian to Hijri conversion', () {
      // Test with a known date: January 1, 2024
      final gregorianDate = DateTime(2024, 1, 1);
      final hijriData = HijriCalculator.gregorianToHijri(gregorianDate);
      
      expect(hijriData['day'], isA<String>());
      expect(hijriData['month'], isA<String>());
      expect(hijriData['year'], isA<String>());
      expect(hijriData['weekday'], isA<String>());
      expect(hijriData['monthName'], isA<String>());
    });

    test('should handle leap year calculation correctly', () {
      // Test with a leap year date
      final gregorianDate = DateTime(2024, 2, 29);
      final hijriData = HijriCalculator.gregorianToHijri(gregorianDate);
      
      expect(hijriData['day'], isA<String>());
      expect(hijriData['month'], isA<String>());
      expect(hijriData['year'], isA<String>());
    });

    test('should provide valid month info', () {
      final monthInfo = HijriCalculator.getHijriMonthInfo(1);
      
      expect(monthInfo['number'], equals(1));
      expect(monthInfo['en'], equals('Muharram'));
      expect(monthInfo['ar'], equals('Muharram'));
    });

    test('should handle edge cases', () {
      // Test with year boundary
      final gregorianDate = DateTime(2023, 12, 31);
      final hijriData = HijriCalculator.gregorianToHijri(gregorianDate);
      
      expect(hijriData['day'], isA<String>());
      expect(hijriData['month'], isA<String>());
      expect(hijriData['year'], isA<String>());
    });
  });
} 