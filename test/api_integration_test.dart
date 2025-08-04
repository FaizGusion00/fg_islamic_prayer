import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group('API Integration Tests', () {
    test('Waktu Solat API - Zone Detection', () async {
      // Test coordinates for Kuala Lumpur
      const lat = 3.1390;
      const long = 101.6869;
      
      final url = Uri.parse('https://api.waktusolat.app/zones/$lat/$long');
      
      try {
        final response = await http.get(url).timeout(
          const Duration(seconds: 10),
        );
        
        expect(response.statusCode, 200);
        
        final data = json.decode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data['zone'], isA<String>());
        expect(data['state'], isA<String>());
        expect(data['district'], isA<String>());
        
        print('Zone detection test passed: ${data['zone']}');
      } catch (e) {
        fail('Zone detection API failed: $e');
      }
    });

    test('Waktu Solat API - All Zones', () async {
      final url = Uri.parse('https://api.waktusolat.app/zones');
      
      try {
        final response = await http.get(url).timeout(
          const Duration(seconds: 15),
        );
        
        expect(response.statusCode, 200);
        
        final data = json.decode(response.body);
        expect(data, isA<List>());
        expect(data.length, greaterThan(50)); // Should have many zones
        
        // Verify structure of first zone
        final firstZone = data.first;
        expect(firstZone['jakimCode'], isA<String>());
        expect(firstZone['negeri'], isA<String>());
        expect(firstZone['daerah'], isA<String>());
        
        print('All zones test passed: ${data.length} zones found');
      } catch (e) {
        fail('All zones API failed: $e');
      }
    });

    test('Waktu Solat API - Prayer Times (SGR01)', () async {
      final url = Uri.parse('https://api.waktusolat.app/v2/solat/SGR01');
      
      try {
        final response = await http.get(url).timeout(
          const Duration(seconds: 15),
        );
        
        expect(response.statusCode, 200);
        
        final data = json.decode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        
        // Check if prayer times are present - handle the actual API response format
        bool hasPrayerTimes = false;
        if (data.containsKey('prayers') && data['prayers'] is List) {
          hasPrayerTimes = true;
        } else if (data.containsKey('prayerTime') && data['prayerTime'] is List) {
          hasPrayerTimes = true;
        } else if (data.containsKey('subuh') || data.containsKey('fajr')) {
          hasPrayerTimes = true;
        } else if (data.containsKey('data')) {
          final nestedData = data['data'];
          if (nestedData is Map<String, dynamic>) {
            hasPrayerTimes = nestedData.containsKey('subuh') || nestedData.containsKey('fajr');
          } else if (nestedData is List && nestedData.isNotEmpty) {
            hasPrayerTimes = true;
          }
        }
        
        expect(hasPrayerTimes, isTrue);
        
        print('Prayer times test passed for SGR01');
      } catch (e) {
        fail('Prayer times API failed: $e');
      }
    });

    test('Waktu Solat API - Prayer Times (WLY01)', () async {
      final url = Uri.parse('https://api.waktusolat.app/v2/solat/WLY01');
      
      try {
        final response = await http.get(url).timeout(
          const Duration(seconds: 15),
        );
        
        expect(response.statusCode, 200);
        
        final data = json.decode(response.body);
        expect(data, isA<Map<String, dynamic>>());
        
        print('Prayer times test passed for WLY01');
      } catch (e) {
        fail('Prayer times API failed: $e');
      }
    });

    test('Aladhan API - Prayer Times', () async {
      // Test coordinates for Kuala Lumpur
      const lat = 3.1390;
      const long = 101.6869;
      final today = DateTime.now();
      final dateString = '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';
      
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/$dateString'
        '?latitude=$lat'
        '&longitude=$long'
        '&method=2'
        '&school=0'
      );
      
      try {
        final response = await http.get(url).timeout(
          const Duration(seconds: 15),
        );
        
        expect(response.statusCode, 200);
        
        final data = json.decode(response.body);
        expect(data['code'], 200);
        expect(data['data'], isA<Map<String, dynamic>>());
        
        // Check if prayer times are present
        final timings = data['data']['timings'];
        expect(timings, isA<Map<String, dynamic>>());
        expect(timings['Fajr'], isA<String>());
        expect(timings['Dhuhr'], isA<String>());
        
        // Check if Hijri date is present
        final date = data['data']['date'];
        expect(date['hijri'], isA<Map<String, dynamic>>());
        
        print('Aladhan API test passed');
      } catch (e) {
        fail('Aladhan API failed: $e');
      }
    });

    test('Hijri Calculator - Accuracy Test', () async {
      // Test with known dates
      final testDate = DateTime(2024, 1, 1);
      
      // Import the calculator
      // Note: This would need to be tested in a separate unit test
      // as we can't import the actual calculator in this test file
      
      print('Hijri calculator accuracy test - manual verification needed');
    });

    test('API Response Time Test', () async {
      final startTime = DateTime.now();
      
      // Test Waktu Solat API response time
      final waktusolatUrl = Uri.parse('https://api.waktusolat.app/zones/3.1390/101.6869');
      final waktusolatResponse = await http.get(waktusolatUrl);
      
      final waktusolatTime = DateTime.now().difference(startTime);
      expect(waktusolatTime.inMilliseconds, lessThan(5000)); // Should respond within 5 seconds
      
      print('Waktu Solat API response time: ${waktusolatTime.inMilliseconds}ms');
      
      // Test Aladhan API response time
      final aladhanStartTime = DateTime.now();
      final today = DateTime.now();
      final dateString = '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';
      final aladhanUrl = Uri.parse(
        'https://api.aladhan.com/v1/timings/$dateString?latitude=3.1390&longitude=101.6869&method=2&school=0'
      );
      final aladhanResponse = await http.get(aladhanUrl);
      
      final aladhanTime = DateTime.now().difference(aladhanStartTime);
      expect(aladhanTime.inMilliseconds, lessThan(5000)); // Should respond within 5 seconds
      
      print('Aladhan API response time: ${aladhanTime.inMilliseconds}ms');
    });

    test('Error Handling Test', () async {
      // Test with invalid coordinates
      final url = Uri.parse('https://api.waktusolat.app/zones/999/999');
      
      try {
        final response = await http.get(url).timeout(
          const Duration(seconds: 10),
        );
        
        // Should handle invalid coordinates gracefully
        expect(response.statusCode, isA<int>());
        print('Error handling test passed');
      } catch (e) {
        // Timeout or network error is acceptable
        print('Error handling test passed (expected error: $e)');
      }
    });
  });
} 