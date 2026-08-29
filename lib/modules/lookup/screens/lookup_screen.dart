/// FILE: lib/modules/lookup/screens/lookup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lookup_provider.dart';

class LookupScreen extends ConsumerStatefulWidget {
  const LookupScreen({super.key});

  @override
  ConsumerState<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends ConsumerState<LookupScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _hintFor(LookupMode mode) {
    switch (mode) {
      case LookupMode.byZip:
        return 'Enter a ZIP code, e.g. 10001';
      case LookupMode.byCity:
        return 'Enter a city or county name, e.g. Austin or Travis County';
      case LookupMode.byAreaCode:
        return 'Enter a 3-digit area code, e.g. 212';
    }
  }

  void _onModeChanged(LookupMode newMode) {
    _controller.clear();
    ref.read(lookupModeProvider.notifier).state = newMode;
    ref.read(lookupQueryProvider.notifier).state = '';
  }

  void _onSelected(String selection) {
    final clean = selection.contains('(')
        ? selection.substring(0, selection.indexOf('(')).trim()
        : selection;

    _controller.text = clean;
    ref.read(lookupQueryProvider.notifier).state = clean;
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(lookupModeProvider);
    final suggestions = mode == LookupMode.byAreaCode
        ? ref.watch(areaCodeCitySuggestionsProvider).valueOrNull ?? const []
        : ref.watch(lookupSuggestionsProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZIP / Area / City Lookup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // MODE SWITCHER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text('ZIP → City'),
                  selected: mode == LookupMode.byZip,
                  onSelected: (_) => _onModeChanged(LookupMode.byZip),
                ),
                ChoiceChip(
                  label: const Text('City/County → ZIP'),
                  selected: mode == LookupMode.byCity,
                  onSelected: (_) => _onModeChanged(LookupMode.byCity),
                ),
                ChoiceChip(
                  label: const Text('Area → Region'),
                  selected: mode == LookupMode.byAreaCode,
                  onSelected: (_) => _onModeChanged(LookupMode.byAreaCode),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // AUTOCOMPLETE FIELD (FIXED)
            Autocomplete<String>(
              focusNode: _focusNode,
              textEditingController: _controller,
              optionsBuilder: (TextEditingValue value) {
                if (value.text.isEmpty) return const Iterable<String>.empty();
                return suggestions;
              },
              onSelected: _onSelected,
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: _hintFor(mode),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    ref.read(lookupQueryProvider.notifier).state = text;
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // RESULTS
            Expanded(
              child: mode == LookupMode.byAreaCode
                  ? Consumer(
                      builder: (context, ref, _) {
                        final resultsAsync = ref.watch(areaCodeCityResultsProvider);

                        return resultsAsync.when(
                          data: (results) {
                            if (results.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No results yet. Start typing above.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final entry = results[index];
                                final details = [
                                  if (entry.lat != null && entry.lng != null)
                                    '${entry.lat!.toStringAsFixed(4)}, ${entry.lng!.toStringAsFixed(4)}',
                                  if (entry.country != null && entry.country!.isNotEmpty) entry.country!,
                                ].join('  •  ');
                                return ListTile(
                                  title: Text('${entry.city}, ${entry.state}'),
                                  subtitle: Text('Area code: ${entry.areaCode}${details.isNotEmpty ? '  •  $details' : ''}'),
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Center(child: Text('Lookup failed: $err')),
                        );
                      },
                    )
                  : Consumer(
                      builder: (context, ref, _) {
                        final resultsAsync = ref.watch(lookupResultsProvider);

                        return resultsAsync.when(
                          data: (results) {
                            if (results.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No results yet. Start typing above.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final entry = results[index];
                                final details = [
                                  if (entry.county != null && entry.county!.isNotEmpty) entry.county!,
                                  if (entry.areaCode.isNotEmpty) 'Area code: ${entry.areaCode}',
                                  if (entry.timezone != null && entry.timezone!.isNotEmpty) entry.timezone!,
                                ].join('  •  ');
                                return ListTile(
                                  title: Text('${entry.city}, ${entry.state} ${entry.zip}'),
                                  subtitle: details.isNotEmpty ? Text(details) : null,
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Center(child: Text('Lookup failed: $err')),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
