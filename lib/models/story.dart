class Story {
  final String id;
  final List<String> authors;
  final DateTime createdAt;
  final String name;
  final bool finished;
  final int numberOfChapters;

  Story(
    this.id,
    this.authors,
    this.createdAt,
    this.name,
    this.finished,
    this.numberOfChapters,
  );

  factory Story.init(String id, String name) {
    return Story(
      id,
      [],
      DateTime.now(),
      name,
      false,
      1,
    );
  }

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      map['id'],
      (List<String>.from(map['authors'])),
      DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      map['name'],
      map['finished'],
      map['numberOfChapters'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authors': authors,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'name': name,
      'finished': finished,
      'numberOfChapters': numberOfChapters,
    };
  }
}
