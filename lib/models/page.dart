import 'package:flutter_quill/flutter_quill.dart';
import 'package:teia/models/snippets/choice_snippet.dart';
import 'package:teia/models/snippets/image_snippet.dart';
import 'package:teia/models/snippets/snippet.dart';
import 'package:teia/models/snippets/text_snippet.dart';
import 'package:teia/utils/utils.dart';

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
  Snippet findSnippet(int index) {
    int skipped = 0;
    try {
      return snippets.firstWhere((snippet) {
        return (skipped += snippet.text.length) >= index;
      });
    } catch (e) {
      return snippets.last;
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
            "attributes": {"color": snippetColors![index]},
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
