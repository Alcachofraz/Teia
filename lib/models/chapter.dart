import 'package:teia/models/chapter_graph.dart';
import 'package:teia/models/page.dart';
import 'package:teia/models/snippets/raw_snippet.dart';

class Chapter {
  int id;
  String title;
  List<Page> pages;
  ChapterGraph graph;

  Chapter(
    this.id,
    this.title,
    this.pages,
    this.graph,
  );

  factory Chapter.create(int id, String title) {
    return Chapter(
      id,
      title,
      [
        Page(1, [RawSnippet('')]),
      ],
      ChapterGraph({1: []}),
    );
  }

  /// Create a new page.
  /// * [id] parent id.
  /// Returns the created page id.
  int addPage(int id) {
    int newId = pages.length + 1;
    pages.add(Page(newId, [RawSnippet('')]));
    graph.addConnection(id, newId);
    return newId;
  }

  /// Check if page is last in chapter.
  /// * [id] page id.
  bool isFinalPage(int id) {
    return graph.isLeaf(id);
  }
}
