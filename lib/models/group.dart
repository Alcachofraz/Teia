class Group {
  final String name;
  final String? storyId;
  final List<String> users;

  Group({
    required this.name,
    required this.users,
    this.storyId,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      name: map['name'],
      storyId: map['story'],
      users: (map['users'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'story': storyId,
      'users': users,
    };
  }
}
