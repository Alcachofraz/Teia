import 'package:flutter/material.dart';
import 'package:teia/utils/swatch.dart';

class Utils {
  static late Color backgroundColor;
  static late Color nodeInsideColor;
  static late Color nodeBorderColor;
  static late Color nodeTextColor;
  static late Color nodeIconColor;
  static late Color arrowColor;
  static late Color nodeHoverSplashColor;
  static late Color nodeClickSplashColor;

  static const double graphPadding = 50.0;
  static const double textEditorWeight = 0.5;
  static const double collapseButtonSize = 32;
  static const int textEditorAnimationDuration = 300;
  static const List<String> snippetColors = ['#f57c00', '#4caf50', '#2196f3'];

  static const textEditorStyle = TextStyle();

  static void init() {
    backgroundColor = swatch(const Color(0xffded2ba));
    nodeInsideColor = swatch(const Color(0xfff5f2eb));
    nodeBorderColor = swatch(const Color(0xff3c321d));
    nodeTextColor = swatch(const Color(0xff3c321d));
    nodeIconColor = swatch(const Color(0xff3c321d));
    nodeHoverSplashColor = swatch(const Color(0xfff0ebe0));
    nodeClickSplashColor = swatch(const Color(0xfff0ebe0));
    arrowColor = swatch(const Color(0xff3c321d));
  }

  static String colorHex(Color color) =>
      '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
}
