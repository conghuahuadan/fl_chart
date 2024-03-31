// coverage:ignore-file
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/utils/lerp.dart';
import 'package:flutter/material.dart' hide Image;


class LineChartData extends AxisChartData with EquatableMixin {

  LineChartData({
    this.lineBarsData = const [],
    super.borderData,
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    super.backgroundColor,
  }) : super(
          minX: minX ?? double.nan,
          maxX: maxX ?? double.nan,
          minY: minY ?? double.nan,
          maxY: maxY ?? double.nan,
        );

  /// [LineChart] draws some lines in various shapes and overlaps them.
  final List<LineChartBarData> lineBarsData;


  /// Copies current [LineChartData] to a new [LineChartData],
  /// and replaces provided values.
  LineChartData copyWith({
    List<LineChartBarData>? lineBarsData,
    FlBorderData? borderData,
    double? minX,
    double? maxX,
    double? baselineX,
    double? minY,
    double? maxY,
    double? baselineY,
    Color? backgroundColor,
  }) {
    return LineChartData(
      lineBarsData: lineBarsData ?? this.lineBarsData,
      borderData: borderData ?? this.borderData,
      minX: minX ?? this.minX,
      maxX: maxX ?? this.maxX,
      minY: minY ?? this.minY,
      maxY: maxY ?? this.maxY,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        lineBarsData,
        borderData,
        minX,
        maxX,
        minY,
        maxY,
        backgroundColor,
      ];
}

class LineChartBarData with EquatableMixin {

