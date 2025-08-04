import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/prayer_times.dart';
import '../services/notification_service.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/hijri_calculator.dart';

class PrayerProvider with ChangeNotifier {
  PrayerTimes? _prayerTimes;
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;
  String? _locationName;
  String _calculationMethod = '2'; // Islamic Society of North America
  String _asrMethod = '0'; // Shafi
  String _apiSource = 'waktusolat'; // Default to Waktu Solat API for Malaysia
  String? _malaysianZone; // Malaysian prayer time zone (e.g., SGR01, WLY01)
  
  // Getters
  PrayerTimes? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;
  String? get locationName => _locationName;
  String get calculationMethod => _calculationMethod;
  String get asrMethod => _asrMethod;
  String get apiSource => _apiSource;
  String? get malaysianZone => _malaysianZone ?? 'Auto-detect';

  // Prayer time names
  final List<String> prayerNames = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Imsak'];
  
  // Calculation methods
  final Map<String, String> calculationMethods = {
    '1': 'University of Islamic Sciences, Karachi',
    '2': 'Islamic Society of North America',
    '3': 'Muslim World League',
    '4': 'Umm Al-Qura University, Makkah',
    '5': 'Egyptian General Authority of Survey',
    '7': 'Institute of Geophysics, University of Tehran',
    '8': 'Gulf Region',
    '9': 'Kuwait',
    '10': 'Qatar',
    '11': 'Majlis Ugama Islam Singapura, Singapore',
    '12': 'Union Organization islamic de France',
    '13': 'Diyanet İşleri Başkanlığı, Turkey',
    '14': 'Spiritual Administration of Muslims of Russia',
    '15': 'Moonsighting Committee Worldwide (Malaysia)',
    '16': 'Department of Islamic Development Malaysia (JAKIM)',
  };
  
  // Asr juristic methods
  final Map<String, String> asrMethods = {
    '0': 'Shafi (Standard)',
    '1': 'Hanafi',
  };

  PrayerProvider() {
    _loadSettings();
    _loadCachedPrayerTimes();
    getCurrentLocation();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _calculationMethod = prefs.getString('calculation_method') ?? '2';
    _asrMethod = prefs.getString('asr_method') ?? '0';
    _apiSource = prefs.getString('api_source') ?? 'waktusolat';
    _malaysianZone = prefs.getString('malaysian_zone');
    notifyListeners();
  }

  Future<void> _loadCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_prayer_times');
    final cachedDate = prefs.getString('cached_date');
    
