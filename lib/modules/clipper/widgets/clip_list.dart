/// FILE: lib/modules/clipper/widgets/clip_list.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/clipper_provider.dart';
import '../../../core/settings/settings_provider.dart';

/// Searchable list of saved clips with tags.
class ClipList extends ConsumerWidget {
  const ClipList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clipsAsync = ref.watch(clipsProvider);
    final controller = ref.read(clipsControllerProvider);
    final use24Hour = ref.watch(settingsProvider).valueOrNull?.use24HourFormat ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search clips or tags...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => ref.read(clipSearchQueryProvider.notifier).state = value,
        ),
        const SizedBox(height: 8),
        clipsAsync.when(
          data: (clips) {
            if (clips.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No clips saved yet')),
              );
            }
            return Column(
              children: clips
                  .map((clip) => Card(
                        child: ListTile(
                          title: Text(clip.text, maxLines: 3, overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (clip.tags.isNotEmpty)
                                Wrap(
                                  spacing: 4,
                                  children: clip.tags
                                      .map((t) => Chip(label: Text(t), visualDensity: VisualDensity.compact))
                                      .toList(),
                                ),
                              Text(DateFormat(use24Hour ? 'MMM d, yyyy HH:mm' : 'MMM d, yyyy hh:mm a')
                                  .format(clip.createdAt)),
                            ],
                          ),
                          isThreeLine: clip.tags.isNotEmpty,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: clip.text));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Clip copied')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: clip.id == null ? null : () => controller.deleteClip(clip.id!),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text('Failed to load clips: $err'),
        ),
      ],
    );
  }
}
