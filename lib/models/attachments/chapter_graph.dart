class TChapterGraph {
  Map<int, List<int>> nodes;

  TChapterGraph(this.nodes);

  // Execute [action] for each connection of the graph.
  // * [action] Action (function) to execute for start and end (nodes) ID's of the connection.
  forEachConnection(Function(int start, int end) action) {
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
  addConnection(int start, int end) {
    if (nodes.containsKey(start)) {
      nodes[start]!.add(end);
      nodes[end] = [];
      return true;
    } else {
      return false;
    }
  }

  // Get total number of pages in the graph.
  numberOfPages() {
    return nodes.keys.length;
  }

  @override
  String toString() {
    return nodes.toString();
  }
}
