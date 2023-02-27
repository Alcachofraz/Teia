import 'package:teia/models/chapter_graph.dart';
import 'package:teia/models/page.dart';
import 'package:teia/models/snippets/choice_snippet.dart';
import 'package:teia/models/snippets/image_snippet.dart';
import 'package:teia/models/snippets/text_snippet.dart';

class Chapter {
  int id;
  String storyId;
  String title;
  List<Page> pages;
  ChapterGraph graph;

  Chapter(
    this.id,
    this.storyId,
    this.title,
    this.pages,
    this.graph,
  );

  factory Chapter.create(int id, String storyId, String title, String uid) {
    return Chapter(
      id,
      storyId,
      title,
      [
        Page(
          1,
          id,
          storyId,
          [
            TextSnippet('Olá. '),
            ChoiceSnippet('Isto é uma escolha.', 2),
            TextSnippet(' '),
            ImageSnippet('Isto é uma imagem.', '')
          ],
          uid,
        ),
      ],
      ChapterGraph({1: []}),
    );
  }

  /// Create a new page.
  /// * [id] parent id.
  /// Returns the created page id.
  int addPage(int id, String uid) {
    int newId = pages.length + 1;
    pages.add(Page(
      newId,
      id,
      storyId,
      [TextSnippet('')],
      uid,
    ));
    graph.addConnection(id, newId);
    return newId;
  }

  /// Check if page is last in chapter.
  /// * [id] page id.
  bool isFinalPage(int id) {
    return graph.isLeaf(id);
  }
}
