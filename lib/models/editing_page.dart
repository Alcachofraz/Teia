import 'package:teia/models/letter.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:teia/models/snippets/choice_snippet.dart';
import 'package:teia/models/snippets/image_snippet.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/models/snippets/text_snippet.dart';
import 'package:teia/utils/utils.dart';

class EditingPage {
  final int id;
  final int chapterId;
  final String storyId;
  String? lastModifierUid;

  final SortedList<Letter> letters;
  final List<Snippet> snippets;

  static const int intMaxValue = 2147483647;
  static const int boundary = 10;

  EditingPage(
    this.id,
    this.chapterId,
    this.storyId,
    this.letters,
    this.snippets,
    this.lastModifierUid,
  );

  factory EditingPage.empty(int id, int chapterId, String storyId, {String? uid}) {
    return EditingPage(id, chapterId, storyId, SortedList<Letter>(), [], uid);
  }

  factory EditingPage.fromMap(Map<String, dynamic>? map) {
    if (map == null) return EditingPage(-1, -1, '', SortedList<Letter>(), [], null);
    return EditingPage(
      map['id'] as int,
      map['chapterId'] as int,
      map['storyId'] as String,
      SortedList<Letter>()..addAll(map['letters'].map<Letter>((letter) => Letter.fromMap(letter)).toList()),
      List.from(map['snippets']).map<Snippet>((snippetJson) {
        LetterId from = LetterId.fromMap(snippetJson['from']);
        LetterId to = LetterId.fromMap(snippetJson['to']);
        switch (snippetJson['type']) {
          case 1:
            return ChoiceSnippet(from, to, snippetJson['id']);
          case 2:
            return ImageSnippet(from, to, snippetJson['url']);
          default:
            return TextSnippet(from, to);
        }
      }).toList(),
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

  Snippet? findSnippetById(LetterId id) {
    try {
      return snippets.firstWhere((snippet) => id.compareTo(snippet.from) >= 0 && id.compareTo(snippet.to) <= 0);
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
        s1.deepCopy(to: letters.lastWhere((letter) => letter.id.compareTo(s2.from) < 0).id),
        s1.deepCopy(from: letters.firstWhere((letter) => letter.id.compareTo(s2.to) > 0).id),
      ];
    }

    /// 3)
    else if (s2.from.compareTo(s1.from) > 0 && s2.to.compareTo(s1.to) >= 0) {
      return [s1.deepCopy(to: letters.lastWhere((letter) => letter.id.compareTo(s2.from) < 0).id)];
    }

    /// 4)
    else if (s2.from.compareTo(s1.from) <= 0 && s2.to.compareTo(s1.to) < 0) {
      return [s1.deepCopy(from: letters.firstWhere((letter) => letter.id.compareTo(s2.to) > 0).id)];
    } else {
      return [];
    }
  }

  void createSnippet(int from, int to, {String? url, int? id}) {
    Snippet toAdd;
    if (id != null) {
      toAdd = ChoiceSnippet(letters[from].id, letters[to].id, id);
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

  void insert(int skip, String text) {
    for (int i = 0; i < text.length; i++) {
      letters.add(
        Letter(
          generateId(
            skip + i - 1 < 0 ? null : letters[skip + i - 1].id,
            skip + i >= letters.length ? null : letters[skip + i].id,
          ),
          text[i],
        ),
      );
    }
  }

  void delete(int skip, int length) {
    letters.removeRange(skip, skip + length);
    rectifySnippetsAfterDelete();
  }

  void rectifySnippetsAfterDelete() {
    List<Snippet> newSnippets = [];
    for (var snippet in snippets) {
      try {
        letters.firstWhere((letter) => letter.id.compareTo(snippet.from) == 0);
      } catch (e) {
        try {
          snippet.from = letters.firstWhere((letter) => letter.id.compareTo(snippet.from) > 0).id;
        } catch (e) {
          continue;
        }
        if (snippet.from.compareTo(snippet.to) > 0) {
          continue;
        }
      }
      try {
        letters.firstWhere((letter) => letter.id.compareTo(snippet.to) == 0);
      } catch (e) {
        try {
          snippet.to = letters.lastWhere((letter) => letter.id.compareTo(snippet.to) < 0).id;
        } catch (e) {
          continue;
        }
        if (snippet.to.compareTo(snippet.from) < 0) {
          continue;
        }
      }
      newSnippets.add(snippet);
    }
    snippets.replaceRange(0, snippets.length, newSnippets);
  }

  Delta toDelta() {
    int currentColor = 0;
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
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'chapterId': chapterId,
        'storyId': storyId,
        'letters': letters.map<Map<String, dynamic>>((letter) => letter.toMap()),
        'snippets': snippets.map<Map<String, dynamic>>((snippet) => snippet.toMap()),
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
