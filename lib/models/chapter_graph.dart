class ChapterGraph {
  Map<int, List<int>> nodes;

  ChapterGraph(this.nodes);

  // Execute [action] for each connection of the graph.
  // * [action] Action (function) to execute for start and end (nodes) ID's of the connection.
  void forEachConnection(Function(int start, int end) action) {
    nodes.forEach((start, endList) {
      for (var end in endList) {
        action(start, end);
      }
    });
  }

  // Add connection from [start] to [end] to graph.
  // * [start] Start node ID (page ID).
  // * [end] End node ID (page ID).
  // Returns false if [start] doesn't exist.
  bool addConnection(int start, int end) {
    if (nodes.containsKey(start)) {
      nodes[start]!.add(end);
      nodes[end] = [];
      return true;
    } else {
      return false;
    }
  }

  // Get total number of pages in the graph.
  int numberOfPages() {
    return nodes.keys.length;
  }

  // Check if page is leaf (has no child connections).
  // Returns true if pageId doesn't exist.
  bool isLeaf(int pageId) {
    final children = nodes[pageId];
    if (children == null) return true;
    return children.isEmpty;
  }

  @override
  String toString() {
    return nodes.toString();
  }
}
