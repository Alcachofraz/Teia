import 'package:teia/models/letter.dart';
import 'package:teia/models/note/reply.dart';

class Note {
  final List<Reply> replies;
  final bool resolved;
  LetterId from;
  LetterId to;

  Note(
    this.replies,
    this.resolved,
    this.from,
    this.to,
  );

  factory Note.create(List<Reply> replies, bool resolved, LetterId from, LetterId to) {
    return Note(replies, resolved, from, to);
  }

  /// Map Page constructor. Instantiate a page from a
  /// Map<String, dynamic> object.
  factory Note.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Note([], false, LetterId.fromMap([]), LetterId.fromMap([]));
    return Note(
      List.from(map['replies']).map<Reply>((replyJson) => Reply.fromMap(replyJson)).toList(),
      map['resolved'] as bool,
      LetterId.fromMap(map['from']),
      LetterId.fromMap(map['to']),
    );
  }

  /// Convert this chapter to a Map<String, dynamic> object.
  Map<String, dynamic> toMap() => {'replies': replies.map((reply) => reply.toMap()), 'resolved': resolved, 'from': from.id, 'to': to.id};

  @override
  String toString() {
    return toMap().toString();
  }
}
