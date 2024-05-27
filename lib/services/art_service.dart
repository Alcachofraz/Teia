import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum BackroundOrientation { right, left }

class ArtService extends GetxService {
  static ArtService get value => Get.put(ArtService());

  static final r = Random();

  /// Count of the avatars in the assets folder.
  static const int avatarCount = 25;

  /// Count of the backgrounds in the assets folder (each orientation).
  static const int backgroundCount = 2;

  /// Get the avatar asset path by indez, starting at 0.
  String assetPath(int index) {
    return 'assets/images/avatars/$index.png';
  }

  /// Randomly select an index.
  int randomAvatarIndex() {
    return r.nextInt(avatarCount);
  }

  /// List of avatar asset paths.
  List<String> avatarPaths() {
    return List.generate(avatarCount, (index) => assetPath(index));
  }

  /// List of avatar indexes.
  List<int> avatarIndexes() {
    return List.generate(avatarCount, (index) => index);
  }

  /// Randomly select two background asset paths.
  String randomBackgroundPath(BackroundOrientation orietantion) {
    return 'assets/images/background/${orietantion.name}/${r.nextInt(backgroundCount)}.png';
  }

  /// Random pastel color.
  Color pastel() {
    return HSLColor.fromAHSL(1.0, r.nextDouble() * 360, 0.4, 0.5).toColor();
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
