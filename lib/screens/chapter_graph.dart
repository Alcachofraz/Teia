import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/graph_page_node.dart';

class ChapterGraph extends StatefulWidget {
  final Chapter chapter;
  final Function(int)? createPage;
  final Function(int)? clickPage;

  const ChapterGraph({
    Key? key,
    required this.chapter,
    this.createPage,
    this.clickPage,
  }) : super(key: key);

  @override
  State<ChapterGraph> createState() => _ChapterGraphState();
}

class _ChapterGraphState extends State<ChapterGraph> {
  /// Returns a list with [Graph, BuchheimWalkerAlgorithm];
  List<dynamic> buildGraph(Chapter chapter) {
    Graph graph = Graph()..isTree = true;
    graph.addNode(Node.Id(1));

    chapter.graph.forEachConnection(
      (start, end) => graph.addEdge(
        Node.Id(start),
        Node.Id(end),
      ),
    );

    BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);

    //Algorithm algorithm = BuchheimWalkerAlgorithm(builder, ArrowEdgeRenderer());
    Algorithm algorithm = BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder));

    return [graph, algorithm];
  }

  @override
  Widget build(BuildContext context) {
    final result = buildGraph(widget.chapter);
    Graph graph = result[0];
    Algorithm algorithm = result[1];

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      constrained: false,
      child: Center(
        child: GraphView(
          graph: graph,
          algorithm: algorithm,
          paint: Paint()
            ..color = Utils.graphSettings.arrowColor
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke,
          builder: (Node node) {
            return Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
              child: GraphPageNode(
                id: node.key!.value as int,
                insideColor: Utils.graphSettings.nodeInsideColor,
                borderColor: Utils.graphSettings.nodeBorderColor,
                hoverColor: Utils.graphSettings.nodeHoverSplashColor,
                clickColor: Utils.graphSettings.nodeClickSplashColor,
                iconColor: Utils.graphSettings.nodeIconColor,
                clickPage: widget.clickPage,
                createPage: widget.createPage,
              ),
            );
          },
        ),
      ),
    );
  }
}
