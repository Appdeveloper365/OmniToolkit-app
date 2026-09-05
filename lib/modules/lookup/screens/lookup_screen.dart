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
        return 'Enter ZIP code (e.g. 10001 or 90210)...';
      case LookupMode.byCity:
        return 'Enter City or County name (e.g. Austin or Travis)...';
      case LookupMode.byAreaCode:
        return 'Enter 3-digit Area Code (e.g. 212 or 310)...';
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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('US Location & Area Code Lookup'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // MODERN SEGMENTED / TAB SWITCHER
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    _buildTabButton(
                      context: context,
                      label: 'ZIP → City',
                      icon: Icons.pin_drop_rounded,
                      isSelected: mode == LookupMode.byZip,
                      onTap: () => _onModeChanged(LookupMode.byZip),
                    ),
                    _buildTabButton(
                      context: context,
                      label: 'City / County',
                      icon: Icons.location_city_rounded,
                      isSelected: mode == LookupMode.byCity,
                      onTap: () => _onModeChanged(LookupMode.byCity),
                    ),
                    _buildTabButton(
                      context: context,
                      label: 'Area Code',
                      icon: Icons.phone_in_talk_rounded,
                      isSelected: mode == LookupMode.byAreaCode,
                      onTap: () => _onModeChanged(LookupMode.byAreaCode),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // AUTOCOMPLETE SEARCH FIELD
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
                      hintText: _hintFor(mode),
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                controller.clear();
                                ref.read(lookupQueryProvider.notifier).state = '';
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                    ),
                    onChanged: (text) {
                      ref.read(lookupQueryProvider.notifier).state = text;
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // RESULTS SECTION
              Expanded(
                child: mode == LookupMode.byAreaCode
                    ? _buildAreaCodeResults(context, ref, isDark)
                    : _buildLookupResults(context, ref, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7)).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.black : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.black : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLookupResults(BuildContext context, WidgetRef ref, bool isDark) {
    final resultsAsync = ref.watch(lookupResultsProvider);

    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 48, color: isDark ? Colors.grey[700] : Colors.grey[400]),
                const SizedBox(height: 12),
                const Text(
                  'No lookup results found.',
                  style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Type a ZIP code (e.g. 90210), City (e.g. Dallas), or County name above.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final entry = results[index];
            final hasCounty = entry.county != null && entry.county!.isNotEmpty;
            final hasArea = entry.areaCode.isNotEmpty;
            final hasTz = entry.timezone != null && entry.timezone!.isNotEmpty;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE),
                  child: Text(
                    entry.state,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7),
                    ),
                  ),
                ),
                title: Text(
                  '${entry.city}, ${entry.state}  ${entry.zip}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (hasCounty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.map_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('County: ${entry.county}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      if (hasArea)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Area: ${entry.areaCode}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      if (hasTz)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('TZ: ${entry.timezone}', style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Lookup failed: $err')),
    );
  }

  Widget _buildAreaCodeResults(BuildContext context, WidgetRef ref, bool isDark) {
    final resultsAsync = ref.watch(areaCodeCityResultsProvider);

    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_missed_rounded, size: 48, color: isDark ? Colors.grey[700] : Colors.grey[400]),
                const SizedBox(height: 12),
                const Text(
                  'No area code results found.',
                  style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Type a 3-digit area code (e.g. 212, 415, 704) above.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final entry = results[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEE2E2),
                  child: Text(
                    entry.areaCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                    ),
                  ),
                ),
                title: Text(
                  '${entry.city}, ${entry.state}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: entry.lat != null && entry.lng != null
                    ? Text('Coordinates: ${entry.lat!.toStringAsFixed(4)}, ${entry.lng!.toStringAsFixed(4)}')
                    : null,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Lookup failed: $err')),
    );
  }
}
