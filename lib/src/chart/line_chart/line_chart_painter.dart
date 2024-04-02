import 'dart:math';
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/src/utils/dash_painter.dart';

class LineChartPainter {
  LineChartPainter() : super() {
    _barPaint = Paint()..style = PaintingStyle.stroke;

    _barAreaPaint = Paint()..style = PaintingStyle.fill;

    _linePaint = Paint()..style = PaintingStyle.stroke;

    dashPainter = const DashPainter(step: 6, span: 3);
  }

  late Paint _linePaint;
  late Paint _barPaint;
  late Paint _barAreaPaint;

  Path linePath = Path();
  late DashPainter dashPainter;

  int minX = 0;
  int maxX = 0;
  int minY = 0;
  int maxY = 0;

  void paint(
    BuildContext context,
    CanvasWrapper canvasWrapper,
    LineChartData data,
  ) {
    if (data.lineBarsData.isEmpty) {
      return;
    }

    for (var i = 0; i < data.lineBarsData.length; i++) {
      final barData = data.lineBarsData[i];

      drawBarLine(canvasWrapper, barData, data);
    }
  }

  List<List<FlSpot>> splitByNullSpots(List<FlSpot> spots) {
    final barList = <List<FlSpot>>[[]];

    for (final spot in spots) {
      if (spot.isNotNull()) {
        barList.last.add(spot);
      } else if (barList.last.isNotEmpty) {
        barList.add([]);
      }
    }

    if (barList.last.isEmpty) {
      barList.removeLast();
    }
    return barList;
  }

  @visibleForTesting
  void drawBarLine(
    CanvasWrapper canvasWrapper,
    LineChartBarData barData,
    LineChartData data,
  ) {
    final viewSize = canvasWrapper.size;

    final spots = barData.spots;
    // final barList = splitByNullSpots(barData.spots);

    final barPath = generateBarPath(viewSize, barData, spots, data);

    final belowBarPath =
        generateBelowBarPath(viewSize, barData, barPath, spots, data);

    final completelyFillAboveBarPath = generateAboveBarPath(
      viewSize,
      barData,
      barPath,
      spots,
      data,
      fillCompletely: true,
    );

    drawBelowBar(
      canvasWrapper,
      belowBarPath,
      completelyFillAboveBarPath,
      data,
      barData,
    );
    drawBar(canvasWrapper, barPath, barData, data);

    final double y = getPixelY(spots[spots.length - 1].y, viewSize, data);

    linePath
      ..moveTo(0, y)
      ..lineTo(viewSize.width, y);

    _linePaint
      ..strokeWidth = 0.3
      ..color = Color(0x80000000);
    dashPainter.paint(canvasWrapper.canvas, linePath, _linePaint);
  }

  @visibleForTesting
  Path generateBarPath(
    Size viewSize,
    LineChartBarData barData,
    List<FlSpot> barSpots,
    LineChartData data, {
    Path? appendToPath,
  }) {
    return generateNormalBarPath(
      viewSize,
      barData,
      barSpots,
      data,
      appendToPath: appendToPath,
    );
  }

