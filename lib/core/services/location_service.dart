import 'package:geolocator/geolocator.dart';

/// Service for handling platform location access
class LocationService {
  /// Get current position with permission handling
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    Permission permission = await Geolocator.checkPermission();
    if (permission == Permission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == Permission.denied) {
        return null;
      }
    }

    if (permission == Permission.deniedForever) {
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  static Future<Position?> getCurrentPositionWithTimeout({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: timeout,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> hasPermission() async {
    Permission permission = await Geolocator.checkPermission();
    return permission == Permission.whileInUse || permission == Permission.always;
  }

  static Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition(
        accuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  static double calculateDistance(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }
}