    if (cachedData != null && cachedDate != null) {
      final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
      if (cachedDate == today) {
        try {
          final Map<String, dynamic> data = json.decode(cachedData);
          _prayerTimes = PrayerTimes.fromJson(data);
          print('Loaded cached prayer times for today');
          notifyListeners();
        } catch (e) {
          print('Error loading cached prayer times: $e');
          // Clear corrupted cache
          await prefs.remove('cached_prayer_times');
          await prefs.remove('cached_date');
        }
      } else {
        print('Cached prayer times are for a different date, clearing cache');
        // Clear outdated cache
        await prefs.remove('cached_prayer_times');
        await prefs.remove('cached_date');
      }
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to open location settings
        bool opened = await Geolocator.openLocationSettings();
        if (!opened) {
          throw Exception('Location services are disabled. Please enable location services in your device settings.');
        }
        // Wait a bit and check again
        await Future.delayed(const Duration(seconds: 2));
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          throw Exception('Location services are still disabled. Please enable them manually.');
        }
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied. Please grant location permission to get accurate prayer times.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Try to open app settings
        throw Exception('Location permissions are permanently denied. Please enable location permission in app settings.');
      }

      // Get current position with timeout and fallback
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 15));
      } catch (e) {
        print('High accuracy location failed, trying with lower accuracy: $e');
        // Fallback to lower accuracy
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        ).timeout(const Duration(seconds: 10));
      }

      // Validate coordinates
      if (position.latitude.abs() > 90 || position.longitude.abs() > 180) {
        throw Exception('Invalid coordinates received. Please try again.');
      }

      _currentPosition = position;
      print('Location obtained: ${position.latitude}, ${position.longitude}');
      
      // Get location name
      await _getLocationName(position);
      
      // Try to fetch fresh prayer times, but don't fail if network is unavailable
      await fetchPrayerTimes();
      
      // If we still don't have prayer times and there's an error, try to use cached data
      if (_prayerTimes == null && _error != null) {
        await _loadCachedPrayerTimes();
        if (_prayerTimes != null) {
          _error = 'Using cached prayer times. Please check your internet connection for updated times.';
        }
      }
    } catch (e) {
      print('Error getting location: $e');
      _error = e.toString();
      
      // Try to load cached data even if location failed
      await _loadCachedPrayerTimes();
      if (_prayerTimes != null) {
        _error = 'Location unavailable. Using cached prayer times. ${e.toString()}';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _getLocationName(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final parts = <String>[];
        
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          parts.add(placemark.locality!);
        }
        if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
          parts.add(placemark.administrativeArea!);
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          parts.add(placemark.country!);
        }
        
        _locationName = parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
        print('Location name: $_locationName');
      } else {
        _locationName = 'Unknown Location';
      }
    } catch (e) {
      print('Error getting location name: $e');
      _locationName = 'Location Name Unavailable';
    }
    notifyListeners();
  }

  // Method to detect Malaysian zone based on coordinates using Waktu Solat API
  Future<String?> _detectMalaysianZone(double latitude, double longitude) async {
    try {
      final url = Uri.parse('https://api.waktusolat.app/zones/$latitude/$longitude');
      print('Detecting Malaysian zone for coordinates: $latitude, $longitude');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Zone detection timed out');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final zone = data['zone'] as dynamic;
        print('Detected zone: $zone');
        return zone != null ? zone.toString() : null;
      } else {
        print('Zone detection failed with status: ${response.statusCode}');
        return _fallbackZoneDetection(latitude, longitude);
      }
    } catch (e) {
      print('Error detecting zone: $e');
      return _fallbackZoneDetection(latitude, longitude);
    }
  }

  // Fallback zone detection for when API is unavailable
  String? _fallbackZoneDetection(double latitude, double longitude) {
    // Simplified zone detection for major Malaysian areas
    // This is used as fallback when the API is unavailable
    
    // Selangor zones
    if (latitude >= 2.8 && latitude <= 3.8 && longitude >= 101.0 && longitude <= 102.0) {
      return 'SGR01'; // Gombak, Petaling, Sepang, Hulu Langat, Hulu Selangor, Rawang
    }
    if (latitude >= 3.0 && latitude <= 3.5 && longitude >= 100.8 && longitude <= 101.5) {
      return 'SGR02'; // Kuala Langat, Kuala Selangor, Klang
    }
    
    // Kuala Lumpur
    if (latitude >= 3.0 && latitude <= 3.3 && longitude >= 101.5 && longitude <= 101.8) {
      return 'WLY01'; // Kuala Lumpur
    }
    
    // Putrajaya
    if (latitude >= 2.8 && latitude <= 3.0 && longitude >= 101.6 && longitude <= 101.8) {
      return 'WLY02'; // Putrajaya
    }
    
    // Johor zones
    if (latitude >= 1.2 && latitude <= 2.8 && longitude >= 102.5 && longitude <= 104.5) {
      if (latitude >= 1.4 && latitude <= 1.6 && longitude >= 103.6 && longitude <= 103.9) {
        return 'JHR01'; // Johor Bahru, Kota Tinggi, Mersing
      }
      return 'JHR02'; // Other Johor areas
    }
    
    // Penang
    if (latitude >= 5.0 && latitude <= 5.7 && longitude >= 100.0 && longitude <= 100.6) {
      return 'PNG01'; // Penang
    }
    
    // Default to Selangor if in Malaysia but zone not detected
    if (latitude >= 1.0 && latitude <= 7.0 && longitude >= 99.0 && longitude <= 120.0) {
      return 'SGR01'; // Default Malaysian zone
    }
    
    return null; // Not in Malaysia
  }

  // Fetch prayer times from Waktu Solat API
  Future<PrayerTimes?> _fetchFromWaktuSolat(double latitude, double longitude) async {
    try {
      String? zone = _malaysianZone ?? await _detectMalaysianZone(latitude, longitude);
      
      if (zone == null) {
        print('Location not in Malaysia, falling back to Aladhan API');
        return _fetchFromAladhan(latitude, longitude);
      }
      
      // Save detected zone for future use
      if (_malaysianZone != zone) {
        _malaysianZone = zone;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('malaysian_zone', zone);
      }
      
      // Try v2 endpoint first, then fallback to v1
      final urls = [
        'https://api.waktusolat.app/v2/solat/$zone',
        'https://api.waktusolat.app/solat/$zone',
      ];
      
      for (final url in urls) {
        print('Fetching prayer times from Waktu Solat API: $url');
        
        try {
          final response = await http.get(Uri.parse(url));
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print('Waktu Solat API response: ${response.body}');
            
            // Handle different response formats
            Map<String, dynamic>? prayerData;
            
            if (data is Map<String, dynamic>) {
              // Check for v2 format with prayerTime array
              if (data.containsKey('prayerTime') && data['prayerTime'] is List) {
                final prayerList = data['prayerTime'] as List;
                if (prayerList.isNotEmpty) {
                  prayerData = prayerList.first as Map<String, dynamic>;
                }
              }
              // Check for direct prayer data format
              else if (data.containsKey('imsak') || data.containsKey('subuh')) {
                prayerData = data;
              }
              // Check for nested data format
              else if (data.containsKey('data')) {
                final nestedData = data['data'];
                if (nestedData is Map<String, dynamic>) {
                  prayerData = nestedData;
                } else if (nestedData is List && nestedData.isNotEmpty) {
                  prayerData = nestedData.first as Map<String, dynamic>;
                }
              }
            }
            
            if (prayerData != null) {
              // Convert Waktu Solat format to our PrayerTimes format
              final timingsMap = {
                'Fajr': prayerData['subuh'] ?? prayerData['fajr'],
                'Sunrise': prayerData['syuruk'] ?? prayerData['sunrise'],
                'Dhuhr': prayerData['zohor'] ?? prayerData['dhuhr'],
                'Asr': prayerData['asar'] ?? prayerData['asr'],
                'Maghrib': prayerData['maghrib'],
                'Isha': prayerData['isyak'] ?? prayerData['isha'],
                'Imsak': prayerData['imsak'],
              };
              
              // Create date info with Hijri calculation
              final now = DateTime.now();
              final hijriData = HijriCalculator.getCurrentHijriDate();
              
              final dateInfo = {
                'readable': prayerData['date'] ?? DateFormat('dd MMM yyyy').format(now),
                'timestamp': now.millisecondsSinceEpoch.toString(),
                'hijri': {
                  'date': hijriData['date'],
                  'day': hijriData['day'],
                  'weekday': {'en': hijriData['weekday']},
                  'month': {
                    'number': int.parse(hijriData['month']),
                    'en': hijriData['monthName'],
                    'ar': hijriData['monthName'],
                  },
                  'year': hijriData['year'],
                },
                'gregorian': {
                  'date': DateFormat('dd-MM-yyyy').format(now),
                  'day': now.day.toString(),
                  'weekday': {'en': DateFormat('EEEE').format(now)},
                  'month': {'en': DateFormat('MMMM').format(now)},
                  'year': now.year.toString(),
                },
              };
              
              // Create location info
              final locationInfo = {
                'latitude': latitude,
                'longitude': longitude,
                'timezone': 'Asia/Kuala_Lumpur',
                'method': {
                  'id': 16,
                  'name': 'Department of Islamic Development Malaysia (JAKIM)',
                },
              };
              
              final prayerTimesJson = {
                'timings': timingsMap,
                'date': dateInfo,
                'meta': locationInfo,
              };
              
              return PrayerTimes.fromJson(prayerTimesJson);
            }
          }
        } catch (e) {
          print('Error with URL $url: $e');
          continue; // Try next URL
        }
      }
      
      print('All Waktu Solat API endpoints failed, falling back to Aladhan');
      return _fetchFromAladhan(latitude, longitude);
      
    } catch (e) {
      print('Error fetching from Waktu Solat API: $e');
      return _fetchFromAladhan(latitude, longitude);
    }
  }

  // Original Aladhan API method (renamed)
  Future<PrayerTimes?> _fetchFromAladhan(double latitude, double longitude) async {
    try {
      final today = DateTime.now();
      final dateString = DateFormat('dd-MM-yyyy').format(today);
      
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/$dateString'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=$_calculationMethod'
        '&school=$_asrMethod'
      );

      print('Fetching prayer times from Aladhan API: $url');

      final response = await http.get(url).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection.');
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Validate response structure
        if (responseData['code'] != 200 || responseData['data'] == null) {
          throw Exception('Invalid response from prayer times API');
        }
        
        return PrayerTimes.fromJson(responseData['data']);
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please try again in a few minutes.');
      } else {
        throw Exception('Failed to load prayer times (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching prayer times from Aladhan: $e');
      return null;
    }
  }

  Future<void> fetchPrayerTimes({int retryCount = 0}) async {
    if (_currentPosition == null) {
      _error = 'Location not available. Please enable location services.';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      PrayerTimes? prayerTimes;
      
      if (_apiSource == 'waktusolat') {
        prayerTimes = await _fetchFromWaktuSolat(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      } else {
        prayerTimes = await _fetchFromAladhan(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }
      
      if (prayerTimes != null) {
        _prayerTimes = prayerTimes;
        
        // Validate that we got valid prayer times
        if (_prayerTimes!.fajr == null || _prayerTimes!.dhuhr == null) {
          throw Exception('Incomplete prayer times received from API');
        }
        
        // Cache the data
        final today = DateTime.now();
        final dateString = DateFormat('dd-MM-yyyy').format(today);
        await _cachePrayerTimes(prayerTimes.toJson(), dateString);
        
        // Schedule notifications
        await _scheduleNotifications();
        
        print('Prayer times fetched successfully');
      } else {
        throw Exception('Failed to fetch prayer times from any source');
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      
      // Retry logic for network errors
      if (retryCount < 2 && (e.toString().contains('timeout') || e.toString().contains('SocketException'))) {
        print('Retrying... Attempt ${retryCount + 1}');
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        return fetchPrayerTimes(retryCount: retryCount + 1);
      }
      
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _cachePrayerTimes(Map<String, dynamic> data, String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_prayer_times', json.encode(data));
      await prefs.setString('cached_date', date);
      await prefs.setString('cached_timestamp', DateTime.now().millisecondsSinceEpoch.toString());
      print('Prayer times cached successfully for $date');
    } catch (e) {
      print('Error caching prayer times: $e');
    }
  }

  // Method to refresh prayer times
  Future<void> refreshPrayerTimes() async {
    if (_currentPosition != null) {
      await fetchPrayerTimes();
    } else {
      await getCurrentLocation();
    }
  }

  // Method to check if cached data is still valid (within 6 hours)

  Future<void> _scheduleNotifications() async {
    if (_prayerTimes == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    
    // Schedule notifications for each prayer
    final prayers = {
      'Fajr': _prayerTimes!.fajr,
      'Sunrise': _prayerTimes!.sunrise,
      'Dhuhr': _prayerTimes!.dhuhr,
      'Asr': _prayerTimes!.asr,
      'Maghrib': _prayerTimes!.maghrib,
      'Isha': _prayerTimes!.isha,
    };
    
    for (final entry in prayers.entries) {
      final prayerName = entry.key;
      final prayerTime = entry.value;
      
      // Check if notifications are enabled for this prayer
      final isEnabled = prefs.getBool('notification_${prayerName.toLowerCase()}') ?? true;
      
      if (isEnabled && prayerTime != null) {
        final timeParts = prayerTime.split(':');
        final prayerDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        
        if (prayerDateTime.isAfter(DateTime.now())) {
          await NotificationService.schedulePrayerNotification(
            prayerName,
            prayerDateTime,
          );
        }
      }
    }
  }

  Future<void> updateCalculationMethod(String method) async {
    _calculationMethod = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calculation_method', method);
    await fetchPrayerTimes();
    notifyListeners();
  }

  Future<void> updateAsrMethod(String method) async {
    _asrMethod = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('asr_method', method);
    await fetchPrayerTimes();
    notifyListeners();
  }

  Future<void> updateApiSource(String source) async {
    _apiSource = source;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_source', source);
    notifyListeners();
    await fetchPrayerTimes();
  }

  Future<void> updateMalaysianZone(String? zone) async {
    // Convert 'Auto-detect' to null for internal logic
    final actualZone = zone == 'Auto-detect' ? null : zone;
    _malaysianZone = actualZone;
    final prefs = await SharedPreferences.getInstance();
    if (actualZone != null) {
      await prefs.setString('malaysian_zone', actualZone);
    } else {
      await prefs.remove('malaysian_zone');
    }
    notifyListeners();
    if (_apiSource == 'waktusolat') {
      await fetchPrayerTimes();
    }
  }

  String? getNextPrayer() {
    if (_prayerTimes == null) return null;
    
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    final prayers = {
      'Fajr': _prayerTimes!.fajr,
      'Dhuhr': _prayerTimes!.dhuhr,
      'Asr': _prayerTimes!.asr,
      'Maghrib': _prayerTimes!.maghrib,
      'Isha': _prayerTimes!.isha,
    };
    
    for (final entry in prayers.entries) {
      if (entry.value != null && entry.value!.compareTo(currentTime) > 0) {
        return entry.key;
      }
    }
    
    return 'Fajr'; // Next day's Fajr
  }

  Duration? getTimeUntilNextPrayer() {
    final nextPrayer = getNextPrayer();
    if (nextPrayer == null || _prayerTimes == null) return null;
    
    final now = DateTime.now();
    String? prayerTime;
    
    switch (nextPrayer) {
      case 'Fajr':
        prayerTime = _prayerTimes!.fajr;
        break;
      case 'Dhuhr':
        prayerTime = _prayerTimes!.dhuhr;
        break;
      case 'Asr':
        prayerTime = _prayerTimes!.asr;
        break;
      case 'Maghrib':
        prayerTime = _prayerTimes!.maghrib;
        break;
      case 'Isha':
        prayerTime = _prayerTimes!.isha;
        break;
    }
    
    if (prayerTime == null) return null;
    
    final timeParts = prayerTime.split(':');
    var prayerDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    
    // If prayer time has passed today, it's tomorrow's Fajr
    if (prayerDateTime.isBefore(now) && nextPrayer == 'Fajr') {
      prayerDateTime = prayerDateTime.add(const Duration(days: 1));
    }
    
    return prayerDateTime.difference(now);
  }

}