import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/graph_page_node.dart';

class ChapterGraphView extends StatefulWidget {
  final Chapter chapter;
  final double? width;
  final double? height;
  final Function(int)? createPage;
  final Function(int)? clickPage;

  const ChapterGraphView({
    Key? key,
    required this.chapter,
    this.createPage,
    this.width,
    this.height,
    this.clickPage,
  }) : super(key: key);

  @override
  State<ChapterGraphView> createState() => _ChapterGraphViewState();
}

class _ChapterGraphViewState extends State<ChapterGraphView> {
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
    graph.addEdge(
      Node.Id(2),
      Node.Id(1),
    );

    BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);

    Algorithm algorithm = BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder));

    return [
      graph,
      builder
    ];
  }

  @override
  Widget build(BuildContext context) {
    final result = buildGraph(widget.chapter);
    Graph graph = result[0];
    Algorithm algorithm = result[1];

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: InteractiveViewer(
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
              ..strokeWidth = 1.0
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
      ),
    );
  }
}
