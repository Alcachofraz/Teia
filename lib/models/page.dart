import 'package:flutter_quill/quill_delta.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:teia/models/change.dart';
import 'package:teia/models/letter.dart';
import 'package:teia/models/snippets/snippet.dart';

class tPage {
  final int id;
  final int chapterId;
  final String storyId;
  String? lastModifierUid;
  final Map<String, int> cursors;

  SortedList<Letter> letters;

  static const int intMaxValue = 2147483647;
  static const int boundary = 10;

  tPage(
    this.id,
    this.chapterId,
    this.storyId,
    this.letters,
    this.lastModifierUid,
    this.cursors,
  );

  factory tPage.empty(int id, int chapterId, String storyId, {String? uid}) {
    return tPage(id, chapterId, storyId, SortedList<Letter>(), uid, {});
  }

  factory tPage.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return tPage(-1, -1, '', SortedList<Letter>(), null, {});
    }
    return tPage(
      map['id'] as int,
      map['chapterId'] as int,
      map['storyId'] as String,
      SortedList<Letter>(),
      map['lastModifierUid'] as String?,
      Map<String, int>.from(
        map['cursors'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'chapterId': chapterId,
        'storyId': storyId,
        'lastModifierUid': lastModifierUid,
      };

  @override
  String toString() {
    return {
      'id': id,
      'chapterId': chapterId,
      'storyId': storyId,
      'letters': letters.length,
      'lastModifierUid': lastModifierUid,
    }.toString();
  }

  /// Update with [newPage] info. Preserve [letters] only.
  void updateWith(tPage newPage) {
    lastModifierUid = newPage.lastModifierUid;
  }

  int get length => letters.length;

  String getRawText() {
    String ret = '';
    for (var letter in letters) {
      ret += letter.letter;
    }
    return ret;
  }

  Snippet? findSnippetById(LetterId id) {
    return findSnippetByIndex(letters.indexWhere((l) => l.id == id));
  }

  Snippet? findSnippetByIndex(int index) {
    if (index >= length) return null;
    print(letters[index].snippet);
    return letters[index].snippet;
  }

  LetterId generateId(LetterId? p, LetterId? q) {
    if (p != null) {
      LetterId ret = p.deepCopy();
      for (int i = ret.depths - 1; i < (q?.depths ?? 0); i++) {
        ret.add(0);
      }
      if (ret.last + boundary > intMaxValue) {
        ret.removeLast();
        ret.last += boundary;
      } else {
        ret.last += boundary;
      }
      if (q != null && ret == q) {
        return p.deepCopy()..add(boundary);
      }
      return ret;
    } else if (p == null && q != null) {
      LetterId ret = q.deepCopy();
      if (ret.last - boundary <= 0) {
        ret.last = 0;
        return ret..add(boundary);
      } else {
        ret.last -= boundary;
        return ret;
      }
    } else {
      // All null
      return LetterId([boundary]); // Create first id
    }
  }

  int indexLetter(LetterId? id) {
    if (id == null) return 0;
    int index = letters.indexWhere((l) => l.id == id);
    if (index < 0) {
      index = letters.indexWhere((l) => l.id.compareTo(id) > 0);
    }
    if (index < 0) {
      index = letters.length;
    }
    return index + 1;
  }

  /// Add change to local [letters] and return delta of that change.
  Delta compose(Change change) {
    switch (change.type) {
      case ChangeType.insert:
        int index = insert(change.id, change.letter!);
        return Delta()
          ..retain(index)
          ..insert(change.letter!);
      case ChangeType.delete:
        int index = delete(change.id, change.length!);
        return Delta()
          ..retain(index)
          ..delete(change.length!);
      case ChangeType.format:
        int index = format(change.id!, change.length!, change.snippet);
        return Delta()
          ..retain(index)
          ..retain(
            change.length!,
            change.snippet != null ? null : {'color': '#0000FF'},
          );
    }
  }

  /// Insert [text] after [id]. Returns index of [id].
  int insert(
    LetterId? id,
    String text,
  ) {
    int index = indexLetter(id);
    LetterId? endId;
    try {
      // If id is null (insert at the beginning)
      if (id == null) {
        try {
          // End should be the first letter
          endId = letters.first.id;
        } catch (e) {
          // If there's so first letter, end should be null
          endId = null;
        }
      } else {
        // If start is not null (endId should be the first letter with id greater than id)
        endId = letters.firstWhere((l) => l.id.compareTo(id) > 0).id;
      }
    } catch (e) {
      // If there's no letter with id greater than startId, end should be null
      endId = null;
    }
    LetterId? lastId = id;
    for (int i = 0; i < text.length; i++) {
      LetterId newId = generateId(lastId, endId);
      letters.add(
        Letter(
          newId,
          text[i],
        ),
      );
      lastId = newId;
    }
    return index;
  }

  /// Delete [length] letters after [id]. Returns index of [id].
  int delete(LetterId? id, int length) {
    int index = letters.indexWhere((l) => l.id == id);
    if (index < 0) return -1;
    letters.removeRange(index, index + length);
    return index;
  }

  /// Formats [length] letters after [id]. Returns index of [id].
  int format(LetterId? id, int length, Snippet? snippet) {
    int index = letters.indexWhere((l) => l.id == id);
    for (int i = index; i < index + length; i++) {
      letters[i].snippet = snippet;
    }
    return index;
  }
}