  LineChartBarData({
    this.spots = const [],
    this.show = true,
    Color? color,
    this.gradient,
    this.barWidth = 2.0,
    this.isCurved = false,
    this.curveSmoothness = 0.35,
    this.preventCurveOverShooting = false,
    this.preventCurveOvershootingThreshold = 10.0,
    this.isStrokeCapRound = false,
    this.isStrokeJoinRound = false,
    BarAreaData? belowBarData,
    BarAreaData? aboveBarData,
    this.dashArray,
    this.shadow = const Shadow(color: Colors.transparent),
    this.isStepLineChart = false,
  })  : color =
            color ?? ((color == null && gradient == null) ? Colors.cyan : null),
        belowBarData = belowBarData ?? BarAreaData(),
        aboveBarData = aboveBarData ?? BarAreaData() {
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

  /// This line goes through this spots.
  ///
  /// You can have multiple lines by splitting them,
  /// put a [FlSpot.nullSpot] between each section.
  final List<FlSpot> spots;

  /// We keep the most left spot to prevent redundant calculations
  late final FlSpot mostLeftSpot;

  /// We keep the most top spot to prevent redundant calculations
  late final FlSpot mostTopSpot;

  /// We keep the most right spot to prevent redundant calculations
  late final FlSpot mostRightSpot;

  /// We keep the most bottom spot to prevent redundant calculations
  late final FlSpot mostBottomSpot;

  /// Determines to show or hide the line.
  final bool show;

  /// If provided, this [LineChartBarData] draws with this [color]
  /// Otherwise we use  [gradient] to draw the background.
  /// It throws an exception if you provide both [color] and [gradient]
  final Color? color;

  /// If provided, this [LineChartBarData] draws with this [gradient].
  /// Otherwise we use [color] to draw the background.
  /// It throws an exception if you provide both [color] and [gradient]
  final Gradient? gradient;

  /// Determines thickness of drawing line.
  final double barWidth;

  /// If it's true, [LineChart] draws the line with curved edges,
  /// otherwise it draws line with hard edges.
  final bool isCurved;

  /// If [isCurved] is true, it determines smoothness of the curved edges.
  final double curveSmoothness;

  /// Prevent overshooting when draw curve line with high value changes.
  /// check this [issue](https://github.com/imaNNeo/fl_chart/issues/25)
  final bool preventCurveOverShooting;

  /// Applies threshold for [preventCurveOverShooting] algorithm.
  final double preventCurveOvershootingThreshold;

  /// Determines the style of line's cap.
  final bool isStrokeCapRound;

  /// Determines the style of line joins.
  final bool isStrokeJoinRound;

  /// Fills the space blow the line, using a color or gradient.
  final BarAreaData belowBarData;

  /// Fills the space above the line, using a color or gradient.
  final BarAreaData aboveBarData;

  /// Determines the dash length and space respectively, fill it if you want to have dashed line.
  final List<int>? dashArray;

  /// Drops a shadow behind the bar line.
  final Shadow shadow;

  /// If sets true, it draws the chart in Step Line Chart style, using [LineChartBarData.lineChartStepData].
  final bool isStepLineChart;

  /// Lerps a [LineChartBarData] based on [t] value, check [Tween.lerp].
  static LineChartBarData lerp(
    LineChartBarData a,
    LineChartBarData b,
    double t,
  ) {
    return LineChartBarData(
      show: b.show,
      barWidth: lerpDouble(a.barWidth, b.barWidth, t)!,
      belowBarData: BarAreaData.lerp(a.belowBarData, b.belowBarData, t),
      aboveBarData: BarAreaData.lerp(a.aboveBarData, b.aboveBarData, t),
      curveSmoothness: b.curveSmoothness,
      isCurved: b.isCurved,
      isStrokeCapRound: b.isStrokeCapRound,
      isStrokeJoinRound: b.isStrokeJoinRound,
      preventCurveOverShooting: b.preventCurveOverShooting,
      preventCurveOvershootingThreshold: lerpDouble(
        a.preventCurveOvershootingThreshold,
        b.preventCurveOvershootingThreshold,
        t,
      )!,
      color: Color.lerp(a.color, b.color, t),
      gradient: Gradient.lerp(a.gradient, b.gradient, t),
      shadow: Shadow.lerp(a.shadow, b.shadow, t)!,
      isStepLineChart: b.isStepLineChart,
    );
  }

  /// Copies current [LineChartBarData] to a new [LineChartBarData],
  /// and replaces provided values.
  LineChartBarData copyWith({
    List<FlSpot>? spots,
    bool? show,
    Color? color,
    Gradient? gradient,
    double? barWidth,
    bool? isCurved,
    double? curveSmoothness,
    bool? preventCurveOverShooting,
    double? preventCurveOvershootingThreshold,
    bool? isStrokeCapRound,
    bool? isStrokeJoinRound,
    BarAreaData? belowBarData,
    BarAreaData? aboveBarData,
    FlDotData? dotData,
    List<int>? dashArray,
    List<int>? showingIndicators,
    Shadow? shadow,
    bool? isStepLineChart,
  }) {
    return LineChartBarData(
      spots: spots ?? this.spots,
      show: show ?? this.show,
      color: color ?? this.color,
      gradient: gradient ?? this.gradient,
      barWidth: barWidth ?? this.barWidth,
      isCurved: isCurved ?? this.isCurved,
      curveSmoothness: curveSmoothness ?? this.curveSmoothness,
      preventCurveOverShooting:
          preventCurveOverShooting ?? this.preventCurveOverShooting,
      preventCurveOvershootingThreshold: preventCurveOvershootingThreshold ??
          this.preventCurveOvershootingThreshold,
      isStrokeCapRound: isStrokeCapRound ?? this.isStrokeCapRound,
      isStrokeJoinRound: isStrokeJoinRound ?? this.isStrokeJoinRound,
      belowBarData: belowBarData ?? this.belowBarData,
      aboveBarData: aboveBarData ?? this.aboveBarData,
      dashArray: dashArray ?? this.dashArray,
      shadow: shadow ?? this.shadow,
      isStepLineChart: isStepLineChart ?? this.isStepLineChart,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        spots,
        show,
        color,
        gradient,
        barWidth,
        isCurved,
        curveSmoothness,
        preventCurveOverShooting,
        preventCurveOvershootingThreshold,
        isStrokeCapRound,
        isStrokeJoinRound,
        belowBarData,
        aboveBarData,
        dashArray,
        shadow,
        isStepLineChart,
      ];
}



/// Holds data for filling an area (above or below) of the line with a color or gradient.
class BarAreaData with EquatableMixin {
  /// if [show] is true, [LineChart] fills above and below area of each line
  /// with a color or gradient.
  ///
  /// [color] determines the color of above or below space area,
  /// if one color provided it applies a solid color,
  /// otherwise it gradients between provided colors for drawing the line.
  /// Gradient happens using provided [gradientColorStops], [gradientFrom], [gradientTo].
  /// if you want it draw normally, don't touch them,
  /// check [LinearGradient] for understanding [gradientColorStops]
  ///
  /// If [spotsLine] is provided, it draws some lines from each spot
  /// to the bottom or top of the chart.
  ///
  /// If [applyCutOffY] is true, it cuts the drawing by the [cutOffY] line.
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

  /// If provided, this [BarAreaData] draws with this [color]
  /// Otherwise we use  [gradient] to draw the background.
  /// It throws an exception if you provide both [color] and [gradient]
  final Color? color;

  /// If provided, this [BarAreaData] draws with this [gradient].
  /// Otherwise we use [color] to draw the background.
  /// It throws an exception if you provide both [color] and [gradient]
  final Gradient? gradient;

  /// cut the drawing below or above area to this y value
  final double cutOffY;

  /// determines should or shouldn't apply cutOffY
  final bool applyCutOffY;

  /// Lerps a [BarAreaData] based on [t] value, check [Tween.lerp].
  static BarAreaData lerp(BarAreaData a, BarAreaData b, double t) {
    return BarAreaData(
      show: b.show,
      color: Color.lerp(a.color, b.color, t),
      // ignore: invalid_use_of_protected_member
      gradient: Gradient.lerp(a.gradient, b.gradient, t),
      cutOffY: lerpDouble(a.cutOffY, b.cutOffY, t)!,
      applyCutOffY: b.applyCutOffY,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        show,
        color,
        gradient,
        cutOffY,
        applyCutOffY,
      ];
}


/// This class holds data about drawing spot dots on the drawing bar line.
class FlDotData with EquatableMixin {
  /// set [show] false to prevent dots from drawing,
  /// if you want to show or hide dots in some spots,
  /// override [checkToShowDot] to handle it in your way.
  const FlDotData({
    this.show = true,
  });

  /// Determines show or hide all dots.
  final bool show;

  /// Lerps a [FlDotData] based on [t] value, check [Tween.lerp].
  static FlDotData lerp(FlDotData a, FlDotData b, double t) {
    return FlDotData(
      show: b.show,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        show,
      ];
}


/// Represent a targeted spot inside a line bar.
class LineBarSpot extends FlSpot with EquatableMixin {
  /// [bar] is the [LineChartBarData] that this spot is inside of,
  /// [barIndex] is the index of our [bar], in the [LineChartData.lineBarsData] list,
  /// [spot] is the targeted spot.
  /// [spotIndex] is the index this [FlSpot], in the [LineChartBarData.spots] list.
  LineBarSpot(
    this.bar,
    this.barIndex,
    FlSpot spot,
  )   :
        super(spot.x, spot.y);

  /// Is the [LineChartBarData] that this spot is inside of.
  final LineChartBarData bar;

  /// Is the index of our [bar], in the [LineChartData.lineBarsData] list,
  final int barIndex;


  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        bar,
        barIndex,
        x,
        y,
      ];
}




