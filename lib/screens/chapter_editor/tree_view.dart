import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flow_chart/flutter_flow_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teia/models/chapter.dart';
import 'package:teia/services/storage_service.dart';
import 'dart:math' as math;

class TreeViewScreen extends StatefulWidget {
  final Chapter chapter;
  final double? width;
  final double? height;
  final Set<int> missingLinks;
  final Function(int)? createPage;
  final Function(int) clickPage;

  const TreeViewScreen({
    super.key,
    required this.chapter,
    this.createPage,
    this.width,
    this.height,
    required this.missingLinks,
    required this.clickPage,
  });

  @override
  State<TreeViewScreen> createState() => _TreeViewScreenState();
}

class _TreeViewScreenState extends State<TreeViewScreen> {
  /// Returns a list with [Graph, BuchheimWalkerAlgorithm];
  void buildTree(Chapter chapter) {
    chapter.tree.forEachConnection((start, end) {});
  }

  @override
  Widget build(BuildContext context) {
    buildTree(widget.chapter);
    return TreeView.simple(
      tree: TreeNode(
        data: widget.chapter.tree,
      ),
      builder: (context, node) {
        return ListTile(
          tileColor: Colors.blueGrey[100],
          title: Text("Page ${node.level + 1}"),
        );
      },
    );
  }
}
