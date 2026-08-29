/// FILE: lib/modules/calendar/widgets/note_dialog.dart
import 'package:flutter/material.dart';

import '../models/note_model.dart';

/// Dialog for creating or editing a note/reminder on a given date.
class NoteDialog extends StatefulWidget {
  const NoteDialog({super.key, required this.date, this.existing});

  final DateTime date;
  final NoteModel? existing;

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late final _titleController =
      TextEditingController(text: widget.existing?.title ?? '');
  late final _descriptionController =
      TextEditingController(text: widget.existing?.description ?? '');
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    final existingTime = widget.existing?.reminderTime;
    if (existingTime != null) {
      final parts = existingTime.split(':');
      _reminderTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Note / Reminder' : 'Edit Note'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.alarm),
              title: Text(_reminderTime == null
                  ? 'No reminder time'
                  : 'Reminder at ${_reminderTime!.format(context)}'),
              trailing: TextButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _reminderTime = picked);
                },
                child: const Text('Set'),
              ),
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
            final title = _titleController.text.trim();
            if (title.isEmpty) return;
            final note = NoteModel(
              id: widget.existing?.id,
              date: widget.date,
              title: title,
              description: _descriptionController.text.trim(),
              reminderTime: _reminderTime == null
                  ? null
                  : '${_reminderTime!.hour.toString().padLeft(2, '0')}:'
                      '${_reminderTime!.minute.toString().padLeft(2, '0')}',
            );
            Navigator.pop(context, note);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
