class User {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;

  User(this.uid, this.name, this.email, this.photoUrl);

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      map['uid'],
      map['name'],
      map['email'],
      map['photoUrl'],
    );
  }
}
