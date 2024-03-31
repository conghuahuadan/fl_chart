import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_painter.dart';
import 'package:fl_chart/src/extensions/paint_extension.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/material.dart';

/// This class is responsible to draw the grid behind all axis base charts.
/// also we have two useful function [getPixelX] and [getPixelY] that used
/// in child classes -> [BarChartPainter], [LineChartPainter]
/// [dataList] is the currently showing data (it may produced by an animation using lerp function),
/// [targetData] is the target data, that animation is going to show (if animating)
abstract class AxisChartPainter{
  AxisChartPainter() {
  }

  /// [_rangeAnnotationPaint] draws range annotations;

  /// Paints [AxisChartData] into the provided canvas.
  @override
  void paint(
    BuildContext context,
    CanvasWrapper canvasWrapper,
    PaintHolder<LineChartData> holder,
  ) {
  }


  /// With this function we can convert our [FlSpot] x
  /// to the view base axis x .
  /// the view 0, 0 is on the top/left, but the spots is bottom/left
  double getPixelX(double spotX, Size viewSize, PaintHolder<LineChartData> holder) {
    final data = holder.data;
    final deltaX = data.maxX - data.minX;
    if (deltaX == 0.0) {
      return 0;
    }
    return ((spotX - data.minX) / deltaX) * viewSize.width;
  }

  /// With this function we can convert our [FlSpot] y
  /// to the view base axis y.
  double getPixelY(double spotY, Size viewSize, PaintHolder<LineChartData> holder) {
    final data = holder.data;
    final deltaY = data.maxY - data.minY;
    if (deltaY == 0.0) {
      return viewSize.height;
    }
    return viewSize.height - (((spotY - data.minY) / deltaY) * viewSize.height);
  }

}
