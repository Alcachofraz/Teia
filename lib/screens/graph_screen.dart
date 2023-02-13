import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/screens/text_editor_screen.dart';
import 'package:teia/utils/utils.dart';
import 'package:teia/views/graph_page_node.dart';
import 'package:teia/views/misc/screen_wrapper.dart';

class GraphScreen extends StatefulWidget {
  final bool picking;

  const GraphScreen({Key? key, this.picking = false}) : super(key: key);

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final Chapter _chapter = Chapter.create(1, 'My chapter');

  @override
  void initState() {
    super.initState();
  }

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

    return [graph, BuchheimWalkerAlgorithm(builder, ArrowEdgeRenderer())];
  }

  @override
  Widget build(BuildContext context) {
    final result = buildGraph(_chapter);
    Graph graph = result[0];
    BuchheimWalkerAlgorithm algorithm = result[1];
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
            algorithm: algorithm,
            paint: Paint()
              ..color = Utils.arrowColor
              ..strokeWidth = 1.5
              ..style = PaintingStyle.stroke,
            builder: (Node node) {
              return Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                child: GraphPageNode(
                  id: node.key!.value as int,
                  insideColor: Utils.nodeInsideColor,
                  borderColor: Utils.nodeBorderColor,
                  hoverColor: Utils.nodeHoverSplashColor,
                  clickColor: Utils.nodeClickSplashColor,
                  iconColor: Utils.nodeIconColor,
                  simplified: widget.picking,
                  enterPage: widget.picking
                      ? (id) {
                          Navigator.pop(context, id);
                        }
                      : (id) {
                          log('Clicked $id');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TextEditorScreen(),
                            ),
                          );
                        },
                  createPage: widget.picking
                      ? null
                      : (id) {
                          log('Clicked Plus $id');
                          setState(() {
                            _chapter.addPage(id);
                          });
                        },
                  dissociatePage: widget.picking ? null : (id) {},
                  connectPage: widget.picking
                      ? null
                      : (from) async {
                          int to = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GraphScreen(
                                picking: true,
                              ),
                            ),
                          );
                          setState(() {
                            _chapter.graph.addConnection(from, to);
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
