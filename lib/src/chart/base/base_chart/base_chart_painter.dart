// coverage:ignore-file
import 'package:fl_chart/src/chart/base/base_chart/base_chart_data.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/material.dart';


/// Holds data for painting on canvas
class PaintHolder<Data extends BaseChartData> {
  /// Holds data for painting on canvas
  const PaintHolder(this.data);

  /// [data] is what we need to show frame by frame (it might be changed by an animator)
  final Data data;
}
