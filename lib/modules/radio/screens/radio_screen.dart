/// FILE: lib/modules/radio/screens/radio_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/radio_provider.dart';
import '../services/radio_service.dart';
import '../widgets/now_playing_bar.dart';
import '../widgets/station_tile.dart';

class RadioScreen extends ConsumerStatefulWidget {
  const RadioScreen({super.key});

  @override
  ConsumerState<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends ConsumerState<RadioScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final stationsAsync = ref.watch(stationListProvider);
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radio & TV Streaming'),
        actions: [
          IconButton(
            tooltip: 'Test Stream',
            icon: const Icon(Icons.bug_report_outlined),
            onPressed: () => ref.read(radioPlaybackControllerProvider)
                .play(RadioService.fallbackStations.first),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Browse'), Tab(text: 'Favorites')],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search stations...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) => ref.read(radioSearchQueryProvider.notifier).state = value,
                      ),
                    ),
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: const Text('Top'),
                              selected: selectedCategory == null,
                              onSelected: (_) => ref.read(selectedCategoryProvider.notifier).state = null,
                            ),
                          ),
                          for (final category in RadioService.categories)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Text(category),
                                selected: selectedCategory == category,
                                onSelected: (_) =>
                                    ref.read(selectedCategoryProvider.notifier).state = category,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: stationsAsync.when(
                        data: (stations) {
                          if (stations.isEmpty) {
                            return const Center(child: Text('No stations found'));
                          }
                          return ListView.builder(
                            itemCount: stations.length,
                            itemBuilder: (context, index) => StationTile(station: stations[index]),
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Center(child: Text('Failed to load stations: $err')),
                      ),
                    ),
                  ],
                ),
                favoritesAsync.when(
                  data: (favorites) {
                    if (favorites.isEmpty) {
                      return const Center(child: Text('No favorites yet. Tap the heart icon to save one.'));
                    }
                    return ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) => StationTile(station: favorites[index]),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Failed to load favorites: $err')),
                ),
              ],
            ),
          ),
          const NowPlayingBar(),
        ],
      ),
    );
  }
}
