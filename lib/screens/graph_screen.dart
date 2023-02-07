import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/screens/text_editor_screen.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/graph_page_node.dart';
import 'package:teia/views/screen_wrapper.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({Key? key}) : super(key: key);

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  late Graph graph;
  late BuchheimWalkerConfiguration builder;

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
    return ScreenWrapper(
      backgroundColor: Utils.backgroundColor,
      body: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        constrained: false,
        child: Center(
          child: GraphView(
            graph: graph,
            algorithm: BuchheimWalkerAlgorithm(builder, ArrowEdgeRenderer()),
            paint: Paint()
              ..color = Utils.arrowColor
              ..strokeWidth = 1
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: GraphPageNode(
                  id: node.key!.value as int,
                  insideColor: Utils.nodeInsideColor,
                  borderColor: Utils.nodeBorderColor,
                  hoverColor: Utils.nodeHoverSplashColor,
                  clickColor: Utils.nodeClickSplashColor,
                  plusColor: Utils.nodePlusColor,
                  enterPage: (id) {
                    log('Clicked $id');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TextEditorScreen(),
                      ),
                    );
                  },
                  createPage: (id) {
                    log('Clicked Plus $id');
                    setState(() {
                      chapter.addPage(id);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
