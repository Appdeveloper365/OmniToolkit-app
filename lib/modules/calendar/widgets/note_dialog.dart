/// FILE: lib/modules/calendar/widgets/note_dialog.dart
import 'package:flutter/material.dart';

import '../models/note_model.dart';

/// Dialog for creating or editing a note on a given date.
class NoteDialog extends StatefulWidget {
  const NoteDialog({super.key, required this.date, this.existing});

  final DateTime date;
  final NoteModel? existing;

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final _noteController =
      TextEditingController(text: widget.existing?.noteText ?? '');

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Note' : 'Edit Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
              maxLines: 4,
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final text = _noteController.text.trim();
            if (text.isEmpty) return;
            final note = NoteModel(
              id: widget.existing?.id,
              date: widget.date,
              noteText: text,
              createdAt: widget.existing?.createdAt,
            );
            Navigator.pop(context, note);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}