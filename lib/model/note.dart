class Note {
  final int id;
  final String title;
  final String content;
  final int color;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: int.parse(json['id'].toString()), // convert về int an toàn
      title: json['title'],
      content: json['content'],
      color: int.parse(json['color'].toString()), // convert về int an toàn
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color,
    };
  }
}
