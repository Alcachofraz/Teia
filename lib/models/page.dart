import 'package:flutter_quill/flutter_quill.dart';
import 'package:teia/models/snippets/choice_snippet.dart';
import 'package:teia/models/snippets/image_snippet.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/models/snippets/text_snippet.dart';
import 'package:teia/utils/logs.dart';
import 'package:teia/utils/utils.dart';
import 'dart:math' as math;

class Page {
  final int id;
  final int chapterId;
  final String storyId;
  final String? lastModifierUid;

  final List<Snippet> snippets;

  Page(this.id, this.chapterId, this.storyId, this.snippets, this.lastModifierUid);

  /// Empty Page constructor. Instantiates a page with the specified
  /// attributes and one empty TextSnippet.
  ///
  /// * [id] Id of the page to instantiate.
  /// * [chapterId] Id of this page's chapter.
  /// * [storyId] Id of this page's story.
  /// * [uid] Uid of the user that is creating this page (optional).
  factory Page.empty(int id, int chapterId, String storyId, {String? uid}) {
    return Page(id, chapterId, storyId, [TextSnippet('')], uid);
  }

  /// Map Page constructor. Instantiate a page from a
  /// Map<String, dynamic> object.
  factory Page.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Page(-1, -1, '', [], null);
    return Page(
      map['id'] as int,
      map['chapterId'] as int,
      map['storyId'] as String,
      map['snippets'].map<Snippet>((snippet) {
        if (snippet['type'] == 0) {
          return TextSnippet(snippet['text']);
        } else if (snippet['type'] == 1) {
          return ChoiceSnippet(snippet['text'], snippet['choice']);
        } else if (snippet['type'] == 2) {
          return ImageSnippet(snippet['text'], snippet['url']);
        } else {
          return TextSnippet(''); // In case somethign goes wrong
        }
      }).toList(),
      map['lastModifierUid'] as String,
    );
  }

  /// Calculate length of this page. Iterates all
  /// snippets and counts the number of characters.
  int get length => snippets.fold<int>(0, (previous, snippet) => previous + snippet.text.length);

  /// Get raw text of this page. Iterates all snippets
  /// and concatenates all text.
  String getRawText() {
    String ret = '';
    for (Snippet snippet in snippets) {
      ret += snippet.text;
    }
    return ret;
  }

  /// Find the snippet that contains the character at [index].
  Snippet? findSnippet(int index) {
    int skipped = 0;
    try {
      return snippets.firstWhere((snippet) {
        return (skipped += snippet.text.length) >= index;
      });
    } catch (e) {
      return snippets.isEmpty ? null : snippets.last;
    }
  }

  /// Clear empty snippets (snippets with empty text) and join
  /// consecutive snippets
  void normalizeSnippets() {
    // Remove empty snipepts
    snippets.removeWhere((s) => s.text.isEmpty);
    // Join consecutive snippets
    List<Snippet> newSnippets = [];
    for (Snippet snippet in snippets) {
      if (newSnippets.isNotEmpty && newSnippets.last.joinable(snippet)) {
        newSnippets.last.text += snippet.text;
      } else {
        newSnippets.add(snippet);
      }
    }
    snippets.replaceRange(0, snippets.length, newSnippets);
    // Check for anomalies
    if (snippets.isEmpty) snippets.add(TextSnippet(''));
    if (!snippets.last.text.endsWith('\n')) {
      snippets.last.text += '\n';
    }
  }

  /// Create a snippet from [from] to [to].
  void createSnippet(int from, int to, {String? url, int? id}) {
    assert(url != null || id != null);
    List<Snippet> newSnippets = [];
    int aux = 0; // Current snippet first character index
    bool insideSelection = false;
    String textAccumulated = '';
    for (Snippet snippet in snippets) {
      // Length of current snippet
      String text = snippet.text;
      int snippetLength = text.length;
      // Index of first character of the new snippet, relative to the current snippet
      int? start;
      // Index of last character of the new snippet
      int end = math.min(to - aux, snippetLength);

      if (from >= aux && from <= aux + snippetLength) {
        // If skip (number of characters to skip before new snippet), is
        // inside this snippet ([aux + snippetLength] is the last character
        // of this snippet)

        start = from - aux;

        // Text before new snippet
        String textBefore = text.substring(0, start);

        // Assign text before new snippet to current snippet
        newSnippets.add(snippet.deepCopy(text: textBefore));

        // Inside selection
        insideSelection = true;
      }
      if (insideSelection) {
        // Text inside new snippet
        String textInside = text.substring(start ?? 0, end);
        // Add to accumulated text
        textAccumulated += textInside;

        // Text after snippet (if any)
        String textAfter = text.substring(end, snippetLength);

        // If new snippet ends before/exactly at current snippet
        if (to - aux <= snippetLength) {
          // Add new snippet
          if (url != null) {
            newSnippets.add(ImageSnippet(textAccumulated, url));
          } else if (id != null) {
            newSnippets.add(ChoiceSnippet(textAccumulated, id));
          }
          // If new snipept ends before current snippet
          if (to - aux < snippetLength) {
            // Add snippet with the rest of the text
            newSnippets.add(snippet.deepCopy(text: textAfter));
          }
          insideSelection = false;
        }
      } else {
        newSnippets.add(snippet);
      }
      aux += snippetLength;
    }
    snippets.replaceRange(0, snippets.length, newSnippets);
    normalizeSnippets();
  }

  /// Insert [snippetToInsert] into index [skip] of this page.
  void insertSnippet(int skip, Snippet snippetToInsert) {
    List<Snippet> newSnippets = [];
    int aux = 0; // Current snippet first character index
    //Logs.d(snippets.map((e) => e.toMap().toString()));
    for (Snippet snippet in snippets) {
      // Length of current snippet
      String text = snippet.text;
      int snippetLength = text.length;
      // Index of first character of the new snippet, relative to the current snippet
      //log('skip: $skip, aux: $aux, snippetLength: $snippetLength');
      if (skip >= aux && skip <= aux + snippetLength) {
        // If skip (number of characters to skip before start inserting), is
        // inside this snippet ([aux + snippetLength] is the last character
        // of this snippet)

        int start = skip - aux;
        // Text before the text to insert
        String textBefore = text.substring(0, start);
        // Text after the text to insert
        String textAfter = text.substring(start, snippetLength);
        Logs.d('textBefore: $textBefore, snippet: ${snippetToInsert.text}, textAfter: $textAfter');
        // Add before snippet
        newSnippets.add(snippet.deepCopy(text: textBefore));
        // Add inserting snippet
        newSnippets.add(snippetToInsert);
        // Add after snippet
        newSnippets.add(snippet.deepCopy(text: textAfter));
        break;
      } else {
        newSnippets.add(snippet);
      }
      aux += snippetLength;
    }
    snippets.replaceRange(0, snippets.length, newSnippets);
  }

  /// Insert [text] into index [skip] of this page.
  void insert(int skip, String text) {
    // If no snippets, add empty snippet
    if (snippets.isEmpty) snippets.add(TextSnippet(''));
    int aux = 0; // Current snippet first character index
    for (Snippet snippet in snippets) {
      // Length of current snippet
      int snippetLength = snippet.text.length;
      if (skip >= aux && skip <= aux + snippetLength) {
        // If skip (number of characters to skip before start inserting), is
        // inside this snippet ([aux + snippetLength] is the last character
        // of this snippet)

        int start = skip - aux;
        // Text before the text to insert
        String textBefore = snippet.text.substring(0, start);
        // Text after the text to insert
        String textAfter = snippet.text.substring(start, snippetLength);
        // Concatenate and assign all text
        snippet.text = textBefore + text + textAfter;
        break;
      }
      aux += snippetLength;
    }
  }

  /// Delete [length] characters at index [skip] of this page.
  void delete(int skip, int length) {
    int aux = 0; // Current snippet first character index
    int deleted = 0; // Deleted characters so far
    for (Snippet snippet in snippets) {
      int snippetLength = snippet.text.length; // Current snippet length
      if (deleted != 0) {
        // If already started deleting

        // Index of last character to remove in THIS SNIPPET
        int end = math.min(length - deleted, snippetLength);
        // Remove designated text
        snippet.text = snippet.text.substring(end, snippetLength);
        // Update deleted
        deleted += end;
      } else if (skip >= aux && skip <= aux + snippetLength) {
        // If skip (number of characters to skip before start deleting), is
        // inside this snippet ([aux + snippetLength] is the last character
        // of this snippet)

        // Index of first character to remove
        int start = skip - aux;
        // Text before the text to remove (to keep)
        String textBefore = snippet.text.substring(0, start);
        // Index of last character to remove in THIS SNIPPET
        int end = math.min(start + length, snippetLength);
        // Text before the text to remove (to keep)
        String textAfter = snippet.text.substring(end, snippetLength);
        // Concatenate and assign all text to keep
        snippet.text = textBefore + textAfter;
        // Update deleted
        deleted += end - start;
      }
      // If already deleted all, break out
      if (deleted == length) break;
      // Increment aux to next snippet
      aux += snippetLength;
    }
  }

  /// Convert this page to a Quill Delta, giving a different
  /// color to the special snippets' text, cycling through
  /// [snippetColors].
  ///
  /// * [snippetColors] List of color codes for special snippets.
  Delta toDelta({List<String>? snippetColors = Utils.snippetColors}) {
    Delta ret = Delta();
    int index = 0;
    for (Snippet snippet in snippets) {
      if (snippet is TextSnippet) {
        ret.push(
          Operation.fromJson({
            "insert": snippet.text,
          }),
        );
      } else {
        ret.push(Operation.fromJson(
          {
            "insert": snippet.text,
            "attributes": {
              ...{"color": snippetColors![index]},
              ...{"link": snippet.deepCopy()},
            },
          },
        ));
        if (++index >= snippetColors.length) index = 0;
      }
    }
    return ret;
  }

  /// Convert get a list of mapped snippets (instead of
  /// Snippet objects). Each snippets is converted to a
  /// Map<String, dynamic> object.
  List<Map<String, dynamic>> snippetsToMap() =>
      snippets.map<Map<String, dynamic>>((snippet) => snippet.toMap()).toList();

  /// Convert this page to a Map<String, dynamic> object.
  Map<String, dynamic> toMap() => {'id': id, 'chapterId': chapterId, 'storyId': storyId, 'snippets': snippetsToMap()};

  List<Snippet> snippetsFromMap(List<Map<String, dynamic>> snippets) => snippets.map<Snippet>((snippet) {
        if (snippet['type'] == 0) {
          return TextSnippet(snippet['text']);
        } else if (snippet['type'] == 1) {
          return ChoiceSnippet(snippet['text'], snippet['choice']);
        } else if (snippet['type'] == 2) {
          return ImageSnippet(snippet['text'], snippet['url']);
        } else {
          return TextSnippet(''); // In case somethign goes wrong
        }
      }).toList();

  @override
  String toString() {
    return toMap().toString();
  }
}
