// coverage:ignore-file
import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/extensions/border_extension.dart';
import 'package:flutter/material.dart';

/// This class holds all data needed for [BaseChartPainter].
///
/// In this phase we draw the border,
/// and handle touches in an abstract way.
abstract class BaseChartData  {
  /// It draws 4 borders around your chart, you can customize it using [borderData],
  /// [touchData] defines the touch behavior and responses.
  BaseChartData({
    FlBorderData? borderData,
  }) : borderData = borderData ?? FlBorderData();

  /// Holds data to drawing border around the chart.
  FlBorderData borderData;

  /// Used for
}

/// Holds data to drawing border around the chart.
class FlBorderData  {
  /// [show] Determines showing or hiding border around the chart.
  /// [border] Determines the visual look of 4 borders, see [Border].
  FlBorderData({
    bool? show,
    Border? border,
  })  : show = show ?? true,
        border = border ?? Border.all();
  final bool show;
  Border border;

  /// returns false if all borders have 0 width or 0 opacity
  bool isVisible() => show && border.isVisible();
}
