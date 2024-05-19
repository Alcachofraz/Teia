enum Role {
  reader,
  writer,
}

class UserState {
  final Role role;
  final bool ready;
  final int avatar;

  UserState({
    required this.role,
    required this.ready,
    required this.avatar,
  });

  factory UserState.fromMap(Map<String, dynamic> map) {
    return UserState(
      role: Role.values[map['role']],
      ready: map['ready'],
      avatar: map['avatar'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role.index,
      'ready': ready,
      'avatar': avatar,
    };
  }
}
