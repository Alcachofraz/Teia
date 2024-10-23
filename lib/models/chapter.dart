import 'package:teia/models/chapter_graph.dart';

class Chapter {
  int id;
  String storyId;
  String title;

  /// Indicates which pages are connected schematically.
  ChapterTree tree;

  /// Indicates which pages are connected logically (by links).
  ChapterTree links;

  Chapter(
    this.id,
    this.storyId,
    this.title,
    this.tree,
    this.links,
  );

  factory Chapter.create(int id, String storyId, String title) {
    return Chapter(
      id,
      storyId,
      title,
      ChapterTree({1: {}}),
      ChapterTree({1: {}}),
    );
  }

  factory Chapter.empty() {
    return Chapter(
      -1,
      'Story ID',
      'Title',
      ChapterTree({1: {}}),
      ChapterTree({1: {}}),
    );
  }

  /// Map Page constructor. Instantiate a page from a
  /// Map<String, dynamic> object.
  factory Chapter.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return Chapter(
        -1,
        '',
        '',
        ChapterTree.empty(),
        ChapterTree.empty(),
      );
    }
    return Chapter(
      map['id'] as int,
      map['storyId'] as String,
      map['title'] as String,
      ChapterTree.fromMap(Map<String, dynamic>.from(map['graph'])
          .map((key, value) => MapEntry(int.parse(key), Set<int>.from(value)))),
      ChapterTree.fromMap(Map<String, dynamic>.from(map['links'])
          .map((key, value) => MapEntry(int.parse(key), Set<int>.from(value)))),
    );
  }

  /// Create a new page.
  /// * [id] parent id.
  /// Returns the id of the child.
  int addPage(int id, {String? uid}) {
    int newId = tree.findNextAvailableId();
    tree.addConnection(id, newId);
    return newId;
  }

  /// Add link to a page. If [childId] isn't, a new page is created.
  /// * [id] parent id.
  /// Returns the id of the child.
  int addLink(int id, {int? childId, String? uid}) {
    childId ??= addPage(id, uid: uid);
    links.addConnection(id, childId);
    return childId;
  }

  /// Remove link from a page.
  /// * [id] parent id.
  /// * [childId] child id.
  /// Returns true if the link was removed.
  bool removeLink(int id, int childId) {
    return links.removeConnection(id, childId);
  }

  /// Connect page [from] to [to].
  bool connectPages(int from, int to) {
    return tree.addConnection(from, to);
  }

  /// Check if page is last in chapter.
  /// * [id] page id.
  bool isFinalPage(int id) {
    return tree.isLeaf(id);
  }

  /// Check if page can be deleted.
  /// If page has no parent in graph, it can't be deleted because it's the entry point.
  /// If page has children in graph, it can't be deleted.
  /// If page has parent in links, it can't be deleted.
  bool canPageBeDeleted(int pageId) {
    bool ret1 = !tree.isRoot(pageId);
    bool ret2 = tree.isLeaf(pageId);
    bool ret3 = !links.isRoot(pageId);
    return ret1 && ret2 && ret3;
  }

  /// Delete page from chapter. Undo links.
  void deletePage(int pageId) {
    tree.removeNode(pageId);
    links.removeNode(pageId);
  }

  /// Convert this chapter to a Map<String, dynamic> object.
  Map<String, dynamic> toMap() {
    try {
      return <String, dynamic>{
        'id': id,
        'storyId': storyId,
        'title': title,
        'graph': tree.toMap(),
        'links': links.toMap(),
      };
    } catch (e) {
      print(e);
      return <String, dynamic>{};
    }
  }

  @override
  String toString() => toMap().toString();
}
