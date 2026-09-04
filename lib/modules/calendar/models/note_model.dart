/// FILE: lib/modules/calendar/models/note_model.dart

/// A note attached to a specific calendar date. Multiple notes can exist
/// for the same date; they are displayed in chronological order using
/// [createdAt].
class NoteModel {
  const NoteModel({
    this.id,
    required this.date,
    required this.noteText,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final DateTime date;
  final String noteText;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() {
    final now = DateTime.now().toIso8601String();
    return {
      if (id != null) 'id': id,
      'note_date': dateKey(date),
      'note_text': noteText,
      'created_at': createdAt?.toIso8601String() ?? now,
      'updated_at': now,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      date: DateTime.parse(map['note_date'] as String),
      noteText: map['note_text'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  NoteModel copyWith({int? id, String? noteText}) => NoteModel(
        id: id ?? this.id,
        date: date,
        noteText: noteText ?? this.noteText,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}