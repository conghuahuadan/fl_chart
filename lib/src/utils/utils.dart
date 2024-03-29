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

  static const double _radians2Degrees = 180.0 / math.pi;

  /// Converts radians to degrees
  double degrees(double radians) => radians * _radians2Degrees;

  Offset calculateRotationOffset(Size size, double degree) {
    final rotatedHeight = (size.width * math.sin(radians(degree))).abs() +
        (size.height * cos(radians(degree))).abs();
    final rotatedWidth = (size.width * cos(radians(degree))).abs() +
        (size.height * sin(radians(degree))).abs();
    return Offset(
      (size.width - rotatedWidth) / 2,
      (size.height - rotatedHeight) / 2,
    );
  }


  /// Default value for BorderSide where borderSide value is not exists
  static const BorderSide defaultBorderSide = BorderSide(width: 0);


  /// billion number
  /// in short scale (https://en.wikipedia.org/wiki/Billion)
  static const double billion = 1000000000;

  /// million number
  static const double million = 1000000;

  /// kilo (thousands) number
  static const double kilo = 1000;

  /// Returns a TextStyle based on provided [context], if [providedStyle] provided we try to merge it.
  TextStyle getThemeAwareTextStyle(
    BuildContext context,
    TextStyle? providedStyle,
  ) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    var effectiveTextStyle = providedStyle;
    if (providedStyle == null || providedStyle.inherit) {
      effectiveTextStyle = defaultTextStyle.style.merge(providedStyle);
    }
    if (MediaQuery.boldTextOf(context)) {
      effectiveTextStyle = effectiveTextStyle!
          .merge(const TextStyle(fontWeight: FontWeight.bold));
    }
    return effectiveTextStyle!;
  }

  /// Finds the best initial interval value
  ///
  /// If there is a zero point in the axis, we a value that passes through it.
  /// For example if we have -3 to +3, with interval 2. if we start from -3, we get something like this: -3, -1, +1, +3
  /// But the most important point is zero in most cases. with this logic we get this: -2, 0, 2
  double getBestInitialIntervalValue(
    double min,
    double max,
    double interval, {
    double baseline = 0.0,
  }) {
    final diff = baseline - min;
    final mod = diff % interval;
    if ((max - min).abs() <= mod) {
      return min;
    }
    if (mod == 0) {
      return min;
    }
    return min + mod;
  }

  /// Converts radius number to sigma for drawing shadows
  double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }
}
