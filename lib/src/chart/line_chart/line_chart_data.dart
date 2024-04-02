// coverage:ignore-file
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Image;

class LineChartData {

  LineChartData({
    this.lineBarsData = const [],
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    Color? backgroundColor,
  })  : backgroundColor = backgroundColor ?? Colors.transparent,
        minX = minX ?? double.nan,
        maxX = maxX ?? double.nan,
        minY = minY ?? double.nan,
        maxY = maxY ?? double.nan;
  double minX;
  double maxX;
  double minY;
  double maxY;

  final List<LineChartBarData> lineBarsData;

  Color backgroundColor;


  double get verticalDiff => maxY - minY;


  double get horizontalDiff => maxX - minX;
}

class LineChartBarData {
  LineChartBarData({
    this.spots = const [],
    this.show = true,
    Color? color,
    this.gradient,
    this.barWidth = 2.0,
    this.isCurved = false,
    this.isStrokeCapRound = false,
    this.isStrokeJoinRound = false,
    BarAreaData? belowBarData,
  })  : color =
            color ?? ((color == null && gradient == null) ? Colors.cyan : null),
        belowBarData = belowBarData ?? BarAreaData() {
    FlSpot? mostLeft;
    FlSpot? mostTop;
    FlSpot? mostRight;
    FlSpot? mostBottom;

    FlSpot? firstValidSpot;
    try {
      firstValidSpot =
          spots.firstWhere((element) => element != FlSpot.nullSpot);
    } catch (e) {
      // There is no valid spot
    }
    if (firstValidSpot != null) {
      for (final spot in spots) {
        if (spot.isNull()) {
          continue;
        }
        if (mostLeft == null || spot.x < mostLeft.x) {
          mostLeft = spot;
        }

        if (mostRight == null || spot.x > mostRight.x) {
          mostRight = spot;
        }

        if (mostTop == null || spot.y > mostTop.y) {
          mostTop = spot;
        }

        if (mostBottom == null || spot.y < mostBottom.y) {
          mostBottom = spot;
        }
      }
      mostLeftSpot = mostLeft!;
      mostTopSpot = mostTop!;
      mostRightSpot = mostRight!;
      mostBottomSpot = mostBottom!;
    }
  }

  final List<FlSpot> spots;

  late final FlSpot mostLeftSpot;

  late final FlSpot mostTopSpot;

  late final FlSpot mostRightSpot;

  late final FlSpot mostBottomSpot;

  final bool show;

  final Color? color;

  final Gradient? gradient;

  final double barWidth;

  final bool isCurved;

  final bool isStrokeCapRound;

  final bool isStrokeJoinRound;

  final BarAreaData belowBarData;
}


class BarAreaData {

  BarAreaData({
    this.show = false,
    Color? color,
    this.gradient,
    this.cutOffY = 0,
    this.applyCutOffY = false,
  }) : color = color ??
            ((color == null && gradient == null)
                ? Colors.blueGrey.withOpacity(0.5)
                : null);

  final bool show;

  final Color? color;

  final Gradient? gradient;

  final double cutOffY;

  final bool applyCutOffY;
}
