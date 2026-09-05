/// FILE: lib/modules/radio/widgets/now_playing_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/radio_provider.dart';
import 'audio_visualizer_widget.dart';
import 'station_logo_widget.dart';

class NowPlayingPanel extends ConsumerWidget {
  const NowPlayingPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(radioStateProvider);
    final station = state.currentStation;
    final favorites = ref.watch(favoritesProvider);
    final controller = ref.read(radioPlaybackControllerProvider);

    if (station == null) return const SizedBox.shrink();

    final isFavorite = favorites.valueOrNull?.any((s) => s.id == station.id) ?? false;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color badgeColor;
    switch (state.status) {
      case RadioStatus.live:
        badgeColor = const Color(0xFF10B981); // Emerald Green
        break;
      case RadioStatus.buffering:
      case RadioStatus.reconnecting:
        badgeColor = const Color(0xFFF59E0B); // Amber Yellow
        break;
      case RadioStatus.offline:
        badgeColor = const Color(0xFFEF4444); // Red
        break;
      case RadioStatus.stopped:
        badgeColor = const Color(0xFF6B7280); // Gray
        break;
    }

    final detailParts = <String>[];
    if (station.country.isNotEmpty) detailParts.add(station.country);
    if (station.language != null && station.language!.isNotEmpty) detailParts.add(station.language!);
    if (station.category.isNotEmpty) detailParts.add(station.category);
    if (station.bitrate != null && station.bitrate! > 0) detailParts.add('${station.bitrate} kbps');
    final detailString = detailParts.join(' • ');

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row: Station Logo + Name & Details + Status Badge
            Row(
              children: [
                StationLogoWidget(
                  logoUrl: station.favicon,
                  size: 56,
                  borderRadius: 14,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (detailString.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            detailString,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Real-time Connectivity Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: badgeColor, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.statusText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Error banner if insecure or failed
            if (state.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 18,
                      color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? const Color(0xFFFEE2E2) : const Color(0xFF991B1B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Visualizer & Controls
            Row(
              children: [
                AudioVisualizerWidget(status: state.status, height: 32),
                const Spacer(),
                // Favorite Toggle
                IconButton(
                  tooltip: isFavorite ? 'Remove Favorite' : 'Save Favorite',
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? const Color(0xFFEF4444) : null,
                  ),
                  onPressed: () => ref.read(favoritesProvider.notifier).toggle(station),
                ),
              ],
            ),

            const Divider(height: 20),

            // Player Controls Bar (Previous, Play/Pause, Stop, Next)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Previous Favorite Button
                SizedBox(
                  width: 54,
                  height: 54,
                  child: IconButton(
                    tooltip: 'Previous Favorite',
                    icon: const Icon(Icons.skip_previous_rounded, size: 28),
                    onPressed: controller.previousFavorite,
                  ),
                ),

                // Play / Pause Button
                SizedBox(
                  width: 64,
                  height: 64,
                  child: FloatingActionButton(
                    heroTag: 'now_playing_play_pause_fab',
                    elevation: 4,
                    backgroundColor: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7),
                    foregroundColor: Colors.black,
                    onPressed: controller.togglePlayPause,
                    child: Icon(
                      state.status == RadioStatus.live
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 36,
                    ),
                  ),
                ),

                // Stop Button
                SizedBox(
                  width: 54,
                  height: 54,
                  child: IconButton(
                    tooltip: 'Stop Playback',
                    icon: const Icon(Icons.stop_rounded, size: 28, color: Colors.red),
                    onPressed: controller.stop,
                  ),
                ),

                // Next Favorite Button
                SizedBox(
                  width: 54,
                  height: 54,
                  child: IconButton(
                    tooltip: 'Next Favorite',
                    icon: const Icon(Icons.skip_next_rounded, size: 28),
                    onPressed: controller.nextFavorite,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Volume Control Slider & Mute Toggle
            Row(
              children: [
                IconButton(
                  tooltip: state.isMuted ? 'Unmute' : 'Mute',
                  icon: Icon(
                    state.isMuted || state.volume == 0
                        ? Icons.volume_off_rounded
                        : state.volume < 0.5
                            ? Icons.volume_down_rounded
                            : Icons.volume_up_rounded,
                    color: state.isMuted ? Colors.red : null,
                  ),
                  onPressed: controller.toggleMute,
                ),
                Expanded(
                  child: Slider(
                    value: state.isMuted ? 0.0 : state.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) => controller.setVolume(val),
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    '${((state.isMuted ? 0.0 : state.volume) * 100).round()}%',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
