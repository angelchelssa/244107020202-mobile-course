class Note {
  final dynamic id;
  final String title;
  final String content;
  final DateTime? updatedAt;

  const Note({
    required this.id,
    required this.title,
    this.content = '',
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'],
        title: map['title'] as String,
        content: map['content'] as String? ?? '',
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null,
      );
}
