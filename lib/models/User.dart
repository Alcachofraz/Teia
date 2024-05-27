class User {
  final String uid;
  final String name;
  final String email;

  User(this.uid, this.name, this.email);

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      map['uid'],
      map['name'],
      map['email'],
    );
  }
}
