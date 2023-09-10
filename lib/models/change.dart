import 'package:flutter_quill/flutter_quill.dart';

class Change extends Comparable<Change> {
  final int offset;
  final int? length;
  final String? letter;
  final String uid;
  final int timestamp;

  Change(this.offset, this.uid, this.timestamp, {this.length, this.letter});

  factory Change.fromMap(Map<String, dynamic> map) {
    return Change(
      map['offset'],
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
      'offset': offset,
      'length': length,
      'letter': letter,
      'uid': uid,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return '{${letter == null ? 'delete: $length' : 'insert: $letter'}, offset: $offset}';
  }

  Delta toDelta() {
    Delta delta = Delta();
    delta.retain(offset);
    if (length == null) {
      return delta..insert(letter!);
    } else {
      return delta..delete(length!);
    }
  }
}
