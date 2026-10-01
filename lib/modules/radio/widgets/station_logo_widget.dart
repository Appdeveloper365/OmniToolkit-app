/// FILE: lib/modules/radio/widgets/station_logo_widget.dart
import 'package:flutter/material.dart';

class StationLogoWidget extends StatelessWidget {
  const StationLogoWidget({
    super.key,
    this.logoUrl,
    this.size = 48.0,
    this.borderRadius = 12.0,
  });

  final String? logoUrl;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.radio_rounded,
          size: size * 0.5,
          color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7),
        ),
      ),
    );

    if (logoUrl == null || logoUrl!.trim().isEmpty) {
      return fallback;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        logoUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // On the web, render station logos through a real <img> element instead
        // of fetching the bytes via XHR. Flutter's default path fetches remote
        // images with `fetch`, which the Content-Security-Policy governs through
        // `connect-src`; station logos come from arbitrary third-party hosts
        // (CDNs, broadcaster sites) that cannot be enumerated in the policy.
        // Using the HTML element strategy makes them obey `img-src`, which
        // already permits https: images. This is a no-op on native platforms.
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (context, error, stackTrace) => fallback,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return fallback;
        },
      ),
    );
  }
}
