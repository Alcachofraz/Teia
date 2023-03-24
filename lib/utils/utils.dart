import 'package:flutter/material.dart';
import 'package:teia/utils/swatch.dart';

class ChapterGraphSettings {
  final Color backgroundColor;
  final Color nodeInsideColor;
  final Color nodeBorderColor;
  final Color nodeTextColor;
  final Color nodeIconColor;
  final Color arrowColor;
  final Color nodeHoverSplashColor;
  final Color nodeClickSplashColor;
  final double padding;

  ChapterGraphSettings({
    required this.backgroundColor,
    required this.nodeInsideColor,
    required this.nodeBorderColor,
    required this.nodeTextColor,
    required this.nodeIconColor,
    required this.arrowColor,
    required this.nodeHoverSplashColor,
    required this.nodeClickSplashColor,
    this.padding = 50,
  });
}

class Utils {
  static late ChapterGraphSettings graphSettings;

  static const double textEditorDefaultWeight = 0.6;
  static const double loosePagesMenuDefaultHeight = 0.5;
  static const double loosePagesMenuMaximumHeight = 0.8;
  static const double loosePagesMenuMinimumHeight = 0.35;
  static const double dividerThickness = 16.0;
  static const int textEditorAnimationDuration = 300;
  static const double collapseButtonSize = 32;
  static const List<String> snippetColors = ['#f57c00', '#4caf50', '#2196f3'];

  static late final Color pageEditorBackgroundColor;
  static late final Color pageEditorSheetColor;

  static const textEditorStyle = TextStyle(fontFamily: 'Arial');

  static void init() {
    graphSettings = ChapterGraphSettings(
      backgroundColor: swatch(Colors.grey[100]!),
      nodeInsideColor: swatch(Colors.white),
      nodeBorderColor: swatch(Colors.black),
      nodeTextColor: swatch(Colors.black),
      nodeIconColor: swatch(Colors.black),
      nodeHoverSplashColor: swatch(Colors.grey[100]!),
      nodeClickSplashColor: swatch(Colors.grey[100]!),
      arrowColor: swatch(Colors.black),
      padding: 50.0,
    );
    pageEditorBackgroundColor = swatch(Colors.grey[50]!);
    pageEditorSheetColor = swatch(Colors.white);
  }

  static String colorHex(Color color) =>
      '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
}
