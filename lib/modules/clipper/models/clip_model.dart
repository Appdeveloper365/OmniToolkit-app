/// FILE: lib/modules/clipper/models/clip_model.dart

/// A saved text clip with optional comma-separated tags.
class ClipModel {
  const ClipModel({
    this.id,
    required this.text,
    required this.tags,
    required this.createdAt,
  });

  final int? id;
  final String text;
  final List<String> tags;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'text': text,
        'tags': tags.join(','),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ClipModel.fromMap(Map<String, dynamic> map) => ClipModel(
        id: map['id'] as int?,
        text: map['text'] as String,
        tags: (map['tags'] as String? ?? '')
            .split(',')
            .where((t) => t.trim().isNotEmpty)
            .toList(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  ClipModel copyWith({int? id, String? text, List<String>? tags}) => ClipModel(
        id: id ?? this.id,
        text: text ?? this.text,
        tags: tags ?? this.tags,
        createdAt: createdAt,
      );
}
