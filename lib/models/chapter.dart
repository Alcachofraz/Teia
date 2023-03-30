import 'package:teia/models/chapter_graph.dart';
import 'package:teia/utils/logs.dart';

class Chapter {
  int id;
  String storyId;
  String title;
  ChapterGraph graph;

  Chapter(
    this.id,
    this.storyId,
    this.title,
    this.graph,
  );

  factory Chapter.create(int id, String storyId, String title, String uid) {
    return Chapter(
      id,
      storyId,
      title,
      ChapterGraph({1: []}),
    );
  }

  /// Map Page constructor. Instantiate a page from a
  /// Map<String, dynamic> object.
  factory Chapter.fromMap(Map<String, dynamic>? map) {
    if (map == null) return Chapter(-1, '', '', ChapterGraph.empty());
    return Chapter(
      map['id'] as int,
      map['storyId'] as String,
      map['title'] as String,
      ChapterGraph.fromMap(Map<String, dynamic>.from(map['graph']).map((key, value) => MapEntry(int.parse(key), List<int>.from(value)))),
    );
  }

  /// Create a new page.
  /// * [id] parent id.
  /// Returns the updated graph.
  ChapterGraph addPage(int id, {String? uid}) {
    Logs.d(id);
    int newId = graph.numberOfPages() + 1;
    Logs.d(newId);
    Logs.d(graph);
    graph.addConnection(id, newId);
    Logs.d(graph);
    return graph;
  }

  /// Connect page [from] to [to].
  bool connectPages(int from, int to) {
    return graph.addConnection(from, to);
  }

  /// Check if page is last in chapter.
  /// * [id] page id.
  bool isFinalPage(int id) {
    return graph.isLeaf(id);
  }

  /// Convert this chapter to a Map<String, dynamic> object.
  Map<String, dynamic> toMap() => {'id': id, 'storyId': storyId, 'title': title, 'graph': graph.nodes};
}
