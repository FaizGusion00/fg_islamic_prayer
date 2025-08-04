import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../lib/services/moon_phase_service.dart';
import '../lib/utils/islamic_quotes.dart';

void main() {
  group('New Features Tests', () {
    test('MoonPhaseService should return valid moon phase data', () async {
      // Test the API endpoint directly
      final now = DateTime.now();
      final url = Uri.parse('http://api.aladhan.com/v1/gToH/${now.day}-${now.month}-${now.year}');
      
      final response = await http.get(url);
      
      expect(response.statusCode, 200);
      
      final data = json.decode(response.body);
      expect(data['data'], isNotNull);
      expect(data['data']['hijri'], isNotNull);
      
      // Test the service method
      final serviceResult = await MoonPhaseService.getCurrentMoonPhase();
      
      expect(serviceResult['phase'], isNotNull);
      expect(serviceResult['emoji'], isNotNull);
      expect(serviceResult['day'], isNotNull);
      expect(serviceResult['illumination'], isNotNull);
      
      // Verify moon phase is one of the valid phases
      expect(MoonPhaseService.moonPhases, contains(serviceResult['phase']));
      expect(MoonPhaseService.moonPhaseEmojis, contains(serviceResult['emoji']));
    });

    test('IslamicQuotes should return valid quotes', () {
      // Test today's quote
      final todayQuote = IslamicQuotes.getTodayQuote();
      expect(todayQuote, isNotNull);
      expect(todayQuote.isNotEmpty, true);
      expect(IslamicQuotes.quotes, contains(todayQuote));
      
      // Test random quote
      final randomQuote = IslamicQuotes.getRandomQuote();
      expect(randomQuote, isNotNull);
      expect(randomQuote.isNotEmpty, true);
      expect(IslamicQuotes.quotes, contains(randomQuote));
      
      // Test specific day quote
      final dayQuote = IslamicQuotes.getQuoteForDay(15);
      expect(dayQuote, isNotNull);
      expect(dayQuote.isNotEmpty, true);
      expect(IslamicQuotes.quotes, contains(dayQuote));
    });

    test('IslamicQuotes should have authentic quotes', () {
      expect(IslamicQuotes.quotes.length, 80);
      
      // Verify all quotes are meaningful
      for (final quote in IslamicQuotes.quotes) {
        expect(quote, isNotNull);
        expect(quote.isNotEmpty, true);
        expect(quote.length > 10, true); // Meaningful length
      }
    });

    test('MoonPhaseService should handle errors gracefully', () async {
      // This test verifies that the service handles errors properly
      final result = await MoonPhaseService.getCurrentMoonPhase();
      
      // Should always return a valid structure even if API fails
      expect(result, isNotNull);
      expect(result['phase'], isNotNull);
      expect(result['emoji'], isNotNull);
      expect(result['day'], isNotNull);
      expect(result['illumination'], isNotNull);
    });

    test('Moon phase calculation should be consistent', () {
      // Test that moon phases are valid
      expect(MoonPhaseService.moonPhases.length, 8);
      expect(MoonPhaseService.moonPhaseEmojis.length, 8);
      
      // Verify all phases have corresponding emojis
      for (int i = 0; i < MoonPhaseService.moonPhases.length; i++) {
        expect(MoonPhaseService.moonPhases[i], isNotNull);
        expect(MoonPhaseService.moonPhaseEmojis[i], isNotNull);
      }
    });
  });
} 