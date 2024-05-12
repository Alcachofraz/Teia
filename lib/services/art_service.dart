import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ArtService extends GetxService {
  static ArtService get value => Get.put(ArtService());

  static final r = Random();

  /// Count of the avatars in the assets folder.
  static const int count = 25;

  /// Get the avatar asset path by indez, starting at 0.
  String asset(int index) {
    return 'assets/images/avatars/$index.png';
  }

  /// Randomly select an index.
  int random() {
    return r.nextInt(count);
  }

  /// Randomly select two indexes.
  List<int> randomPair() {
    final first = r.nextInt(count);
    int second;
    do {
      second = r.nextInt(count);
    } while (first == second);
    return [first, second];
  }

  /// Random pastel color.
  Color pastel() {
    return HSLColor.fromAHSL(1.0, r.nextDouble() * 360, 0.5, 0.9).toColor();
  }

  /// Darken a given color.
  Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(
      c.alpha,
      (c.red * f).round(),
      (c.green * f).round(),
      (c.blue * f).round(),
    );
  }
}
