import 'package:teia/models/story.dart';

class Group {
  final String name;
  final Story? story;
  final List<String> users;
  final Map<String, int> roles;

  Group({
    required this.name,
    required this.users,
    required this.roles,
    this.story,
  });

  factory Group.fromMap(Map<String, dynamic> map, Story? story) {
    return Group(
      name: map['name'],
      story: story,
      roles: Map<String, int>.from(map['roles']),
      users: (map['users'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'story': story,
      'roles': roles,
      'users': users,
    };
  }
}
