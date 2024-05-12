class Story {
  final String id;
  final List<String> authors;
  final String title;

  Story(this.id, this.authors, this.title);

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      map['id'],
      (map['authors'] ?? []),
      map['title'],
    );
  }
}
