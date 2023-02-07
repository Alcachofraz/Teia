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

  static late double graphPadding;

  static void init() {
    graphPadding = 50.0;

    backgroundColor = swatch(const Color(0xffded2ba));
    nodeInsideColor = swatch(const Color(0xfff5f2eb));
    nodeBorderColor = swatch(const Color(0xff3c321d));
    nodeTextColor = swatch(const Color(0xff3c321d));
    nodeIconColor = swatch(const Color(0xff3c321d));
    nodeHoverSplashColor = swatch(const Color(0xfff0ebe0));
    nodeClickSplashColor = swatch(const Color(0xfff0ebe0));
    arrowColor = swatch(const Color(0xff3c321d));
  }
}
