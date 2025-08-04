import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for fetching moon phase data from Aladhan API
class MoonPhaseService {
  static const String _baseUrl = 'http://api.aladhan.com/v1';
  
  /// Moon phase names
  static const List<String> moonPhases = [
    'New Moon',
    'Waxing Crescent',
    'First Quarter',
    'Waxing Gibbous',
    'Full Moon',
    'Waning Gibbous',
    'Last Quarter',
    'Waning Crescent',
  ];

  /// Moon phase emojis
  static const List<String> moonPhaseEmojis = [
    '🌑', // New Moon
    '🌒', // Waxing Crescent
    '🌓', // First Quarter
    '🌔', // Waxing Gibbous
    '🌕', // Full Moon
    '🌖', // Waning Gibbous
    '🌗', // Last Quarter
    '🌘', // Waning Crescent
  ];

  /// Fetches current moon phase from Aladhan API
  static Future<Map<String, dynamic>> getCurrentMoonPhase() async {
    try {
      final now = DateTime.now();
      final url = Uri.parse('$_baseUrl/gToH/${now.day}-${now.month}-${now.year}');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Moon phase request timed out');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hijriData = data['data']['hijri'];
        
        // Calculate moon phase based on Hijri date
        final hijriDay = int.parse(hijriData['day']);
        final moonPhaseIndex = _calculateMoonPhaseIndex(hijriDay);
        
        return {
          'phase': moonPhases[moonPhaseIndex],
          'emoji': moonPhaseEmojis[moonPhaseIndex],
          'day': hijriDay,
          'hijriDate': '${hijriData['day']} ${hijriData['month']['en']} ${hijriData['year']}',
          'illumination': _calculateIllumination(hijriDay),
        };
      } else {
        throw Exception('Failed to fetch moon phase: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching moon phase: $e');
      // Fallback to calculated moon phase
      return _getFallbackMoonPhase();
    }
  }

  /// Calculates moon phase index based on Hijri day
  static int _calculateMoonPhaseIndex(int hijriDay) {
    // Simplified moon phase calculation based on Hijri day
    // This is an approximation - for more accuracy, use astronomical calculations
    final phase = (hijriDay / 3.5) % 8;
    return phase.round() % 8;
  }

  /// Calculates moon illumination percentage
  static double _calculateIllumination(int hijriDay) {
    final phase = (hijriDay / 3.5) % 8;
    if (phase <= 1) return 0; // New Moon
    if (phase <= 2) return 25; // Waxing Crescent
    if (phase <= 3) return 50; // First Quarter
    if (phase <= 4) return 75; // Waxing Gibbous
    if (phase <= 5) return 100; // Full Moon
    if (phase <= 6) return 75; // Waning Gibbous
    if (phase <= 7) return 50; // Last Quarter
    return 25; // Waning Crescent
  }

  /// Fallback method when API fails
  static Map<String, dynamic> _getFallbackMoonPhase() {
    final now = DateTime.now();
    final day = now.day;
    final moonPhaseIndex = (day / 3.5) % 8;
    final index = moonPhaseIndex.round() % 8;
    
    return {
      'phase': moonPhases[index],
      'emoji': moonPhaseEmojis[index],
      'day': day,
      'hijriDate': 'Current',
      'illumination': _calculateIllumination(day),
    };
  }

  /// Gets moon phase for a specific date
  static Future<Map<String, dynamic>> getMoonPhaseForDate(DateTime date) async {
    try {
      final url = Uri.parse('$_baseUrl/gToH/${date.day}-${date.month}-${date.year}');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Moon phase request timed out');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hijriData = data['data']['hijri'];
        
        final hijriDay = int.parse(hijriData['day']);
        final moonPhaseIndex = _calculateMoonPhaseIndex(hijriDay);
        
        return {
          'phase': moonPhases[moonPhaseIndex],
          'emoji': moonPhaseEmojis[moonPhaseIndex],
          'day': hijriDay,
          'hijriDate': '${hijriData['day']} ${hijriData['month']['en']} ${hijriData['year']}',
          'illumination': _calculateIllumination(hijriDay),
        };
      } else {
        throw Exception('Failed to fetch moon phase: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching moon phase: $e');
      return _getFallbackMoonPhase();
    }
  }
} 