import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QiblaProvider with ChangeNotifier {
  double? _qiblaDirection;
  double? _compassHeading;
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  double? _distanceToMecca;
  double? _magneticDeclination;
  Timer? _locationUpdateTimer;
  StreamSubscription<CompassEvent>? _compassSubscription;
  List<double> _compassReadings = [];
  DateTime? _lastLocationUpdate;
  
  // Most precise Kaaba coordinates (verified from multiple Islamic sources)
  static const double kaabaLatitude = 21.4224779;
  static const double kaabaLongitude = 39.8251832;
  
  // Getters
  double? get qiblaDirection => _qiblaDirection;
  double? get compassHeading => _compassHeading;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get distanceToMecca => _distanceToMecca;
  double? get magneticDeclination => _magneticDeclination;
  
  // Calculate the angle between current heading and Qibla direction
  double? get qiblaAngle {
    if (_qiblaDirection == null || _compassHeading == null) return null;
    double angle = _qiblaDirection! - _compassHeading!;
    // Normalize angle to -180 to 180 range
    while (angle > 180) angle -= 360;
    while (angle < -180) angle += 360;
    return angle;
  }
  
  // Check if device is pointing towards Qibla with ultra-precise accuracy detection
  bool get isPointingToQibla {
    if (qiblaAngle == null) return false;
    return qiblaAngle!.abs() <= 2.0; // Ultra-precise accuracy for Islamic prayers
  }
  
  // Get accuracy level for better user feedback
  String get accuracyLevel {
    if (qiblaAngle == null) return 'calculating';
    
    double angle = qiblaAngle!.abs();
    if (angle <= 0.5) return 'perfect';
    if (angle <= 1.5) return 'excellent';
    if (angle <= 3.0) return 'very_good';
    if (angle <= 5.0) return 'good';
    if (angle <= 10.0) return 'fair';
    return 'adjust';
  }
  
  // Get location accuracy status
  String get locationAccuracy {
    if (_currentPosition == null) return 'unknown';
    double accuracy = _currentPosition!.accuracy;
    if (accuracy <= 3) return 'excellent';
    if (accuracy <= 5) return 'very_good';
    if (accuracy <= 10) return 'good';
    if (accuracy <= 20) return 'fair';
    return 'poor';
  }
  
  // Check if location needs refresh (every 5 minutes for accuracy)
  bool get needsLocationRefresh {
    if (_lastLocationUpdate == null) return true;
    return DateTime.now().difference(_lastLocationUpdate!).inMinutes >= 5;
  }

  QiblaProvider() {
    _initializeQibla();
  }

  Future<void> _initializeQibla() async {
    await getCurrentLocation();
    await _getMagneticDeclination();
    _startCompassListener();
    _startLocationUpdateTimer();
  }
  
  void _startLocationUpdateTimer() {
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (needsLocationRefresh) {
        getCurrentLocation();
      }
    });
  }

  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get the most accurate location possible
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 15),
      );
      
      // Validate location accuracy
      if (_currentPosition!.accuracy > 50) {
        // Try again with different settings if accuracy is poor
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      }
      
      _lastLocationUpdate = DateTime.now();
      await _getMagneticDeclination();
      _calculateQiblaDirection();
      _calculateDistanceToMecca();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get magnetic declination for precise compass correction
  Future<void> _getMagneticDeclination() async {
    if (_currentPosition == null) return;
    
    try {
      // Use NOAA magnetic declination API for maximum accuracy
      final lat = _currentPosition!.latitude;
      final lng = _currentPosition!.longitude;
      final year = DateTime.now().year;
      
      final url = 'https://www.ngdc.noaa.gov/geomag-web/calculators/calculateDeclination?lat1=$lat&lon1=$lng&model=WMM&startYear=$year&resultFormat=json';
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _magneticDeclination = data['result'][0]['declination']?.toDouble();
      } else {
        // Fallback to simplified calculation if API fails
        _magneticDeclination = _calculateApproximateDeclination(lat, lng);
      }
    } catch (e) {
      // Use simplified calculation as fallback
      _magneticDeclination = _calculateApproximateDeclination(
        _currentPosition!.latitude, 
        _currentPosition!.longitude
      );
    }
  }
  
  // Simplified magnetic declination calculation as fallback
  double _calculateApproximateDeclination(double lat, double lng) {
    // This is a simplified model - real declination varies significantly
    // Based on IGRF model approximation
    double latRad = lat * math.pi / 180;
    double lngRad = lng * math.pi / 180;
    
    // Simplified calculation (not as accurate as NOAA but better than nothing)
    double declination = -5.0 * math.sin(lngRad) * math.cos(latRad);
    return declination;
  }

  void _calculateQiblaDirection() {
    if (_currentPosition == null) return;
    
    double userLat = _degreesToRadians(_currentPosition!.latitude);
    double userLng = _degreesToRadians(_currentPosition!.longitude);
    double kaabaLat = _degreesToRadians(kaabaLatitude);
    double kaabaLng = _degreesToRadians(kaabaLongitude);
    
    double deltaLng = kaabaLng - userLng;
    
    // Ultra-precise great circle bearing calculation using spherical trigonometry
    // This accounts for Earth's curvature for maximum accuracy
    double y = math.sin(deltaLng) * math.cos(kaabaLat);
    double x = math.cos(userLat) * math.sin(kaabaLat) - 
               math.sin(userLat) * math.cos(kaabaLat) * math.cos(deltaLng);
    
    double bearing = math.atan2(y, x);
    
    // Convert to degrees and normalize to 0-360
    _qiblaDirection = _radiansToDegrees(bearing);
    if (_qiblaDirection! < 0) {
      _qiblaDirection = _qiblaDirection! + 360;
    }
    
    // Apply magnetic declination correction for true north alignment
    _qiblaDirection = _applyMagneticDeclination(_qiblaDirection!);
    
    // Apply precision rounding (to 0.1 degree for maximum accuracy)
    _qiblaDirection = double.parse(_qiblaDirection!.toStringAsFixed(1));
    
    notifyListeners();
  }
  
  double _applyMagneticDeclination(double direction) {
    if (_magneticDeclination == null) return direction;
    
    // Apply magnetic declination correction
    // Positive declination means magnetic north is east of true north
    double correctedDirection = direction + _magneticDeclination!;
    
    // Normalize to 0-360 range
    while (correctedDirection < 0) correctedDirection += 360;
    while (correctedDirection >= 360) correctedDirection -= 360;
    
    return correctedDirection;
  }
  


  void _calculateDistanceToMecca() {
    if (_currentPosition == null) return;
    
    _distanceToMecca = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      kaabaLatitude,
      kaabaLongitude,
    ) / 1000; // Convert to kilometers
    
    notifyListeners();
  }

  void _startCompassListener() {
    _compassSubscription?.cancel();
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading != null) {
        _processCompassReading(event.heading!);
      }
    });
    
    _compassSubscription?.onError((error) {
      _error = 'Compass not available. Please check device sensors and permissions.';
      notifyListeners();
    });
  }
  
  void _processCompassReading(double newHeading) {
    // Add to readings buffer for advanced filtering
    _compassReadings.add(newHeading);
    
    // Keep only last 10 readings for moving average
    if (_compassReadings.length > 10) {
      _compassReadings.removeAt(0);
    }
    
    // Apply advanced filtering for ultra-stable readings
    double filteredHeading = _applyAdvancedFiltering();
    
    if (_compassHeading != null) {
      // Handle compass wrap-around (359° to 0°)
      double diff = (filteredHeading - _compassHeading!).abs();
      if (diff > 180) {
        if (filteredHeading > _compassHeading!) {
          filteredHeading -= 360;
        } else {
          filteredHeading += 360;
        }
      }
      
      // Apply adaptive smoothing based on movement speed
      double smoothingFactor = _getAdaptiveSmoothingFactor(diff);
      _compassHeading = _compassHeading! * (1 - smoothingFactor) + filteredHeading * smoothingFactor;
      
      // Normalize to 0-360 range
      if (_compassHeading! < 0) _compassHeading = _compassHeading! + 360;
      if (_compassHeading! >= 360) _compassHeading = _compassHeading! - 360;
    } else {
      _compassHeading = filteredHeading;
    }
    
    // Apply precision rounding
    _compassHeading = double.parse(_compassHeading!.toStringAsFixed(1));
    
    notifyListeners();
  }
  
  double _applyAdvancedFiltering() {
    if (_compassReadings.isEmpty) return 0.0;
    if (_compassReadings.length == 1) return _compassReadings.first;
    
    // Remove outliers using median filtering
    List<double> sortedReadings = List.from(_compassReadings)..sort();
    double median = sortedReadings[sortedReadings.length ~/ 2];
    
    // Filter out readings that are too far from median
    List<double> filteredReadings = _compassReadings.where((reading) {
      double diff = (reading - median).abs();
      if (diff > 180) diff = 360 - diff;
      return diff <= 30; // Remove readings more than 30° from median
    }).toList();
    
    if (filteredReadings.isEmpty) return median;
    
    // Calculate weighted average (recent readings have more weight)
    double sum = 0;
    double weightSum = 0;
    for (int i = 0; i < filteredReadings.length; i++) {
      double weight = (i + 1).toDouble(); // More recent = higher weight
      sum += filteredReadings[i] * weight;
      weightSum += weight;
    }
    
    return sum / weightSum;
  }
  
  double _getAdaptiveSmoothingFactor(double movementSpeed) {
    // Faster movement = less smoothing for responsiveness
    // Slower movement = more smoothing for stability
    if (movementSpeed > 10) return 0.7; // Fast movement
    if (movementSpeed > 5) return 0.5;  // Medium movement
    if (movementSpeed > 2) return 0.3;  // Slow movement
    return 0.1; // Very slow/stable
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  double _radiansToDegrees(double radians) {
    return radians * (180 / math.pi);
  }

  Future<void> refreshLocation() async {
    await getCurrentLocation();
  }

  String getQiblaDirectionText() {
    if (_qiblaDirection == null) return 'Calculating...';
    
    double direction = _qiblaDirection!;
    
    if (direction >= 337.5 || direction < 22.5) return 'North';
    if (direction >= 22.5 && direction < 67.5) return 'Northeast';
    if (direction >= 67.5 && direction < 112.5) return 'East';
    if (direction >= 112.5 && direction < 157.5) return 'Southeast';
    if (direction >= 157.5 && direction < 202.5) return 'South';
    if (direction >= 202.5 && direction < 247.5) return 'Southwest';
    if (direction >= 247.5 && direction < 292.5) return 'West';
    if (direction >= 292.5 && direction < 337.5) return 'Northwest';
    
    return 'Unknown';
  }

  String getDistanceText() {
    if (_distanceToMecca == null) return 'Calculating...';
    
    if (_distanceToMecca! < 1) {
      return '${(_distanceToMecca! * 1000).toStringAsFixed(0)} meters';
    } else if (_distanceToMecca! < 1000) {
      return '${_distanceToMecca!.toStringAsFixed(1)} km';
    } else {
      return '${(_distanceToMecca! / 1000).toStringAsFixed(1)}k km';
    }
  }

  String getAccuracyText() {
    if (qiblaAngle == null) return 'Calculating...';
    
    double angle = qiblaAngle!.abs();
    
    if (angle <= 1) return 'Perfect';
    if (angle <= 5) return 'Very Good';
    if (angle <= 10) return 'Good';
    if (angle <= 20) return 'Fair';
    return 'Adjust Direction';
  }

  Color getAccuracyColor() {
    if (qiblaAngle == null) return Colors.grey;
    
    double angle = qiblaAngle!.abs();
    
    if (angle <= 1) return Colors.green;
    if (angle <= 5) return Colors.lightGreen;
    if (angle <= 10) return Colors.orange;
    if (angle <= 20) return Colors.deepOrange;
    return Colors.red;
  }

  String getCoordinatesText() {
    if (_currentPosition == null) return 'Getting location...';
    
    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;
    
    final latDirection = lat >= 0 ? 'N' : 'S';
    final lngDirection = lng >= 0 ? 'E' : 'W';
    
    return '${lat.abs().toStringAsFixed(4)}°$latDirection, ${lng.abs().toStringAsFixed(4)}°$lngDirection';
  }

  // Check if compass is available
  Future<bool> isCompassAvailable() async {
    try {
      final events = FlutterCompass.events;
      return events != null;
    } catch (e) {
      return false;
    }
  }

  // Calibration helper
  bool needsCalibration() {
    // Simple heuristic: if compass reading is null or hasn't changed much
    return _compassHeading == null;
  }

  // Enhanced accuracy validation
  bool get isLocationAccurate {
    if (_currentPosition == null) return false;
    return _currentPosition!.accuracy <= 20; // Within 20 meters
  }
  
  bool get isCompassStable {
    if (_compassReadings.length < 5) return false;
    
    // Check if compass readings are stable (low variance)
    double sum = _compassReadings.reduce((a, b) => a + b);
    double mean = sum / _compassReadings.length;
    
    double variance = _compassReadings
        .map((reading) => math.pow(reading - mean, 2))
        .reduce((a, b) => a + b) / _compassReadings.length;
    
    return variance < 25; // Low variance indicates stability
  }
  
  String get overallAccuracyStatus {
    if (!isLocationAccurate) return 'location_poor';
    if (!isCompassStable) return 'compass_unstable';
    if (_magneticDeclination == null) return 'declination_unknown';
    
    String qiblaAccuracy = accuracyLevel;
    if (qiblaAccuracy == 'perfect' || qiblaAccuracy == 'excellent') {
      return 'excellent';
    } else if (qiblaAccuracy == 'very_good' || qiblaAccuracy == 'good') {
      return 'good';
    } else {
      return 'needs_adjustment';
    }
  }
  
  // Force recalibration
  Future<void> recalibrate() async {
    _compassReadings.clear();
    _compassHeading = null;
    _qiblaDirection = null;
    _magneticDeclination = null;
    
    await getCurrentLocation();
  }
  
  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _compassSubscription?.cancel();
    super.dispose();
  }
}