  @visibleForTesting
  Path generateNormalBarPath(
    Size viewSize,
    LineChartBarData barData,
    List<FlSpot> barSpots,
    LineChartData data, {
    Path? appendToPath,
  }) {
    final path = appendToPath ?? Path();
    final size = barSpots.length;

    var temp = Offset.zero;

    final x = getPixelX(barSpots[0].x, viewSize, data);
    final y = getPixelY(barSpots[0].y, viewSize, data);
    if (appendToPath == null) {
      path.moveTo(x, y);
      if (size == 1) {
        path.lineTo(x, y);
      }
    } else {
      path.lineTo(x, y);
    }
    for (var i = 1; i < size; i++) {
      final current = Offset(
        getPixelX(barSpots[i].x, viewSize, data),
        getPixelY(barSpots[i].y, viewSize, data),
      );

      final previous = Offset(
        getPixelX(barSpots[i - 1].x, viewSize, data),
        getPixelY(barSpots[i - 1].y, viewSize, data),
      );

      final next = Offset(
        getPixelX(barSpots[i + 1 < size ? i + 1 : i].x, viewSize, data),
        getPixelY(barSpots[i + 1 < size ? i + 1 : i].y, viewSize, data),
      );

      final controlPoint1 = previous + temp;

      const smoothness = 0.0;
      temp = ((next - previous) / 2) * smoothness;

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

  @visibleForTesting
  Path generateBelowBarPath(
    Size viewSize,
    LineChartBarData barData,
    Path barPath,
    List<FlSpot> barSpots,
    LineChartData data, {
    bool fillCompletely = false,
  }) {
    final belowBarPath = Path.from(barPath);

    var x = getPixelX(barSpots[barSpots.length - 1].x, viewSize, data);
    double y;
    y = getPixelY(0, viewSize, data);

    belowBarPath.lineTo(x, y);

    y = getPixelY(0, viewSize, data);
    belowBarPath.lineTo(x, y);

    x = getPixelX(barSpots[0].x, viewSize, data);
    y = getPixelY(barSpots[0].y, viewSize, data);
    belowBarPath
      ..lineTo(x, y)
      ..close();

    return belowBarPath;
  }

  @visibleForTesting
  Path generateAboveBarPath(
    Size viewSize,
    LineChartBarData barData,
    Path barPath,
    List<FlSpot> barSpots,
    LineChartData data, {
    bool fillCompletely = false,
  }) {
    final aboveBarPath = Path.from(barPath);

    var x = getPixelX(barSpots[barSpots.length - 1].x, viewSize, data);
    double y;
    y = 0.0;

    aboveBarPath.lineTo(x, y);

    x = getPixelX(barSpots[0].x, viewSize, data);
    y = 0.0;

    aboveBarPath.lineTo(x, y);

    x = getPixelX(barSpots[0].x, viewSize, data);
    y = getPixelY(barSpots[0].y, viewSize, data);
    aboveBarPath
      ..lineTo(x, y)
      ..close();

    return aboveBarPath;
  }

  @visibleForTesting
  void drawBelowBar(
    CanvasWrapper canvasWrapper,
    Path belowBarPath,
    Path filledAboveBarPath,
    LineChartData data,
    LineChartBarData barData,
  ) {
    final viewSize = canvasWrapper.size;

    final belowBarLargestRect = Rect.fromLTRB(
      0,
      0,
      viewSize.width,
      viewSize.height,
    );

    _barAreaPaint.setColorOrGradient(
      barData.color.withOpacity(0.12),
      LinearGradient(
        colors: [
          barData.color.withOpacity(0.12),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      belowBarLargestRect,
    );

    canvasWrapper.drawPath(belowBarPath, _barAreaPaint);
  }

  @visibleForTesting
  void drawBar(
    CanvasWrapper canvasWrapper,
    Path barPath,
    LineChartBarData barData,
    LineChartData data,
  ) {
    _barPaint
      ..strokeCap = barData.isStrokeCapRound ? StrokeCap.round : StrokeCap.butt
      ..strokeJoin = StrokeJoin.round
      ..color = barData.color
      ..maskFilter = null
      ..strokeWidth = barData.barWidth
      ..transparentIfWidthIsZero();

    canvasWrapper.drawPath(barPath, _barPaint);
  }

  double getPixelX(double spotX, Size viewSize, LineChartData data) {
    final deltaX = data.maxX - data.minX;
    if (deltaX == 0.0) {
      return 0;
    }
    return ((spotX - data.minX) / deltaX) * viewSize.width;
  }

  double getPixelY(double spotY, Size viewSize, LineChartData data) {
    final deltaY = data.maxY - data.minY;
    if (deltaY == 0.0) {
      return viewSize.height;
    }
    return viewSize.height - (((spotY - data.minY) / deltaY) * viewSize.height);
  }
}

extension PaintExtension on Paint {
  void transparentIfWidthIsZero() {
    if (strokeWidth == 0) {
      shader = null;
      color = color.withOpacity(0);
    }
  }

  void setColorOrGradient(Color? color, Gradient? gradient, Rect rect) {
    if (gradient != null) {
      this.color = Colors.black;
      shader = gradient.createShader(rect);
    } else {
      this.color = color ?? Colors.transparent;
      shader = null;
    }
  }
}
