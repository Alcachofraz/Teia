import 'package:teia/models/letter.dart';
import 'package:collection/collection.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/models/snippets/text_snippet.dart';

class EditingPage {
  final int id;
  final int chapterId;
  final String storyId;
  String? lastModifierUid;

  final SortedList<Letter> letters;

  static const int intMaxValue = 2147483647;
  static const int boundary = 10;

  EditingPage(
    this.id,
    this.chapterId,
    this.storyId,
    this.letters,
    this.lastModifierUid,
  );

  factory EditingPage.empty(int id, int chapterId, String storyId, {String? uid}) {
    return EditingPage(id, chapterId, storyId, SortedList<Letter>(), uid);
  }

  factory EditingPage.fromMap(Map<String, dynamic>? map) {
    if (map == null) return EditingPage(-1, -1, '', SortedList<Letter>(), null);
    return EditingPage(
      map['id'] as int,
      map['chapterId'] as int,
      map['storyId'] as String,
      SortedList<Letter>()..addAll(map['letters'].map<Letter>((letter) => Letter.fromMap(letter)).toList()),
      map['lastModifierUid'] as String,
    );
  }

  int get length => letters.length;

  String getRawText() {
    String ret = '';
    for (var letter in letters) {
      ret += letter.letter;
    }
    return ret;
  }

  Snippet findSnippet(int index) {
    //TODO
    return TextSnippet('');
  }

  void createSnippet(int from, int to, {String? url, int? id}) {}

  List<int> generateId(List<int>? p, List<int>? q) {
    if (p != null) {
      List<int> ret = List.from(p);
      for (int i = ret.length - 1; i < (q?.length ?? 0); i++) {
        ret.add(0);
      }
      if (ret.last + boundary > intMaxValue) {
        ret.removeLast();
        ret.last += boundary;
      } else {
        ret.last += boundary;
      }
      if (q != null && const ListEquality().equals(ret, q)) {
        return List.from(p)..add(boundary);
      }
      return ret;
    } else if (p == null && q != null) {
      List<int> ret = List.from(q);
      if (ret.last - boundary <= 0) {
        ret.last = 0;
        return ret..add(boundary);
      } else {
        ret.last -= boundary;
        return ret;
      }
    } else {
      // All null
      return [boundary]; // Create first id
    }
  }

  int? getLeftMostOffset(Letter letter) {
    // Find letter
    int ret = letters.indexOf(letter);
    if (ret >= 0) {
      return ret;
    }
    try {
      Letter aux = letters.lastWhere((l) => l.compareTo(letter) < 0);
      return letters.indexOf(aux);
    } catch (e) {
      return null;
    }
  }

  void insert(int skip, String text) {
    for (int i = 0; i < text.length; i++) {
      letters.add(
        Letter(
          generateId(
            skip + i - 1 <= 0 ? null : letters[skip + i - 1].id,
            skip + i >= letters.length ? null : letters[skip + i].id,
          ),
          text[i],
        ),
      );
    }
  }

  void delete(int skip, int length) {
    letters.removeRange(skip, skip + length);
  }

  Delta toDelta() {
    return letters.fold<Delta>(Delta(), (delta, letter) => delta..insert(letter.letter));
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'chapterId': chapterId,
        'storyId': storyId,
        'letters': letters.map<Map<String, dynamic>>((letter) => letter.toMap()),
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
}
