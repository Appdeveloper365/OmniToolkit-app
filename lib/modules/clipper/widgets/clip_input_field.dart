/// FILE: lib/modules/clipper/widgets/clip_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../providers/clipper_provider.dart';
import '../../../core/settings/settings_provider.dart';

/// Text clipping area with a tag input; auto-saves to SQLite on submit.
class ClipInputField extends ConsumerStatefulWidget {
  const ClipInputField({super.key});

  @override
  ConsumerState<ClipInputField> createState() => _ClipInputFieldState();
}

class _ClipInputFieldState extends ConsumerState<ClipInputField> {
  final _textController = TextEditingController();
  final _tagsController = TextEditingController();
  Timer? _autoSaveTimer;
  Timer? _clipboardTimer;
  String? _lastSavedText;
  bool _checkingClipboard = false;

  @override
  void initState() {
    super.initState();
    _clipboardTimer = Timer.periodic(const Duration(seconds: 1), (_) => _pollClipboard());
  }

  @override
  void dispose() {
    _textController.dispose();
    _tagsController.dispose();
    _autoSaveTimer?.cancel();
    _clipboardTimer?.cancel();
    super.dispose();
  }

  void _save() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    _lastSavedText = text;
    ref.read(clipsControllerProvider).addClip(text, tags);
    _textController.clear();
    _tagsController.clear();
  }

  Future<void> _pollClipboard() async {
    if (_checkingClipboard || !mounted ||
        !(ref.read(settingsProvider).valueOrNull?.autoSaveClips ?? true)) {
      return;
    }
    _checkingClipboard = true;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim();
      if (text != null && text.isNotEmpty && text != _lastSavedText) {
        _lastSavedText = text;
        await ref.read(clipsControllerProvider).addClip(text, const []);
      }
    } finally {
      _checkingClipboard = false;
    }
  }

  void _scheduleAutoSave(String value) {
    _autoSaveTimer?.cancel();
    if (value.trim().isEmpty ||
        !(ref.read(settingsProvider).valueOrNull?.autoSaveClips ?? true)) {
      return;
    }
    _autoSaveTimer = Timer(const Duration(milliseconds: 900), _save);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Clip text',
                hintText: 'Paste or type text to save...',
              ),
              onChanged: _scheduleAutoSave,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) {
                  _textController.text = data!.text!;
                  _scheduleAutoSave(data.text!);
                  setState(() {});
                }
              },
              icon: const Icon(Icons.content_paste),
              label: const Text('Paste & auto-save'),
            ),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                hintText: 'e.g. work, ideas',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save Clip'),
            ),
          ],
        ),
      ),
    );
  }
}
