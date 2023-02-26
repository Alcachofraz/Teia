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

  final List<Snippet> snippets;

  Page(this.id, this.chapterId, this.storyId, this.snippets);

  factory Page.empty(int id, int chapterId, String storyId) {
    return Page(id, chapterId, storyId, []);
  }

  String getRawText() {
    String ret = '';
    for (Snippet snippet in snippets) {
      ret += snippet.text;
    }
    return ret;
  }

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

  List<Map<String, dynamic>> snippetsToMap() => snippets.map<Map<String, dynamic>>((snippet) => snippet.toMap()).toList();

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

  factory Page.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Page(-1, -1, '', []);
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
    );
  }

  @override
  String toString() {
    return 'Page{id: $id}';
  }
}
