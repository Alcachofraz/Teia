class ChapterGraph {
  final Map<int, List<int>> _nodes;

  ChapterGraph(this._nodes);

  // Nodes getter
  get nodes => _nodes;

  // Execute [action] for each connection of the graph.
  // * [action] Action (function) to execute for start and end (nodes) ID's of the connection.
  void forEachConnection(Function(int start, int end) action) {
    _nodes.forEach((start, endList) {
      for (var end in endList) {
        action(start, end);
      }
    });
  }

  // Add connection from [start] to [end] to graph.
  // * [start] Start node ID (page ID).
  // * [end] End node ID (page ID).
  // Returns false if [start] doesn't exist or if nodes is null.
  bool addConnection(int start, int end) {
    if (_nodes.containsKey(start)) {
      _nodes[start]!.add(end);
      _nodes[end] = [];
      return true;
    } else {
      return false;
    }
  }

  // Get total number of pages in the graph.
  int numberOfPages() {
    return _nodes.keys.length;
  }

  // Check if page is leaf (has no child connections).
  // Returns true if pageId doesn't exist or nodes is null.
  bool isLeaf(int pageId) {
    final children = _nodes[pageId];
    if (children == null) return true;
    return children.isEmpty;
  }
}
