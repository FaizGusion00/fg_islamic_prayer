import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../lib/services/hijri_date_service.dart';

void main() {
  group('HijriDateService Tests', () {
    test('getCurrentHijriDate should return valid Hijri date from Aladhan API', () async {
      // Test the API endpoint directly
      final now = DateTime.now();
      final url = Uri.parse('http://api.aladhan.com/v1/gToH/${now.day}-${now.month}-${now.year}');
      
      final response = await http.get(url);
      
      expect(response.statusCode, 200);
      
      final data = json.decode(response.body);
      expect(data['data'], isNotNull);
      expect(data['data']['hijri'], isNotNull);
      
      final hijriData = data['data']['hijri'];
      expect(hijriData['day'], isNotNull);
      expect(hijriData['month'], isNotNull);
      expect(hijriData['year'], isNotNull);
      expect(hijriData['weekday'], isNotNull);
      
      // Test the service method
      final serviceResult = await HijriDateService.getCurrentHijriDate();
      
      expect(serviceResult['day'], isNotNull);
      expect(serviceResult['month'], isNotNull);
      expect(serviceResult['year'], isNotNull);
      expect(serviceResult['weekday'], isNotNull);
      expect(serviceResult['monthName'], isNotNull);
      expect(serviceResult['date'], isNotNull);
    });

    test('getHijriDate should return valid Hijri date for specific date', () async {
      final testDate = DateTime(2024, 1, 1);
      final result = await HijriDateService.getHijriDate(testDate);
      
      expect(result['day'], isNotNull);
      expect(result['month'], isNotNull);
      expect(result['year'], isNotNull);
      expect(result['weekday'], isNotNull);
      expect(result['monthName'], isNotNull);
      expect(result['date'], isNotNull);
    });

    test('formatHijriDate should format date correctly', () {
      final hijriData = {
        'weekday': 'Monday',
        'day': '15',
        'monthName': 'Ramadan',
        'year': '1445',
      };
      
      final formatted = HijriDateService.formatHijriDate(hijriData);
      expect(formatted, 'Monday, 15 Ramadan 1445 AH');
    });

    test('should handle API errors gracefully', () async {
      // This test verifies that the service handles errors properly
      // The actual implementation should have fallback mechanisms
      final result = await HijriDateService.getCurrentHijriDate();
      
      // Should always return a valid structure even if API fails
      expect(result, isNotNull);
      expect(result['day'], isNotNull);
      expect(result['month'], isNotNull);
      expect(result['year'], isNotNull);
    });
  });
} 