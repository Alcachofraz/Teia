class CommentMessage {
  final String username;
  final String message;
  final int avatar;
  final String uid;

  CommentMessage({
    required this.username,
    required this.message,
    required this.avatar,
    required this.uid,
  });

  factory CommentMessage.fromJson(Map<String, dynamic> json) {
    return CommentMessage(
      username: json['username'],
      message: json['message'],
      avatar: json['avatar'],
      uid: json['uid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'message': message,
      'avatar': avatar,
      'uid': uid,
    };
  }
}
