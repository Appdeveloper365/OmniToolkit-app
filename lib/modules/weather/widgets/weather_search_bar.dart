/// FILE: lib/modules/weather/widgets/weather_search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/city_model.dart';
import '../providers/weather_provider.dart';

/// Search field that lets the user find any place on Earth and select it.
class WeatherSearchBar extends ConsumerStatefulWidget {
  const WeatherSearchBar({super.key});

  @override
  ConsumerState<WeatherSearchBar> createState() => _WeatherSearchBarState();
}

class _WeatherSearchBarState extends ConsumerState<WeatherSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showResults = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectCity(CityModel city) {
    ref.read(selectedCityProvider.notifier).state = city;
    _controller.clear();
    ref.read(citySearchQueryProvider.notifier).state = '';
    setState(() => _showResults = false);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(citySearchResultsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search any city or place on Earth...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(citySearchQueryProvider.notifier).state = '';
                      setState(() => _showResults = false);
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            ref.read(citySearchQueryProvider.notifier).state = value;
            setState(() => _showResults = value.trim().length >= 2);
          },
        ),
        if (_showResults)
          resultsAsync.when(
            data: (cities) {
              if (cities.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('No matching places found'),
                );
              }
              return Card(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      return ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(city.name),
                        subtitle: Text(city.displayName),
                        onTap: () => _selectCity(city),
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: LinearProgressIndicator(),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Search failed: $err'),
            ),
          ),
      ],
    );
  }
}
