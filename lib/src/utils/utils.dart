import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';

class Utils {
  factory Utils() {
    return _singleton;
  }

  Utils._internal();
  static Utils _singleton = Utils._internal();

  static const double _degrees2Radians = math.pi / 180.0;

  /// Converts degrees to radians
  double radians(double degrees) => degrees * _degrees2Radians;

}
