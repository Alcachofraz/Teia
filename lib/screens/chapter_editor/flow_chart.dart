import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/services/storage_service.dart';
import 'dart:math' as math;

class ChapterFlowChart extends StatefulWidget {
  final Chapter chapter;
  final double? width;
  final double? height;
  final Set<int> missingLinks;
  final Function(int)? createPage;
  final Function(int) clickPage;

  const ChapterFlowChart({
    super.key,
    required this.chapter,
    this.createPage,
    this.width,
    this.height,
    required this.missingLinks,
    required this.clickPage,
  });

  @override
  State<ChapterFlowChart> createState() => _ChapterFlowChartState();
}

class _ChapterFlowChartState extends State<ChapterFlowChart> {
  Dashboard dashboard = Dashboard(minimumZoomFactor: 1);

  Map<int, Offset> generatePyramidGraph(
    Map<int, Set<int>> graph,
  ) {
    const double verticalSpacing = 25;
    const double horizontalSpacing = 75;
    const double size = 100;
    Map<int, Offset> positions = {};

    List<int> currentLevelNodes = [1];
    int currentLevel = 1;

    Map<int, List<int>> nodesPerLevel = {};

    while (currentLevelNodes.isNotEmpty) {
      nodesPerLevel[currentLevel] = [...currentLevelNodes];
      List<int> nextLevelNodes = [];

      for (int node in currentLevelNodes) {
        graph[node]?.forEach((child) {
          if (!nextLevelNodes.contains(child)) {
            nextLevelNodes.add(child);
          }
        });
      }
      currentLevelNodes.clear();
      currentLevelNodes.addAll(nextLevelNodes);
      currentLevel++;
    }

    int maxNodesPerLevel = 0;
    for (List<int> nodes in nodesPerLevel.values) {
      if (nodes.length > maxNodesPerLevel) {
        maxNodesPerLevel = nodes.length;
      }
    }

    nodesPerLevel.forEach((level, nodes) {
      for (int node in nodes) {
        positions[node] = Offset(
          level * (size + (horizontalSpacing * level * 0.25)),
          ((maxNodesPerLevel / (nodes.length + 1)) +
                  nodes.indexOf(node) *
                      (maxNodesPerLevel / (nodes.length + 1))) *
              (size + verticalSpacing),
        );
      }
    });

    return positions;
  }

  FlowElement _addPage(int index, Offset position) {
    FlowElement element = FlowElement(
      size: Size(100, 100),
      position: position,
      text: 'Page $index',
      textSize: 18,
      kind: ElementKind.rectangle,
      handlers: [],
    );
    dashboard.addElement(element);
    return element;
  }

  /// Returns a list with [Graph, BuchheimWalkerAlgorithm];
  void buildDashboard(Chapter chapter) {
    dashboard = Dashboard(minimumZoomFactor: 1);
    // Generate position offsets for each page in [chapter.tree]
    Map<int, Offset> positions = generatePyramidGraph(chapter.tree.nodes);
    _addPage(1, positions[1] ?? Offset.zero);
    chapter.tree.forEachConnection((start, end) {
      FlowElement? startElement;
      FlowElement? endElement;
      for (FlowElement element in dashboard.elements) {
        if (element.text == 'Page $start') {
          startElement = element;
        }
        if (element.text == 'Page $end') {
          endElement = element;
        }
        if (startElement != null && endElement != null) {
          break;
        }
      }
      startElement ??= _addPage(start, positions[start] ?? Offset.zero);
      endElement ??= _addPage(end, positions[end] ?? Offset.zero);

      dashboard.addNextById(
        startElement,
        endElement.id,
        ArrowParams(style: ArrowStyle.curve, headRadius: 5),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    buildDashboard(widget.chapter);
    return FlowChart(
      dashboard: dashboard,
      onDashboardTapped: ((context, position) {}),
      onDashboardLongTapped: ((context, position) {}),
      onElementLongPressed: (context, offset, element) {},
      onElementPressed: (context, offset, element) {
        widget.clickPage(int.parse(element.text.split(' ')[1]));
      },
      onHandlerPressed: (context, position, handler, element) {},
      onHandlerLongPressed: (context, position, handler, element) {},
      onScaleUpdate: (newScale) {},
      onNewConnection: (srcElement, destElement) {},
      onPivotPressed: (context, pivot) {},
    );
  }
}
