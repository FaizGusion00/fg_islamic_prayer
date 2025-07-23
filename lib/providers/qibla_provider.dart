import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class QiblaProvider with ChangeNotifier {
  double? _qiblaDirection;
  double? _compassHeading;
  Position? _currentPosition;
  bool _isLoading = false;
  String? _error;
  double? _distanceToMecca;
  
  // Kaaba coordinates
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;
  
  // Getters
  double? get qiblaDirection => _qiblaDirection;
  double? get compassHeading => _compassHeading;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get distanceToMecca => _distanceToMecca;
  
  // Calculate the angle between current heading and Qibla direction
  double? get qiblaAngle {
    if (_qiblaDirection == null || _compassHeading == null) return null;
    double angle = _qiblaDirection! - _compassHeading!;
    // Normalize angle to -180 to 180 range
    while (angle > 180) angle -= 360;
    while (angle < -180) angle += 360;
    return angle;
  }
  
  // Check if device is pointing towards Qibla with improved accuracy detection
  bool get isPointingToQibla {
    if (qiblaAngle == null) return false;
    return qiblaAngle!.abs() <= 3.0; // More strict accuracy for better UX
  }
  
  // Get accuracy level for better user feedback
  String get accuracyLevel {
    if (qiblaAngle == null) return 'calculating';
    
    double angle = qiblaAngle!.abs();
    if (angle <= 1) return 'perfect';
    if (angle <= 3) return 'excellent';
    if (angle <= 5) return 'very_good';
    if (angle <= 10) return 'good';
    if (angle <= 15) return 'fair';
    return 'adjust';
  }

  QiblaProvider() {
    _initializeQibla();
  }

  Future<void> _initializeQibla() async {
    await getCurrentLocation();
    _startCompassListener();
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

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      _calculateQiblaDirection();
      _calculateDistanceToMecca();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateQiblaDirection() {
    if (_currentPosition == null) return;
    
    // Use the most precise Kaaba coordinates (from official sources)
    const double preciseKaabaLat = 21.4224779;
    const double preciseKaabaLng = 39.8251832;
    
    double userLat = _degreesToRadians(_currentPosition!.latitude);
    double userLng = _degreesToRadians(_currentPosition!.longitude);
    double kaabaLat = _degreesToRadians(preciseKaabaLat);
    double kaabaLng = _degreesToRadians(preciseKaabaLng);
    
    double deltaLng = kaabaLng - userLng;
    
    // High-precision great circle bearing calculation using spherical trigonometry
    double y = math.sin(deltaLng) * math.cos(kaabaLat);
    double x = math.cos(userLat) * math.sin(kaabaLat) - 
               math.sin(userLat) * math.cos(kaabaLat) * math.cos(deltaLng);
    
    double bearing = math.atan2(y, x);
    
    // Convert to degrees and normalize to 0-360
    _qiblaDirection = _radiansToDegrees(bearing);
    if (_qiblaDirection! < 0) {
      _qiblaDirection = _qiblaDirection! + 360;
    }
    
    // Apply magnetic declination correction if available
    // This improves accuracy by accounting for the difference between magnetic and true north
    _qiblaDirection = _applyMagneticDeclination(_qiblaDirection!);
    
    // Smooth the direction to reduce jitter while maintaining accuracy
    _qiblaDirection = _smoothDirection(_qiblaDirection!);
    
    notifyListeners();
  }
  
  double _applyMagneticDeclination(double direction) {
    // For now, we'll use a simplified approach
    // In a production app, you'd want to use a magnetic declination API
    // or lookup table based on location
    return direction;
  }
  
  double _smoothDirection(double newDirection) {
    // Simple smoothing to reduce jitter
    if (_qiblaDirection != null) {
      double diff = (newDirection - _qiblaDirection!).abs();
      if (diff > 180) {
        diff = 360 - diff;
      }
      
      // Only update if change is significant enough to avoid micro-movements
      if (diff < 0.5) {
        return _qiblaDirection!;
      }
    }
    
    return double.parse(newDirection.toStringAsFixed(2));
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
    FlutterCompass.events?.listen((CompassEvent event) {
      if (event.heading != null) {
        // Apply smoothing to compass readings to reduce jitter
        double newHeading = event.heading!;
        
        if (_compassHeading != null) {
          // Handle compass wrap-around (359° to 0°)
          double diff = (newHeading - _compassHeading!).abs();
          if (diff > 180) {
            if (newHeading > _compassHeading!) {
              newHeading -= 360;
            } else {
              newHeading += 360;
            }
          }
          
          // Apply exponential smoothing for stable readings
          const double smoothingFactor = 0.3;
          _compassHeading = _compassHeading! * (1 - smoothingFactor) + newHeading * smoothingFactor;
          
          // Normalize to 0-360 range
          if (_compassHeading! < 0) _compassHeading = _compassHeading! + 360;
          if (_compassHeading! >= 360) _compassHeading = _compassHeading! - 360;
        } else {
          _compassHeading = newHeading;
        }
        
        // Round to reduce micro-movements
        _compassHeading = double.parse(_compassHeading!.toStringAsFixed(1));
        
        notifyListeners();
      }
    }).onError((error) {
      _error = 'Compass not available. Please check device sensors and permissions.';
      notifyListeners();
    });
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

  void dispose() {
    // Clean up compass listener if needed
    super.dispose();
  }
}