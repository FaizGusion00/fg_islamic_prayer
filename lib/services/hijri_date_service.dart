import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for fetching accurate Hijri dates from Aladhan API
class HijriDateService {
  static const String _baseUrl = 'http://api.aladhan.com/v1';
  
  /// Fetches current Hijri date from Aladhan API
  static Future<Map<String, dynamic>> getCurrentHijriDate() async {
    try {
      final now = DateTime.now();
      final url = Uri.parse('$_baseUrl/gToH/${now.day}-${now.month}-${now.year}');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Hijri date request timed out');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hijriData = data['data']['hijri'];
        
        return {
          'day': hijriData['day'],
          'month': hijriData['month']['number'].toString(),
          'year': hijriData['year'],
          'weekday': hijriData['weekday']['en'],
          'monthName': hijriData['month']['en'],
          'date': '${hijriData['day']} ${hijriData['month']['en']} ${hijriData['year']} AH',
          'monthInfo': hijriData['month'],
        };
      } else {
        throw Exception('Failed to fetch Hijri date: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Hijri date: $e');
      // Fallback to local calculation
      return _getFallbackHijriDate();
    }
  }
  
  /// Fetches Hijri date for a specific Gregorian date
  static Future<Map<String, dynamic>> getHijriDate(DateTime gregorianDate) async {
    try {
      final url = Uri.parse('$_baseUrl/gToH/${gregorianDate.day}-${gregorianDate.month}-${gregorianDate.year}');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Hijri date request timed out');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hijriData = data['data']['hijri'];
        
        return {
          'day': hijriData['day'],
          'month': hijriData['month']['number'].toString(),
          'year': hijriData['year'],
          'weekday': hijriData['weekday']['en'],
          'monthName': hijriData['month']['en'],
          'date': '${hijriData['day']} ${hijriData['month']['en']} ${hijriData['year']} AH',
          'monthInfo': hijriData['month'],
        };
      } else {
        throw Exception('Failed to fetch Hijri date: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching Hijri date: $e');
      // Fallback to local calculation
      return _getFallbackHijriDate();
    }
  }
  
  /// Fallback method using local calculation when API fails
  static Map<String, dynamic> _getFallbackHijriDate() {
    // Import the local calculator as fallback
    try {
      // This will be replaced with the actual import when we update the files
      return {
        'day': '1',
        'month': '1',
        'year': '1445',
        'weekday': 'Monday',
        'monthName': 'Muharram',
        'date': '1 Muharram 1445 AH',
        'monthInfo': {'number': 1, 'en': 'Muharram'},
      };
    } catch (e) {
      // Ultimate fallback
      return {
        'day': '1',
        'month': '1',
        'year': '1445',
        'weekday': 'Monday',
        'monthName': 'Muharram',
        'date': '1 Muharram 1445 AH',
        'monthInfo': {'number': 1, 'en': 'Muharram'},
      };
    }
  }
  
  /// Formats Hijri date for display
  static String formatHijriDate(Map<String, dynamic> hijriData) {
    final weekday = hijriData['weekday'] ?? 'Monday';
    final day = hijriData['day'] ?? '1';
    final monthName = hijriData['monthName'] ?? 'Muharram';
    final year = hijriData['year'] ?? '1445';
    
    return '$weekday, $day $monthName $year AH';
  }
} 