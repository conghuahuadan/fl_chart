// coverage:ignore-file
import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/extensions/border_extension.dart';
import 'package:flutter/material.dart';

/// This class holds all data needed for [BaseChartPainter].
///
/// In this phase we draw the border,
/// and handle touches in an abstract way.
abstract class BaseChartData with EquatableMixin {
  /// It draws 4 borders around your chart, you can customize it using [borderData],
  /// [touchData] defines the touch behavior and responses.
  BaseChartData({
    FlBorderData? borderData,
  }) : borderData = borderData ?? FlBorderData();

  /// Holds data to drawing border around the chart.
  FlBorderData borderData;

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        borderData,
      ];
}

/// Holds data to drawing border around the chart.
class FlBorderData with EquatableMixin {
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

  /// Lerps a [FlBorderData] based on [t] value, check [Tween.lerp].
  static FlBorderData lerp(FlBorderData a, FlBorderData b, double t) {
    return FlBorderData(
      show: b.show,
      border: Border.lerp(a.border, b.border, t),
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        show,
        border,
      ];
}
