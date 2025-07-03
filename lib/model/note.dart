class Note {
  final int id;
  final String title;
  final String content;
  final int color;
  final bool pinned;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.pinned,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      content: json['content'],
      color: int.parse(json['color'].toString()),
      pinned: json['pinned'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
      'pinned':pinned,
      'createdAt':createdAt
    };
  }
}
