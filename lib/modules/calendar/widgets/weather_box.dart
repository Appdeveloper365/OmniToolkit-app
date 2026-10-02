import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../../../../core/services/location_service.dart';

/// Weather info box widget for calendar screen
class WeatherBox extends StatefulWidget {
  final VoidCallback? onRefresh;

  const WeatherBox({
    super.key,
    this.onRefresh,
  });

  @override
  State<WeatherBox> createState() => _WeatherBoxState();
}

class _WeatherBoxState extends State<WeatherBox> {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;

  // Weather - and with it the device-location request - is opt-in: nothing is
  // fetched until the user taps "Show weather". This keeps the privacy-policy
  // promise that location permission is never requested automatically at
  // startup.
  bool _weatherEnabled = false;

  Future<void> _loadWeather() async {
    _weatherEnabled = true;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        setState(() {
          _error = 'Location not available';
          _isLoading = false;
        });
        return;
      }

      final weather = await WeatherService.fetchWeather(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
      );

      setState(() {
        _weatherData = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Weather unavailable';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (_isLoading || !_weatherEnabled) ? null : _loadWeather,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (!_weatherEnabled) {
      return _buildLocationPrompt();
    }

    if (_isLoading) {
      return _buildLoading();
    }

    if (_error != null) {
      return _buildError();
    }

    if (_weatherData == null) {
      return _buildLoading();
    }

    return _buildWeatherInfo();
  }

  /// Opt-in card shown until the user consents to a location request.
  Widget _buildLocationPrompt() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Weather uses your device location',
            style: TextStyle(fontSize: 12),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _loadWeather,
          child: const Text('Show weather', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 10),
        Text('Loading weather...', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildError() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off, size: 20, color: Colors.grey),
        const SizedBox(width: 10),
        Text(_error ?? 'Weather unavailable', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWeatherInfo() {
    final data = _weatherData!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildIcon(data.symbolCode),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.temperature?.round() ?? '--'}°',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(data.condition ?? 'Unknown', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (data.alert != null && data.alert!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              data.alert!,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        const Align(
          alignment: Alignment.bottomRight,
          child: Text('MET Norway', style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic, color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _buildIcon(String? symbolCode) {
    final icon = _getIcon(symbolCode);
    return Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary);
  }

  IconData _getIcon(String? symbolCode) {
    if (symbolCode == null) return Icons.cloud;
    if (symbolCode.contains('clearsky') || symbolCode.contains('fair')) return Icons.wb_sunny;
    if (symbolCode.contains('partlycloudy')) return Icons.wb_cloudy;
    if (symbolCode.contains('cloudy')) return Icons.cloud;
    if (symbolCode.contains('rain')) return Icons.grain;
    if (symbolCode.contains('snow')) return Icons.ac_unit;
    if (symbolCode.contains('sleet')) return Icons.grain_rounded;
    if (symbolCode.contains('fog')) return Icons.foggy;
    return Icons.cloud;
  }
}
