class Story {
  final String id;
  final List<String> authors;
  final DateTime createdAt;
  final String name;

  Story(
    this.id,
    this.authors,
    this.createdAt,
    this.name,
  );

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      map['id'],
      (List<String>.from(map['authors'])),
      DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      map['name'],
    );
  }
}
