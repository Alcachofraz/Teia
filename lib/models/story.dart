class Story {
  final String id;
  final List<String> authors;
  final DateTime createdAt;
  final String name;
  final bool finished;

  Story(
    this.id,
    this.authors,
    this.createdAt,
    this.name,
    this.finished,
  );

  factory Story.init(String id, String name) {
    return Story(
      id,
      [],
      DateTime.now(),
      name,
      false,
    );
  }

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      map['id'],
      (List<String>.from(map['authors'])),
      DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      map['name'],
      map['finished'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authors': authors,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'name': name,
      'finished': finished,
    };
  }
}
