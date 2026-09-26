/// FILE: lib/modules/weather/widgets/weather_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../weather_provider.dart';

/// Live weather box that pairs with the dual-time clock in the calendar
/// header: automatic location detection, current temperature, condition
/// icon and phrase, and the mandatory WeatherAPI.com attribution. Refreshes
/// every 15 minutes; tapping it after a failure retries immediately.
class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  static const _accent = Color(0xFF818CF8); // indigo, pairs with the clock's cyan

  Future<void> _openAttribution() async {
    final url = Uri.parse('https://www.weatherapi.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(weatherProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      // Tap-to-retry is only meaningful after a failure.
      onTap: state is WeatherOffline
          ? () => ref.read(weatherProvider.notifier).refreshNow()
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                : const [Color(0xFFEEF2FF), Color(0xFFF1F5F9)],
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.wb_cloudy_rounded,
                  size: 18,
                  color: _accent,
                ),
                const SizedBox(width: 6),
                Text(
                  'Live Weather',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? const Color(0xFFEEF2FF) : const Color(0xFF3730A3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _WeatherBody(state: state, isDark: isDark),
            const SizedBox(height: 10),
            // Mandatory WeatherAPI.com attribution.
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: _openAttribution,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  child: Text(
                    'Weather data by WeatherAPI.com',
                    style: TextStyle(
                      fontSize: 9,
                      decoration: TextDecoration.underline,
                      decorationColor: isDark ? Colors.white24 : Colors.black26,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Location, temperature, condition icon, and live phrase row -- varies by
/// [WeatherUiState].
class _WeatherBody extends StatelessWidget {
  const _WeatherBody({required this.state, required this.isDark});

  final WeatherUiState state;
  final bool isDark;

  static const _tempStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    height: 1.1,
  );

  @override
  Widget build(BuildContext context) {
    final locationColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    switch (state) {
      case WeatherLoading():
        return _content(
          location: 'Detecting...',
          locationColor: locationColor,
          temp: '--°C',
          icon: const _BouncingIcon(icon: Icons.my_location_rounded),
          phrase: 'Locating radar...',
          pulseColor: WeatherWidget._accent,
        );
      case WeatherOk(:final snapshot):
        return _content(
          location: snapshot.locationName.isEmpty
              ? 'Current location'
              : snapshot.locationName,
          locationColor: locationColor,
          temp: snapshot.tempLabel,
          icon: _ConditionIcon(iconUrl: snapshot.iconUrl),
          phrase: snapshot.conditionText.isEmpty
              ? 'Conditions updated'
              : snapshot.conditionText,
          pulseColor: const Color(0xFF34D399), // emerald: live data flowing
        );
      case WeatherPreview():
        return _content(
          location: 'Local Space',
          locationColor: locationColor,
          temp: '21°C',
          icon: const Icon(
            Icons.wb_sunny_rounded,
            size: 28,
            color: Color(0xFFFBBF24),
          ),
          phrase: 'Sunny intervals',
          pulseColor: WeatherWidget._accent,
        );
      case WeatherOffline():
        return _content(
          location: 'Offline',
          locationColor: locationColor,
          temp: '--°C',
          icon: const Icon(
            Icons.wifi_off_rounded,
            size: 26,
            color: Color(0xFFFB7185), // rose
          ),
          phrase: 'Weather unavailable - tap to retry',
          pulseColor: const Color(0xFFFB7185),
        );
    }
  }

  Widget _content({
    required String location,
    required Color locationColor,
    required String temp,
    required Widget icon,
    required String phrase,
    required Color pulseColor,
  }) {
    final isDarkTheme = isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: locationColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    temp,
                    style: _tempStyle.copyWith(
                      color: isDarkTheme ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            icon,
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0x11334155))),
          ),
          child: Row(
            children: [
              _PulseDot(color: pulseColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  phrase,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: isDarkTheme
                        ? const Color(0xFFA5B4FC)
                        : const Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The current condition icon from WeatherAPI's CDN, falling back to a
/// neutral icon when the URL is empty or the network image fails.
class _ConditionIcon extends StatelessWidget {
  const _ConditionIcon({required this.iconUrl});

  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    if (iconUrl.isEmpty) {
      return const Icon(
        Icons.wb_cloudy_rounded,
        size: 28,
        color: WeatherWidget._accent,
      );
    }
    return Image.network(
      iconUrl,
      width: 28,
      height: 28,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.wb_cloudy_rounded,
        size: 28,
        color: WeatherWidget._accent,
      ),
    );
  }
}

/// Small bouncing location marker used while the position is resolving.
class _BouncingIcon extends StatefulWidget {
  const _BouncingIcon({required this.icon});

  final IconData icon;

  @override
  State<_BouncingIcon> createState() => _BouncingIconState();
}

class _BouncingIconState extends State<_BouncingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_controller),
      child: Icon(widget.icon, size: 24, color: WeatherWidget._accent),
    );
  }
}

/// Softly pulsing status dot next to the live phrase line.
class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color});

  final Color color;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_controller),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
