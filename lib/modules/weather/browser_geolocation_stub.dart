/// FILE: lib/modules/weather/browser_geolocation_stub.dart

/// Non-web builds have no browser geolocation API: resolve null immediately
/// so the weather service falls back to its default city.
Future<({double latitude, double longitude})?> browserGeolocationPosition() async {
  return null;
}
