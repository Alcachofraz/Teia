import 'package:flutter_quill/flutter_quill.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:teia/models/change.dart';
import 'package:teia/models/letter.dart';
import 'package:teia/models/snippets/choice_snippet.dart';
import 'package:teia/models/snippets/image_snippet.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/models/snippets/text_snippet.dart';

class tPage {
  final int id;
  final int chapterId;
  final String storyId;
  String? lastModifierUid;

  final SortedList<Letter> letters;
  final List<Snippet> snippets;

  static const int intMaxValue = 2147483647;
  static const int boundary = 10;

  tPage(
    this.id,
    this.chapterId,
    this.storyId,
    this.letters,
    this.snippets,
    this.lastModifierUid,
  );

  factory tPage.empty(int id, int chapterId, String storyId, {String? uid}) {
    return tPage(id, chapterId, storyId, SortedList<Letter>(), [], uid);
  }

  factory tPage.fromMap(Map<String, dynamic>? map) {
    if (map == null) return tPage(-1, -1, '', SortedList<Letter>(), [], null);
    return tPage(
      map['id'] as int,
      map['chapterId'] as int,
      map['storyId'] as String,
      SortedList<Letter>()
        ..addAll(map['letters']
            .map<Letter>((letter) => Letter.fromMap(letter))
            .toList()),
      List.from(map['snippets']).map<Snippet>((snippetJson) {
        LetterId from = LetterId.fromMap(snippetJson['from']);
        LetterId to = LetterId.fromMap(snippetJson['to']);
        switch (snippetJson['type']) {
          case 1:
            return ChoiceSnippet(from, to, snippetJson['choice']);
          case 2:
            return ImageSnippet(from, to, snippetJson['url']);
          default:
            return TextSnippet(from, to);
        }
      }).toList(),
      map['lastModifierUid'] as String?,
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

  Snippet? findSnippetById(LetterId id) {
    try {
      return snippets.firstWhere((snippet) =>
          id.compareTo(snippet.from) >= 0 && id.compareTo(snippet.to) <= 0);
    } catch (e) {
      return null;
    }
  }

  Snippet? findSnippetByIndex(int index) {
    if (index >= length) return null;
    return findSnippetById(letters[index].id);
  }

  List<Snippet> subtractSnippet(Snippet s1, Snippet s2) {
    /// 4 possible cases:
    /// 1) s2 is outside s1;
    /// 2) s2 is inside s1 (does not include the cases where limits coincide);
    /// 3) s2 starts inside s1 (includes the following)
    ///   - the case where the ending points coincide
    ///   - the case where s2 starts at the ending point of s1
    /// 4) s2 ends inside s1 (includes the following)
    ///   - the case where the starting points coincide
    ///   - the case where s2 ends at the starting point of s1

    /// 1)
    if (s2.from.compareTo(s1.to) > 0 || s2.to.compareTo(s1.from) < 0) {
      return [s1.deepCopy()];
    }

    /// 2)
    else if (s2.from.compareTo(s1.from) > 0 && s2.to.compareTo(s1.to) < 0) {
      return [
        s1.deepCopy(
            to: letters
                .lastWhere((letter) => letter.id.compareTo(s2.from) < 0)
                .id),
        s1.deepCopy(
            from: letters
                .firstWhere((letter) => letter.id.compareTo(s2.to) > 0)
                .id),
      ];
    }

    /// 3)
    else if (s2.from.compareTo(s1.from) > 0 && s2.to.compareTo(s1.to) >= 0) {
      return [
        s1.deepCopy(
            to: letters
                .lastWhere((letter) => letter.id.compareTo(s2.from) < 0)
                .id)
      ];
    }

    /// 4)
    else if (s2.from.compareTo(s1.from) <= 0 && s2.to.compareTo(s1.to) < 0) {
      return [
        s1.deepCopy(
            from: letters
                .firstWhere((letter) => letter.id.compareTo(s2.to) > 0)
                .id)
      ];
    } else {
      return [];
    }
  }

  void createSnippet(int from, int to, {String? url, int? choice}) {
    Snippet toAdd;
    if (choice != null) {
      toAdd = ChoiceSnippet(letters[from].id, letters[to].id, choice);
    } else if (url != null) {
      toAdd = ImageSnippet(letters[from].id, letters[to].id, url);
    } else {
      toAdd = TextSnippet(letters[from].id, letters[to].id);
    }
    List<Snippet> newSnippets = [];
    for (var snippet in snippets) {
      newSnippets.addAll(subtractSnippet(snippet, toAdd));
    }
    newSnippets.add(toAdd);
    snippets.replaceRange(0, snippets.length, newSnippets);
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

  Delta compose(Change change) {
    if (change.length != null) {
      int index = delete(change.id, length);
      return Delta()
        ..retain(index)
        ..delete(change.length!);
    } else {
      int index = insert(change.id, change.letter!);
      return Delta()
        ..retain(index)
        ..insert(change.letter!);
    }
  }

  int insert(LetterId? id, String text) {
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

  int delete(LetterId? id, int length) {
    int index = letters.indexWhere((l) => l.id == id);
    print(index);
    if (index < 0) return -1;
    letters.removeRange(index, index + length);
    return index;
  }

  Delta toDelta() {
    /*int currentColor = 0;
    bool insideSnippet = false;
    Snippet? current;
    Snippet? previous;
    return letters.fold<Delta>(
      Delta(),
      (delta, letter) {
        current = findSnippetById(letter.id);
        if (current != null) {
          if (current != previous) {
            if (++currentColor >= Utils.snippetColors.length) currentColor = 0;
          }
          insideSnippet = true;
        } else {
          if (insideSnippet) {
            insideSnippet = false;
          }
        }
        previous = current;
        return delta
          ..insert(
            letter.letter,
            insideSnippet ? {'color': Utils.snippetColors[currentColor]} : null,
          );
      },
    );*/
    return letters.fold<Delta>(
      Delta(),
      (delta, letter) {
        return delta
          ..insert(
            letter.letter,
          );
      },
    )..insert('\n');
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'chapterId': chapterId,
        'storyId': storyId,
        'letters':
            letters.map<Map<String, dynamic>>((letter) => letter.toMap()),
        'snippets':
            snippets.map<Map<String, dynamic>>((snippet) => snippet.toMap()),
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
