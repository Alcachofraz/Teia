class Reply {
  final String text;
  final String photoUrl;
  final String username;

  Reply(
    this.text,
    this.photoUrl,
    this.username,
  );

  factory Reply.create(String text, String photoUrl, String username) {
    return Reply(text, photoUrl, username);
  }

  /// Map Page constructor. Instantiate a page from a
  /// Map<String, dynamic> object.
  factory Reply.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Reply('', '', '');
    return Reply(
      map['text'],
      map['photoUrl'],
      map['username'],
    );
  }

  /// Convert this chapter to a Map<String, dynamic> object.
  Map<String, dynamic> toMap() => {'text': text, 'photoUrl': photoUrl, 'username': username};

  @override
  String toString() {
    return toMap().toString();
  }
}
