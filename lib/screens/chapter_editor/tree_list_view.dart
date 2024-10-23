import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/screens/chapter_editor/widgets/expandable.dart';

class TreeListView extends StatefulWidget {
  final Chapter chapter;
  final double? width;
  final double? height;
  final Set<int> missingLinks;
  final Function(int)? createPage;
  final Function(int) clickPage;

  const TreeListView({
    super.key,
    required this.chapter,
    this.createPage,
    this.width,
    this.height,
    required this.missingLinks,
    required this.clickPage,
  });

  @override
  State<TreeListView> createState() => _TreeListViewState();
}

class _TreeListViewState extends State<TreeListView> {
  // Keep track of the expanded nodes
  final Map<int, bool> expandedNodes = {};

  // Helper function to collapse all children of a node recursively
  void _collapseChildren(int parentId, Map<int, Set<int>> nodes) {
    if (!nodes.containsKey(parentId)) return;

    Set<int> children = nodes[parentId]!;
    for (var childId in children) {
      expandedNodes[childId] = false;
      _collapseChildren(childId, nodes);
    }
  }

  // Recursive function to build ListTiles
  List<Widget> _buildNodeList(
      Map<int, Set<int>> nodes, int? parentId, int level) {
    List<Widget> nodeList = [];

    // Get the children of the current parent node (if any)
    if (parentId == 0) {
      nodes[0] = {1};
    }
    Set<int> children = nodes[parentId]!;

    for (var nodeId in children) {
      // Check if this node is expanded
      bool isExpanded = expandedNodes[nodeId] ?? false;

      // Add an ExpansionTile for each node
      nodeList.add(
        Padding(
          padding: EdgeInsets.only(left: level * 16.0), // Indent by level
          child: Expandable(
            key: PageStorageKey<int>(nodeId), // Key for state preservation
            expanded: isExpanded,
            onTap: () {
              widget.clickPage(nodeId);
            },
            title: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Gap(12),
                Text('Page $nodeId'),
                Gap(12),
                if (widget.missingLinks.contains(nodeId))
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.link_off_rounded,
                      color: Colors.red,
                      size: 18.0,
                    ),
                  ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      bool expanded = !(expandedNodes[nodeId] ?? false);
                      setState(() {
                        expandedNodes[nodeId] = expanded;
                      });
                      if (expanded) {
                        // Collapse all children nodes when collapsing this node
                        _collapseChildren(nodeId, nodes);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 10, 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isExpanded) Gap(6),
                          Gap(4),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_right_rounded,
                            size: 20,
                            color: Colors.deepPurple,
                          ),
                          if (!isExpanded)
                            Text(
                              '(${nodes[nodeId]!.length})',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            children:
                isExpanded ? _buildNodeList(nodes, nodeId, level + 1) : [],
          ),
        ),
      );
    }

    return nodeList;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ListView(
        children: [
          Gap(16),
          ..._buildNodeList(
            widget.chapter.tree.nodes,
            0,
            0,
          ),
          Gap(16),
        ],
      ),
    );
  }
}
