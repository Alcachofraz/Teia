import 'package:teia/models/letter.dart';

class Change extends Comparable<Change> {
  final LetterId? id;
  final int? length;
  final String? letter;
  final String uid;
  final int timestamp;

  Change(this.id, this.uid, this.timestamp, {this.length, this.letter});

  factory Change.fromMap(Map<String, dynamic> map) {
    return Change(
      map['id'] == null ? null : LetterId.fromMap(map['id']),
      map['uid'],
      map['timestamp'],
      length: map['length'],
      letter: map['letter'],
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
      'length': length,
      'letter': letter,
      'uid': uid,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return '{${letter == null ? 'delete: $length' : 'insert: $letter'}, offset: $id}';
  }
}
