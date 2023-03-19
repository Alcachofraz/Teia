import 'package:collection/collection.dart';
import 'package:quiver/core.dart';

class Letter extends Comparable<Letter> {
  final List<int> id;
  final String letter;

  Letter(this.id, this.letter);

  factory Letter.fromMap(Map<String, dynamic> map) {
    return Letter(List<int>.from(map['id']), map['letter'] as String);
  }

  @override
  int compareTo(Letter other) {
    int i = 0;
    while (id[i] == other.id[i]) {
      i++;
      if (i >= id.length) return -1;
      if (i >= other.id.length) return 1;
    }
    return id[i] - other.id[i];
  }

  @override
  bool operator ==(other) => other is Letter && const ListEquality().equals(id, other.id);

  @override
  int get hashCode => hashObjects(id);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'letter': letter,
    };
  }
}
