import 'package:teia/models/letter.dart';
import 'package:teia/models/snippets/snippet.dart';

enum ChangeType {
  insert,
  delete,
  format,
}

class Change extends Comparable<Change> {
  final LetterId? id;
  final ChangeType type;
  final int? length;
  final String? letter;
  final String uid;
  final int timestamp;
  final Snippet? snippet;
  final String? commentId;
  final bool requeue;

  Change(
    this.id,
    this.type,
    this.uid,
    this.timestamp, {
    this.length,
    this.letter,
    this.snippet,
    this.commentId,
    this.requeue = false,
  });

  factory Change.fromMap(Map<String, dynamic> map) {
    return Change(
      map['id'] == null ? null : LetterId.fromMap(map['id']),
      ChangeType.values[map['type']],
      map['uid'],
      map['timestamp'],
      length: map['length'],
      letter: map['letter'],
      snippet: map['snippet'] == null
          ? null
          : Snippet.fromMap(
              Map<String, dynamic>.from(
                map['snippet'] as dynamic,
              ),
            ),
      commentId: map['commentId'],
      requeue: map['requeue'],
    );
  }

  @override
  int compareTo(Change other) {
    return timestamp.compareTo(other.timestamp);
  }

  @override
  bool operator ==(other) => other is Change && timestamp == other.timestamp;

  @override
  int get hashCode => timestamp.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id?.id,
      'type': type.index,
      'length': length,
      'letter': letter,
      'uid': uid,
      'timestamp': timestamp,
      'snippet': snippet?.toMap(),
      'commentId': commentId,
      'requeue': requeue,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
