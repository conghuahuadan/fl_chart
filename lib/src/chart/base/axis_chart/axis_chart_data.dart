// coverage:ignore-file
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Image;


/// Represents a conceptual position in cartesian (axis based) space.
class FlSpot {
  /// [x] determines cartesian (axis based) horizontally position
  /// 0 means most left point of the chart
  ///
  /// [y] determines cartesian (axis based) vertically position
  /// 0 means most bottom point of the chart
  const FlSpot(this.x, this.y);

  final double x;
  final double y;

  ///Prints x and y coordinates of FlSpot list
  @override
  String toString() => '($x, $y)';

  /// Used for splitting lines, or maybe other concepts.
  static const FlSpot nullSpot = FlSpot(double.nan, double.nan);

  /// Sets zero for x and y
  static const FlSpot zero = FlSpot(0, 0);

  /// Determines if [x] or [y] is null.
  bool isNull() => this == nullSpot;

  /// Determines if [x] and [y] is not null.
  bool isNotNull() => !isNull();
}
