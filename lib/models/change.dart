import 'package:flutter_quill/flutter_quill.dart';

class Change extends Comparable<Change> {
  final LetterId id;
  final int? length;
  final String? letter;
  final String uid;
  final int timestamp;

  Change(this.id, this.length, this.letter, this.uid, this.timestamp);

  factory Change.fromMap(Map<String, dynamic> map) {
    return Change(LetterId.fromMap(LetterId.fromMap(map['id'])), map['length'],
        map['letter'], map['uid'], map['timestamp']);
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
      'id': id.id,
      'length': length,
      'letter': letter,
      'uid': uid,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return '{$letter, $id}';
  }

  Delta toDelta() {
    if (length == null) {
      return Delta()..insert(letter!);
    } else {
      return Delta()..delete(length!);
    }
  }
}

class LetterId extends Comparable<LetterId> {
  final List<int> id;
  LetterId(this.id);

  factory LetterId.fromMap(dynamic array) {
    return LetterId(List<int>.from(array));
  }

  @override
  int compareTo(LetterId other) {
    int i = 0;
    while (id[i] == other.id[i]) {
      i++;
      if (i >= id.length && i < other.id.length) return -1;
      if (i >= other.id.length && i < id.length) return 1;
      if (i >= id.length && i >= other.id.length) return 0;
    }
    return id[i] - other.id[i];
  }

  int get depths => id.length;
  void removeLast() => id.removeLast();
  int get last => id.last;
  set last(int value) => id.last = value;
  void add(int value) => id.add(value);

  LetterId deepCopy() {
    return LetterId(List.from(id));
  }

  @override
  bool operator ==(other) =>
      other is LetterId && const ListEquality().equals(id, other.id);

  @override
  int get hashCode => hashObjects(id);

  @override
  String toString() {
    return id.toString();
  }
}
