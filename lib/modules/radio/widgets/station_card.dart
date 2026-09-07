/// FILE: lib/modules/radio/widgets/station_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/station_model.dart';
import '../providers/radio_provider.dart';
import 'station_logo_widget.dart';

class StationCard extends ConsumerWidget {
  const StationCard({super.key, required this.station});

  final StationModel station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.valueOrNull?.any((s) => s.id == station.id) ?? false;
    final radioState = ref.watch(radioStateProvider);
    final isSelected = radioState.currentStation?.id == station.id;
    final isPlaying = isSelected && radioState.status == RadioStatus.live;
    final controller = ref.read(radioPlaybackControllerProvider);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isSelected
        ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE))
        : (isDark ? const Color(0xFF0F172A).withOpacity(0.7) : Colors.white);

    final borderColor = isSelected
        ? (isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7))
        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: isSelected ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.play(station),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                StationLogoWidget(
                  logoUrl: station.favicon,
                  size: 44,
                  borderRadius: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${station.category}${station.country.isNotEmpty ? " • ${station.country}" : ""}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? const Color(0xFFEF4444) : null,
                      ),
                      onPressed: () => ref.read(favoritesProvider.notifier).toggle(station),
                    ),
                    IconButton(
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                        color: isSelected
                            ? (isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7))
                            : theme.colorScheme.primary,
                        size: 32,
                      ),
                      onPressed: () {
                        if (isSelected) {
                          controller.togglePlayPause();
                        } else {
                          controller.play(station);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
