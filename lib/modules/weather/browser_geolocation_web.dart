/// FILE: lib/modules/weather/browser_geolocation_web.dart
import 'dart:async';

import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Resolves the browser's current position via the Geolocation API, or null
/// when the user denies the permission prompt, the browser has no geolocation
/// support, or the request stalls. The weather service treats null as "use
/// the fallback city".
Future<({double latitude, double longitude})?> browserGeolocationPosition() {
  final completer = Completer<({double latitude, double longitude})?>();
  try {
    final geolocation = web.window.navigator.geolocation;
    geolocation.getCurrentPosition(
      ((web.GeolocationPosition position) {
        if (!completer.isCompleted) {
          completer.complete((
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
          ));
        }
      }).toJS,
      ((web.GeolocationPositionError _) {
        if (!completer.isCompleted) completer.complete(null);
      }).toJS,
    );
  } catch (_) {
    if (!completer.isCompleted) completer.complete(null);
  }

  return completer.future.timeout(
    const Duration(seconds: 10),
    onTimeout: () => null,
  );
}
