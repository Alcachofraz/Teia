import 'dart:math';

import 'package:flutter_quill/quill_delta.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:teia/models/change.dart';
import 'package:teia/models/letter.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/services/authentication_service.dart';

class tPage {
  final int id;
  final int chapterId;
  final String storyId;
  String? lastModifierUid;
  final Map<String, int> cursors;
  final List<Snippet> snippets;

  SortedList<Letter> letters;

  static const int kIntMaxValue = 50; // 0x20000000000000;
  static const int boundary = 10;

  tPage(
    this.id,
    this.chapterId,
    this.storyId,
    this.letters,
    this.lastModifierUid,
    this.cursors,
    this.snippets,
  );

  factory tPage.empty(int id, int chapterId, String storyId, {String? uid}) {
    return tPage(id, chapterId, storyId, SortedList<Letter>(), uid, {}, []);
  }

  factory tPage.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return tPage(-1, -1, '', SortedList<Letter>(), null, {}, []);
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
      (map['snippets'] as List<dynamic>? ?? [])
          .map((e) => Snippet.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'chapterId': chapterId,
        'storyId': storyId,
        'lastModifierUid': lastModifierUid,
        'snippets': snippetList().map((e) => e.toMap()).toList(),
      };

  List<Snippet> snippetList() {
    List<Snippet> ret = [];
    Snippet? currentSnippet;
    String text = '';
    for (var letter in letters) {
      if (letter.snippet == currentSnippet) {
        // If the snippet is the same
        text += letter.letter;
      } else {
        // If snippet changed
        // Save current snippet with current text
        ret.add(
          Snippet(
            text,
            currentSnippet?.type ?? SnippetType.text,
            currentSnippet?.attributes ?? {},
          ),
        );
        // Update current snippet and text
        currentSnippet = letter.snippet;
        text = letter.letter;
      }
    }
    ret.add(
      Snippet(
        text,
        currentSnippet?.type ?? SnippetType.text,
        currentSnippet?.attributes ?? {},
      ),
    );
    return ret;
  }

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
    //print(letters[index].snippet);
    return letters[index].snippet;
  }

  LetterIdAndLength? findLetterIdAndLengthBySnippet(Snippet snippet) {
    int count = 0;
    int index = 0;
    bool found = false;
    LetterId first = LetterId([0]);
    for (var letter in letters) {
      if (letter.snippet == snippet) {
        if (!found) {
          first = letter.id;
        }
        found = true;
        count++;
      } else {
        if (found) {
          return LetterIdAndLength(
            first,
            count,
            index,
          );
        }
      }
      if (!found) index++;
    }
    return null;
  }

  LetterId generateId(LetterId? p, LetterId? q) {
    if (p != null) {
      LetterId ret = p.deepCopy();
      for (int i = ret.depths - 1; i < (q?.depths ?? 0); i++) {
        ret.add(0);
      }
      if (ret.last >= kIntMaxValue - boundary) {
        if (q != null) ret.removeLast();
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

  int indexLetter(LetterId? id, {insert = true}) {
    if (id == null) return 0;
    int index = letters.indexWhere((l) => l.id == id);
    if (index < 0) {
      index = letters.indexWhere((l) => l.id.compareTo(id) > 0);
    }
    if (index < 0) {
      index = letters.length;
    }
    return index + (insert ? 1 : 0);
  }

  /// Add change to local [letters] and return delta of that change.
  Delta compose(Change change) {
    int index;
    try {
      switch (change.type) {
        case ChangeType.insert:
          index = insert(change.id, change.letter!);
          return Delta()
            ..retain(index)
            ..insert(change.letter!);
        case ChangeType.delete:
          index = delete(change.id, change.length!);
          return Delta()
            ..retain(index)
            ..delete(change.length ?? 0);
        case ChangeType.format:
          index = format(change.id!, change.length!, change.snippet);
          return Delta()
            ..retain(index)
            ..retain(
              change.length ?? 0,
              change.snippet != null ? null : {'color': '#0000FF'},
            );
      }
    } catch (e) {
      print(e);
      rethrow;
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
    //int index = letters.indexWhere((l) => l.id == id);
    int index = indexLetter(id, insert: false);
    if (index < 0) return -1;
    if (index + length <= letters.length) {
      letters.removeRange(index, index + length);
    }
    return index;
  }

  /// Formats [length] letters after [id]. Returns index of [id].
  int format(LetterId? id, int length, Snippet? snippet) {
    //int index = letters.indexWhere((l) => l.id == id);
    int index = indexLetter(id, insert: false);
    for (int i = index; i < index + length; i++) {
      letters[i].snippet = snippet;
    }
    return index;
  }

  /// Check if is leaf.
  /// If there's no snippets with type choice, it's a leaf.
  bool isLeaf({reading = false}) {
    if (reading) {
      return !snippets.any((s) => s.type == SnippetType.choice);
    } else {
      return !letters.any((l) => l.snippet?.type == SnippetType.choice);
    }
  }

  /// Convert this page to a list of Changes.
  /// This is used to send the full list of simplified changes to the server.
  List<Change> toChanges({requeue = true}) {
    List<Change> ret = [
      Change(
        null,
        ChangeType.insert,
        AuthenticationService.value.uid!,
        DateTime.now().millisecondsSinceEpoch,
        letter: getRawText(),
      ),
    ];
    WorkingSnippet? workingSnippet;
    LetterId letterId = LetterId([10]);
    for (int i = 1; i <= letters.length; i++) {
      Letter letter = letters[i - 1];
      if (letter.snippet == null) {
        if (workingSnippet != null) {
          ret.add(Change(
            workingSnippet.startId,
            ChangeType.format,
            AuthenticationService.value.uid!,
            DateTime.now().millisecondsSinceEpoch,
            length: workingSnippet.length,
            snippet: workingSnippet.snippet,
            requeue: requeue,
          ));
          workingSnippet = null;
        }
      } else {
        if (workingSnippet != null) {
          if (letter.snippet == workingSnippet.snippet) {
            workingSnippet.length++;
          } else {
            ret.add(Change(
              workingSnippet.startId,
              ChangeType.format,
              AuthenticationService.value.uid!,
              DateTime.now().millisecondsSinceEpoch,
              length: workingSnippet.length,
              snippet: workingSnippet.snippet,
              requeue: requeue,
            ));
            workingSnippet = WorkingSnippet(letter.snippet!, letterId, 1);
          }
        } else {
          workingSnippet = WorkingSnippet(letter.snippet!, letterId, 1);
        }
      }
      letterId = generateId(letterId, null);
    }
    if (workingSnippet != null) {
      ret.add(
        Change(
          workingSnippet.startId,
          ChangeType.format,
          AuthenticationService.value.uid!,
          DateTime.now().millisecondsSinceEpoch,
          length: workingSnippet.length,
          snippet: workingSnippet.snippet,
          requeue: requeue,
        ),
      );
    }
    return ret;
  }
}

class WorkingSnippet {
  final Snippet snippet;
  final LetterId startId;
  int length;

  WorkingSnippet(this.snippet, this.startId, this.length);
}

class LetterIdAndLength {
  final LetterId id;
  final int length;
  final int index;

  LetterIdAndLength(this.id, this.length, this.index);
}
