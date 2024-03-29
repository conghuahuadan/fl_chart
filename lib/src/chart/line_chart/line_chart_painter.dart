import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_extensions.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_painter.dart';
import 'package:fl_chart/src/chart/base/base_chart/base_chart_painter.dart';
import 'package:fl_chart/src/extensions/paint_extension.dart';
import 'package:fl_chart/src/extensions/path_extension.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:fl_chart/src/utils/utils.dart';
import 'package:flutter/material.dart';

/// Paints [LineChartData] in the canvas, it can be used in a [CustomPainter]
class LineChartPainter extends AxisChartPainter<LineChartData> {
  /// Paints [dataList] into canvas, it is the animating [LineChartData],
  /// [targetData] is the animation's target and remains the same
  /// during animation, then we should use it  when we need to show
  /// tooltips or something like that, because [dataList] is changing constantly.
  ///
  /// [textScale] used for scaling texts inside the chart,
  /// parent can use [MediaQuery.textScaleFactor] to respect
  /// the system's font size.
  LineChartPainter() : super() {
    _barPaint = Paint()..style = PaintingStyle.stroke;

    _barAreaPaint = Paint()..style = PaintingStyle.fill;

    _barAreaLinesPaint = Paint()..style = PaintingStyle.stroke;

    _clearBarAreaPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0x00000000)
      ..blendMode = BlendMode.dstIn;
  }
  late Paint _barPaint;
  late Paint _barAreaPaint;
  late Paint _barAreaLinesPaint;
  late Paint _clearBarAreaPaint;

  /// Paints [LineChartData] into the provided canvas.
  @override
  void paint(
    BuildContext context,
    CanvasWrapper canvasWrapper,
    PaintHolder<LineChartData> holder,
  ) {
    final data = holder.data;
    if (data.lineBarsData.isEmpty) {
      return;
    }
    super.paint(context, canvasWrapper, holder);

    /// draw each line independently on the chart
    for (var i = 0; i < data.lineBarsData.length; i++) {
      final barData = data.lineBarsData[i];

      if (!barData.show) {
        continue;
      }

      drawBarLine(canvasWrapper, barData, holder);

    }

  }

  @visibleForTesting
  void drawBarLine(
    CanvasWrapper canvasWrapper,
    LineChartBarData barData,
    PaintHolder<LineChartData> holder,
  ) {
    final viewSize = canvasWrapper.size;
    final barList = barData.spots.splitByNullSpots();

    // paint each sublist that was built above
    // bar is passed in separately from barData
    // because barData is the whole line
    // and bar is a piece of that line
    for (final bar in barList) {
      final barPath = generateBarPath(viewSize, barData, bar, holder);

      final belowBarPath =
          generateBelowBarPath(viewSize, barData, barPath, bar, holder);

      final completelyFillAboveBarPath = generateAboveBarPath(
        viewSize,
        barData,
        barPath,
        bar,
        holder,
        fillCompletely: true,
      );

      drawBelowBar(
        canvasWrapper,
        belowBarPath,
        completelyFillAboveBarPath,
        holder,
        barData,
      );
      drawBar(canvasWrapper, barPath, barData, holder);
    }
  }

  /// Generates a path, based on [LineChartBarData.isStepChart] for step style, and normal style.
  @visibleForTesting
  Path generateBarPath(
    Size viewSize,
    LineChartBarData barData,
    List<FlSpot> barSpots,
    PaintHolder<LineChartData> holder, {
    Path? appendToPath,
  }) {
    return generateNormalBarPath(
      viewSize,
      barData,
      barSpots,
      holder,
      appendToPath: appendToPath,
    );
  }

  /// firstly we generate the bar line that we should draw,
  /// then we reuse it to fill below bar space.
  /// there is two type of barPath that generate here,
  /// first one is the sharp corners line on spot connections
  /// second one is curved corners line on spot connections,
  /// and we use isCurved to find out how we should generate it,
  /// If you want to concatenate paths together for creating an area between
  /// multiple bars for example, you can pass the appendToPath
  @visibleForTesting
  Path generateNormalBarPath(
    Size viewSize,
    LineChartBarData barData,
    List<FlSpot> barSpots,
    PaintHolder<LineChartData> holder, {
    Path? appendToPath,
  }) {
    final path = appendToPath ?? Path();
    final size = barSpots.length;

    var temp = Offset.zero;

    final x = getPixelX(barSpots[0].x, viewSize, holder);
    final y = getPixelY(barSpots[0].y, viewSize, holder);
    if (appendToPath == null) {
      path.moveTo(x, y);
      if (size == 1) {
        path.lineTo(x, y);
      }
    } else {
      path.lineTo(x, y);
    }
    for (var i = 1; i < size; i++) {
      /// CurrentSpot
      final current = Offset(
        getPixelX(barSpots[i].x, viewSize, holder),
        getPixelY(barSpots[i].y, viewSize, holder),
      );

      /// previous spot
      final previous = Offset(
        getPixelX(barSpots[i - 1].x, viewSize, holder),
        getPixelY(barSpots[i - 1].y, viewSize, holder),
      );

      /// next point
      final next = Offset(
        getPixelX(barSpots[i + 1 < size ? i + 1 : i].x, viewSize, holder),
        getPixelY(barSpots[i + 1 < size ? i + 1 : i].y, viewSize, holder),
      );

      final controlPoint1 = previous + temp;

      /// if the isCurved is false, we set 0 for smoothness,
      /// it means we should not have any smoothness then we face with
      /// the sharped corners line
      final smoothness = barData.isCurved ? barData.curveSmoothness : 0.0;
      temp = ((next - previous) / 2) * smoothness;

      if (barData.preventCurveOverShooting) {
        if ((next - current).dy <= barData.preventCurveOvershootingThreshold ||
            (current - previous).dy <=
                barData.preventCurveOvershootingThreshold) {
          temp = Offset(temp.dx, 0);
        }

        if ((next - current).dx <= barData.preventCurveOvershootingThreshold ||
            (current - previous).dx <=
                barData.preventCurveOvershootingThreshold) {
          temp = Offset(0, temp.dy);
        }
      }

      final controlPoint2 = current - temp;

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        current.dx,
        current.dy,
      );
    }

    return path;
  }

  /// it generates below area path using a copy of [barPath],
  /// if cutOffY is provided by the [BarAreaData], it cut the area to the provided cutOffY value,
  /// if [fillCompletely] is true, the cutOffY will be ignored,
  /// and a completely filled path will return,
  @visibleForTesting
  Path generateBelowBarPath(
    Size viewSize,
    LineChartBarData barData,
    Path barPath,
    List<FlSpot> barSpots,
    PaintHolder<LineChartData> holder, {
    bool fillCompletely = false,
  }) {
    final belowBarPath = Path.from(barPath);

    /// Line To Bottom Right
    var x = getPixelX(barSpots[barSpots.length - 1].x, viewSize, holder);
    double y;
    if (!fillCompletely && barData.belowBarData.applyCutOffY) {
      y = getPixelY(barData.belowBarData.cutOffY, viewSize, holder);
    } else {
      y = viewSize.height;
    }
    belowBarPath.lineTo(x, y);

    /// Line To Bottom Left
    x = getPixelX(barSpots[0].x, viewSize, holder);
    if (!fillCompletely && barData.belowBarData.applyCutOffY) {
      y = getPixelY(barData.belowBarData.cutOffY, viewSize, holder);
    } else {
      y = viewSize.height;
    }
    belowBarPath.lineTo(x, y);

    /// Line To Top Left
    x = getPixelX(barSpots[0].x, viewSize, holder);
    y = getPixelY(barSpots[0].y, viewSize, holder);
    belowBarPath
      ..lineTo(x, y)
      ..close();

    return belowBarPath;
  }

  /// it generates above area path using a copy of [barPath],
  /// if cutOffY is provided by the [BarAreaData], it cut the area to the provided cutOffY value,
  /// if [fillCompletely] is true, the cutOffY will be ignored,
  /// and a completely filled path will return,
  @visibleForTesting
  Path generateAboveBarPath(
    Size viewSize,
    LineChartBarData barData,
    Path barPath,
    List<FlSpot> barSpots,
    PaintHolder<LineChartData> holder, {
    bool fillCompletely = false,
  }) {
    final aboveBarPath = Path.from(barPath);

    /// Line To Top Right
    var x = getPixelX(barSpots[barSpots.length - 1].x, viewSize, holder);
    double y;
    if (!fillCompletely && barData.aboveBarData.applyCutOffY) {
      y = getPixelY(barData.aboveBarData.cutOffY, viewSize, holder);
    } else {
      y = 0.0;
    }
    aboveBarPath.lineTo(x, y);

    /// Line To Top Left
    x = getPixelX(barSpots[0].x, viewSize, holder);
    if (!fillCompletely && barData.aboveBarData.applyCutOffY) {
      y = getPixelY(barData.aboveBarData.cutOffY, viewSize, holder);
    } else {
      y = 0.0;
    }
    aboveBarPath.lineTo(x, y);

    /// Line To Bottom Left
    x = getPixelX(barSpots[0].x, viewSize, holder);
    y = getPixelY(barSpots[0].y, viewSize, holder);
    aboveBarPath
      ..lineTo(x, y)
      ..close();

    return aboveBarPath;
  }

  /// firstly we draw [belowBarPath], then if cutOffY value is provided in [BarAreaData],
  /// [belowBarPath] maybe draw over the main bar line,
  /// then to fix the problem we use [filledAboveBarPath] to clear the above section from this draw.
  @visibleForTesting
  void drawBelowBar(
    CanvasWrapper canvasWrapper,
    Path belowBarPath,
    Path filledAboveBarPath,
    PaintHolder<LineChartData> holder,
    LineChartBarData barData,
  ) {
    if (!barData.belowBarData.show) {
      return;
    }

    final viewSize = canvasWrapper.size;

    final belowBarLargestRect = Rect.fromLTRB(
      getPixelX(barData.mostLeftSpot.x, viewSize, holder),
      getPixelY(barData.mostTopSpot.y, viewSize, holder),
      getPixelX(barData.mostRightSpot.x, viewSize, holder),
      viewSize.height,
    );

    final belowBar = barData.belowBarData;
    _barAreaPaint.setColorOrGradient(
      belowBar.color,
      belowBar.gradient,
      belowBarLargestRect,
    );

    if (barData.belowBarData.applyCutOffY) {
      canvasWrapper.saveLayer(
        Rect.fromLTWH(0, 0, viewSize.width, viewSize.height),
        Paint(),
      );
    }

    canvasWrapper.drawPath(belowBarPath, _barAreaPaint);

    // clear the above area that get out of the bar line
    if (barData.belowBarData.applyCutOffY) {
      canvasWrapper
        ..drawPath(filledAboveBarPath, _clearBarAreaPaint)
        ..restore();
    }

    /// draw below spots line
    if (barData.belowBarData.spotsLine.show) {
      for (final spot in barData.spots) {
        if (barData.belowBarData.spotsLine.checkToShowSpotLine(spot)) {
          final from = Offset(
            getPixelX(spot.x, viewSize, holder),
            getPixelY(spot.y, viewSize, holder),
          );

          Offset to;

          // Check applyCutOffY
          if (barData.belowBarData.spotsLine.applyCutOffY &&
              barData.belowBarData.applyCutOffY) {
            to = Offset(
              getPixelX(spot.x, viewSize, holder),
              getPixelY(barData.belowBarData.cutOffY, viewSize, holder),
            );
          } else {
            to = Offset(
              getPixelX(spot.x, viewSize, holder),
              viewSize.height,
            );
          }

          final lineStyle = barData.belowBarData.spotsLine.flLineStyle;
          _barAreaLinesPaint
            ..setColorOrGradientForLine(
              lineStyle.color,
              lineStyle.gradient,
              from: from,
              to: to,
            )
            ..strokeWidth = lineStyle.strokeWidth
            ..transparentIfWidthIsZero();

          canvasWrapper.drawDashedLine(
            from,
            to,
            _barAreaLinesPaint,
            lineStyle.dashArray,
          );
        }
      }
    }
  }

  /// draw the main bar line by the [barPath]
  @visibleForTesting
  void drawBar(
    CanvasWrapper canvasWrapper,
    Path barPath,
    LineChartBarData barData,
    PaintHolder<LineChartData> holder,
  ) {
    if (!barData.show) {
      return;
    }
    final viewSize = canvasWrapper.size;

    _barPaint
      ..strokeCap = barData.isStrokeCapRound ? StrokeCap.round : StrokeCap.butt
      ..strokeJoin =
          barData.isStrokeJoinRound ? StrokeJoin.round : StrokeJoin.miter;

    final rectAroundTheLine = Rect.fromLTRB(
      getPixelX(barData.mostLeftSpot.x, viewSize, holder),
      getPixelY(barData.mostTopSpot.y, viewSize, holder),
      getPixelX(barData.mostRightSpot.x, viewSize, holder),
      getPixelY(barData.mostBottomSpot.y, viewSize, holder),
    );
    _barPaint
      ..setColorOrGradient(
        barData.color,
        barData.gradient,
        rectAroundTheLine,
      )
      ..maskFilter = null
      ..strokeWidth = barData.barWidth
      ..transparentIfWidthIsZero();

    barPath = barPath.toDashedPath(barData.dashArray);
    canvasWrapper.drawPath(barPath, _barPaint);
  }


}
