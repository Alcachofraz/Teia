enum Role {
  reader,
  writer;

  @override
  String toString() {
    return this == Role.reader ? 'Reader' : 'Writer';
  }

  String get image {
    return this == Role.reader
        ? "assets/images/roles/reader.png"
        : "assets/images/roles/writer.png";
  }
}

class UserState {
  final Role role;
  final bool ready;
  final int avatar;
  final String name;
  final String uid;
  final bool admin;

  UserState({
    required this.role,
    required this.ready,
    required this.avatar,
    required this.name,
    required this.uid,
    required this.admin,
  });

  factory UserState.fromMap(Map<String, dynamic> map, String uid) {
    return UserState(
      role: Role.values[map['role']],
      ready: map['ready'],
      avatar: map['avatar'],
      name: map['name'],
      uid: uid,
      admin: map['admin'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role.index,
      'ready': ready,
      'avatar': avatar,
      'name': name,
      'admin': admin,
    };
  }

  UserState copyWith({
    Role? role,
    bool? ready,
    int? avatar,
    String? name,
    String? uid,
    bool? admin,
  }) {
    return UserState(
      role: role ?? this.role,
      ready: ready ?? this.ready,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      uid: uid ?? this.uid,
      admin: admin ?? this.admin,
    );
  }
}
