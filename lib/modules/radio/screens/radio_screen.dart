/// FILE: lib/modules/radio/screens/radio_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/station_model.dart';
import '../providers/radio_provider.dart';
import '../services/radio_service.dart';
import '../widgets/now_playing_panel.dart';
import '../widgets/radio_header.dart';
import '../widgets/radio_keyboard_shortcuts.dart';
import '../widgets/station_card.dart';

class RadioScreen extends ConsumerStatefulWidget {
  const RadioScreen({super.key});

  @override
  ConsumerState<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends ConsumerState<RadioScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedGenre = ref.watch(selectedGenreProvider);
    final selectedCountry = ref.watch(selectedCountryProvider);
    final stationsAsync = ref.watch(stationListProvider);
    final favoritesAsync = ref.watch(favoritesProvider);

    return RadioKeyboardShortcuts(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const RadioHeader(),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(icon: Icon(Icons.search_rounded, size: 20), text: 'Browse'),
                  Tab(icon: Icon(Icons.public_rounded, size: 20), text: 'Countries'),
                  Tab(icon: Icon(Icons.category_rounded, size: 20), text: 'Genres'),
                  Tab(icon: Icon(Icons.favorite_rounded, size: 20), text: 'Favorites'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Browse / Search
                    _buildBrowseTab(
                      context,
                      ref,
                      selectedCategory,
                      stationsAsync,
                      isDark,
                    ),

                    // Tab 2: Country Directory
                    _buildCountriesTab(
                      context,
                      ref,
                      selectedCountry,
                      stationsAsync,
                      isDark,
                    ),

                    // Tab 3: Genre Directory
                    _buildGenresTab(
                      context,
                      ref,
                      selectedGenre,
                      stationsAsync,
                      isDark,
                    ),

                    // Tab 4: Favorites
                    _buildFavoritesTab(
                      context,
                      ref,
                      favoritesAsync,
                      isDark,
                    ),
                  ],
                ),
              ),
              const NowPlayingPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseTab(
    BuildContext context,
    WidgetRef ref,
    String? selectedCategory,
    AsyncValue<List<StationModel>> stationsAsync,
    bool isDark,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by station name, city, country, genre...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(radioSearchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              ref.read(radioSearchQueryProvider.notifier).state = value;
              setState(() {});
            },
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: const Text('Top Stations'),
                  selected: selectedCategory == null,
                  onSelected: (_) {
                    ref.read(selectedCategoryProvider.notifier).state = null;
                  },
                ),
              ),
              for (final cat in RadioService.genres)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selectedCategory == cat,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state = cat;
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: _buildStationListView(stationsAsync, 'Choose a station to begin listening.'),
        ),
      ],
    );
  }

  Widget _buildCountriesTab(
    BuildContext context,
    WidgetRef ref,
    CountryInfo? selectedCountry,
    AsyncValue<List<StationModel>> stationsAsync,
    bool isDark,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: RadioService.countries.length,
              itemBuilder: (context, index) {
                final c = RadioService.countries[index];
                final isSel = selectedCountry?.code == c.code;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Text(c.flag, style: const TextStyle(fontSize: 16)),
                    label: Text(c.name),
                    selected: isSel,
                    onSelected: (_) {
                      ref.read(selectedCountryProvider.notifier).state = isSel ? null : c;
                    },
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: _buildStationListView(
            stationsAsync,
            selectedCountry != null
                ? 'No stations found for ${selectedCountry.name}'
                : 'Select a country above to load radio stations.',
          ),
        ),
      ],
    );
  }

  Widget _buildGenresTab(
    BuildContext context,
    WidgetRef ref,
    String? selectedGenre,
    AsyncValue<List<StationModel>> stationsAsync,
    bool isDark,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RadioService.genres.map((g) {
              final isSel = selectedGenre == g;
              return FilterChip(
                label: Text(g),
                selected: isSel,
                onSelected: (_) {
                  ref.read(selectedGenreProvider.notifier).state = isSel ? null : g;
                },
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: _buildStationListView(
            stationsAsync,
            selectedGenre != null
                ? 'No stations found for genre "$selectedGenre"'
                : 'Select a genre above to load stations.',
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<StationModel>> favoritesAsync,
    bool isDark,
  ) {
    return favoritesAsync.when(
      data: (favorites) {
        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 64,
                  color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                ),
                const SizedBox(height: 12),
                Text(
                  'No favorite stations saved yet.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap the heart icon on any station card to save it here.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: favorites.length,
          itemBuilder: (context, index) => StationCard(station: favorites[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Failed to load favorites: $err')),
    );
  }

  Widget _buildStationListView(
    AsyncValue<List<StationModel>> stationsAsync,
    String emptyMessage,
  ) {
    return stationsAsync.when(
      data: (stations) {
        if (stations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.radio_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  emptyMessage,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: stations.length,
          itemBuilder: (context, index) => StationCard(station: stations[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Failed to load stations: $err')),
    );
  }
}
