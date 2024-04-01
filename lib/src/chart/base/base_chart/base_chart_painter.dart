// coverage:ignore-file
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/material.dart';


/// Holds data for painting on canvas
class PaintHolder<LineChartData> {
  /// Holds data for painting on canvas
  const PaintHolder(this.data);

  /// [data] is what we need to show frame by frame (it might be changed by an animator)
  final LineChartData data;
}
