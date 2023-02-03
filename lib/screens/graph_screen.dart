import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/views/graph_page_node.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({Key? key}) : super(key: key);

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late Graph graph;
  late BuchheimWalkerConfiguration builder;

  Color nodeColor = Colors.green[200]!;
  Color nodeHoverColor = Colors.green[300]!;
  Color nodeClickColor = Colors.green[400]!;
  Color arrowColor = Colors.green[300]!;

  TChapter chapter = TChapter.create(1, 'My chapter');

  @override
  void initState() {
    super.initState();
  }

  void buildGraph() {
    graph = Graph()..isTree = true;
    graph.addNode(Node.Id(1));

    chapter.graph.forEachConnection(
      (start, end) => graph.addEdge(
        Node.Id(start),
        Node.Id(end),
      ),
    );

    builder = BuchheimWalkerConfiguration();
    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    buildGraph();
    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 20.0),
      minScale: 0.0001,
      maxScale: 5.6,
      child: GraphView(
        graph: graph,
        algorithm: BuchheimWalkerAlgorithm(builder, ArrowEdgeRenderer()),
        paint: Paint()
          ..color = arrowColor
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
        builder: (Node node) {
          return GraphPageNode(
            id: node.key!.value as int,
            color: nodeColor,
            hoverColor: nodeHoverColor,
            clickColor: nodeClickColor,
            createPage: (id) {
              log('Clicked Plus $id');
              setState(() {
                chapter.addPage(id);
              });
              log(chapter.graph.toString());
            },
          );
        },
      ),
    );
  }
}
