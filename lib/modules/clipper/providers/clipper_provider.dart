/// FILE: lib/modules/clipper/providers/clipper_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/clip_model.dart';
import '../services/clipper_db_service.dart';
import '../services/password_generator_service.dart';

final clipperDbServiceProvider = Provider((ref) => ClipperDbService());
final passwordGeneratorServiceProvider = Provider((ref) => PasswordGeneratorService());

final clipSearchQueryProvider = StateProvider<String>((ref) => '');

final clipsProvider = FutureProvider<List<ClipModel>>((ref) async {
  final query = ref.watch(clipSearchQueryProvider).trim();
  final service = ref.watch(clipperDbServiceProvider);
  return query.isEmpty ? service.allClips() : service.search(query);
});

class ClipsController {
  ClipsController(this.ref);
  final Ref ref;

  Future<void> addClip(String text, List<String> tags) async {
    if (text.trim().isEmpty) return;
    await ref.read(clipperDbServiceProvider).insertClip(
          ClipModel(text: text.trim(), tags: tags, createdAt: DateTime.now()),
        );
    ref.invalidate(clipsProvider);
  }

  Future<void> deleteClip(int id) async {
    await ref.read(clipperDbServiceProvider).deleteClip(id);
    ref.invalidate(clipsProvider);
  }
}

final clipsControllerProvider = Provider((ref) => ClipsController(ref));

/// Password generator settings.
final passwordLengthProvider = StateProvider<double>((ref) => 16);
final includeUppercaseProvider = StateProvider<bool>((ref) => true);
final includeNumbersProvider = StateProvider<bool>((ref) => true);
final includeSymbolsProvider = StateProvider<bool>((ref) => true);
final generatedPasswordProvider = StateProvider<String>((ref) => '');
