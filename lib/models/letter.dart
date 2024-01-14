import 'package:collection/collection.dart';
import 'package:quiver/core.dart';
import 'package:teia/models/snippets/snippet.dart';

class Letter extends Comparable<Letter> {
  final LetterId id;
  final String letter;
  Snippet? snippet;

  Letter(this.id, this.letter, {this.snippet});

  factory Letter.fromMap(Map<String, dynamic> map) {
    return Letter(
      LetterId.fromMap(map['id']),
      map['letter'] as String,
      snippet: Snippet.fromMap(map['snippet']),
    );
  }

  @override
  int compareTo(Letter other) {
    return id.compareTo(other.id);
  }

  @override
  bool operator ==(other) => other is Letter && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'id': id.id,
      'letter': letter,
      'snippet': snippet?.toMap(),
    };
  }

  @override
  String toString() {
    return '{$letter, $id, $snippet}';
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
