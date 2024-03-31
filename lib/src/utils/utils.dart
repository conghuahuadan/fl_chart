import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';

class Utils {
  factory Utils() {
    return _singleton;
  }

  Utils._internal();
  static Utils _singleton = Utils._internal();

}
