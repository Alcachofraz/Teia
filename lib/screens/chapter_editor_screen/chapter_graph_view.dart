import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/graph_page_node.dart';
import 'package:collection/collection.dart';

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
  Set<int> missingLinks = {};
  Function eq = const ListEquality().equals;

  /// Returns a list with [Graph, BuchheimWalkerAlgorithm];
  List<dynamic> buildGraph(Chapter chapter) {
    Graph graph = Graph();
    graph.addNode(Node.Id(1));

    chapter.graph.forEachConnection((start, end) {
      graph.addEdge(
        Node.Id(start),
        Node.Id(end),
      );
    });

    for (var element in chapter.graph.nodes.entries) {
      if (chapter.links.nodes.containsKey(element.key) && !eq(chapter.links.nodes[element.key], element.value)) {
        missingLinks.add(element.key);
      }
    }

    SugiyamaConfiguration sug = SugiyamaConfiguration()
      ..bendPointShape = CurvedBendPointShape(curveLength: 20)
      ..nodeSeparation = (32)
      ..levelSeparation = (32)
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;

    SugiyamaAlgorithm builder = SugiyamaAlgorithm(sug);

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
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              int id = node.key!.value as int;
              return GraphPageNode(
                id: id,
                missingLinks: missingLinks.contains(id),
                insideColor: Utils.graphSettings.nodeInsideColor,
                borderColor: Utils.graphSettings.nodeBorderColor,
                hoverColor: Utils.graphSettings.nodeHoverSplashColor,
                clickColor: Utils.graphSettings.nodeClickSplashColor,
                iconColor: Utils.graphSettings.nodeIconColor,
                clickPage: widget.clickPage,
                createPage: widget.createPage,
              );
            },
          ),
        ),
      ),
    );
  }
}
