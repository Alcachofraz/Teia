import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget loadingRotate({double? size, Color? color}) => Center(
      child: SpinKitRing(
        color: color ?? Colors.black,
        duration: const Duration(milliseconds: 1000),
        size: size ?? 50,
      ),
    );

Widget loadingDots({double? size, Color? color}) => Center(
      child: SpinKitThreeBounce(
        color: color ?? Colors.black,
        duration: const Duration(milliseconds: 1000),
        size: size ?? 50,
      ),
    );
