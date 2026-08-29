/// FILE: lib/modules/calendar/models/note_model.dart

/// A reminder/note attached to a specific calendar date.
class NoteModel {
  const NoteModel({
    this.id,
    required this.date,
    required this.title,
    this.description,
    this.reminderTime,
  });

  final int? id;
  final DateTime date;
  final String title;
  final String? description;
  final String? reminderTime;

  static String dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': dateKey(date),
      'title': title,
      'description': description,
      'reminderTime': reminderTime,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      description: map['description'] as String?,
      reminderTime: map['reminderTime'] as String?,
    );
  }

  NoteModel copyWith({int? id}) => NoteModel(
        id: id ?? this.id,
        date: date,
        title: title,
        description: description,
        reminderTime: reminderTime,
      );
}
