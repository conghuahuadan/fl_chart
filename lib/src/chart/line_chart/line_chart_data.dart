// coverage:ignore-file
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/extensions/color_extension.dart';
import 'package:fl_chart/src/extensions/gradient_extension.dart';
import 'package:fl_chart/src/utils/lerp.dart';
import 'package:flutter/material.dart' hide Image;


class LineChartData extends AxisChartData with EquatableMixin {

  LineChartData({
    this.lineBarsData = const [],
    super.borderData,
    double? minX,
    double? maxX,
    super.baselineX,
    double? minY,
    double? maxY,
    super.baselineY,
    super.clipData = const FlClipData.none(),
    super.backgroundColor,
  }) : super(
          minX: minX ?? double.nan,
          maxX: maxX ?? double.nan,
          minY: minY ?? double.nan,
          maxY: maxY ?? double.nan,
        );

  /// [LineChart] draws some lines in various shapes and overlaps them.
  final List<LineChartBarData> lineBarsData;

  /// Lerps a [BaseChartData] based on [t] value, check [Tween.lerp].
  @override
  LineChartData lerp(BaseChartData a, BaseChartData b, double t) {
    if (a is LineChartData && b is LineChartData) {
      return LineChartData(
        minX: lerpDouble(a.minX, b.minX, t),
        maxX: lerpDouble(a.maxX, b.maxX, t),
        baselineX: lerpDouble(a.baselineX, b.baselineX, t),
        minY: lerpDouble(a.minY, b.minY, t),
        maxY: lerpDouble(a.maxY, b.maxY, t),
        baselineY: lerpDouble(a.baselineY, b.baselineY, t),
        backgroundColor: Color.lerp(a.backgroundColor, b.backgroundColor, t),
        borderData: FlBorderData.lerp(a.borderData, b.borderData, t),
        clipData: b.clipData,
        lineBarsData:
            lerpLineChartBarDataList(a.lineBarsData, b.lineBarsData, t)!,
      );
    } else {
      throw Exception('Illegal State');
    }
  }

  /// Copies current [LineChartData] to a new [LineChartData],
  /// and replaces provided values.
  LineChartData copyWith({
    List<LineChartBarData>? lineBarsData,
    RangeAnnotations? rangeAnnotations,
    ExtraLinesData? extraLinesData,
    FlGridData? gridData,
    FlBorderData? borderData,
    double? minX,
    double? maxX,
    double? baselineX,
    double? minY,
    double? maxY,
    double? baselineY,
    FlClipData? clipData,
    Color? backgroundColor,
  }) {
    return LineChartData(
      lineBarsData: lineBarsData ?? this.lineBarsData,
      borderData: borderData ?? this.borderData,
      minX: minX ?? this.minX,
      maxX: maxX ?? this.maxX,
      baselineX: baselineX ?? this.baselineX,
      minY: minY ?? this.minY,
      maxY: maxY ?? this.maxY,
      baselineY: baselineY ?? this.baselineY,
      clipData: clipData ?? this.clipData,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        lineBarsData,
        extraLinesData,
        borderData,
        rangeAnnotations,
        minX,
        maxX,
        baselineX,
        minY,
        maxY,
        baselineY,
        clipData,
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
    this.dotData = const FlDotData(),
    this.showingIndicators = const [],
    this.dashArray,
    this.shadow = const Shadow(color: Colors.transparent),
    this.isStepLineChart = false,
    this.lineChartStepData = const LineChartStepData(),
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

  /// Responsible to showing [spots] on the line as a circular point.
  final FlDotData dotData;

  /// Show indicators based on provided indexes
  final List<int> showingIndicators;

  /// Determines the dash length and space respectively, fill it if you want to have dashed line.
  final List<int>? dashArray;

  /// Drops a shadow behind the bar line.
  final Shadow shadow;

  /// If sets true, it draws the chart in Step Line Chart style, using [LineChartBarData.lineChartStepData].
  final bool isStepLineChart;

  /// Holds data for representing a Step Line Chart, and works only if [isStepChart] is true.
  final LineChartStepData lineChartStepData;

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
      dotData: FlDotData.lerp(a.dotData, b.dotData, t),
      dashArray: lerpIntList(a.dashArray, b.dashArray, t),
      color: Color.lerp(a.color, b.color, t),
      gradient: Gradient.lerp(a.gradient, b.gradient, t),
      spots: lerpFlSpotList(a.spots, b.spots, t)!,
      showingIndicators: b.showingIndicators,
      shadow: Shadow.lerp(a.shadow, b.shadow, t)!,
      isStepLineChart: b.isStepLineChart,
      lineChartStepData:
          LineChartStepData.lerp(a.lineChartStepData, b.lineChartStepData, t),
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
    LineChartStepData? lineChartStepData,
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
      dotData: dotData ?? this.dotData,
      showingIndicators: showingIndicators ?? this.showingIndicators,
      shadow: shadow ?? this.shadow,
      isStepLineChart: isStepLineChart ?? this.isStepLineChart,
      lineChartStepData: lineChartStepData ?? this.lineChartStepData,
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
        dotData,
        showingIndicators,
        dashArray,
        shadow,
        isStepLineChart,
        lineChartStepData,
      ];
}

/// Holds data for representing a Step Line Chart, and works only if [LineChartBarData.isStepChart] is true.
class LineChartStepData with EquatableMixin {
  /// Determines the [stepDirection] of each step;
  const LineChartStepData({this.stepDirection = stepDirectionMiddle});

  /// Go to the next spot directly, with the current point's y value.
  static const stepDirectionForward = 0.0;

  /// Go to the half with the current spot y, and with the next spot y for the rest.
  static const stepDirectionMiddle = 0.5;

  /// Go to the next spot y and direct line to the next spot.
  static const stepDirectionBackward = 1.0;

  /// Determines the direction of each step;
  final double stepDirection;

  /// Lerps a [LineChartStepData] based on [t] value, check [Tween.lerp].
  static LineChartStepData lerp(
    LineChartStepData a,
    LineChartStepData b,
    double t,
  ) {
    return LineChartStepData(
      stepDirection: lerpDouble(a.stepDirection, b.stepDirection, t)!,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [stepDirection];
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
    this.spotsLine = const BarAreaSpotsLine(),
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

  /// holds data for drawing a line from each spot the the bottom, or top of the chart
  final BarAreaSpotsLine spotsLine;

  /// cut the drawing below or above area to this y value
  final double cutOffY;

  /// determines should or shouldn't apply cutOffY
  final bool applyCutOffY;

  /// Lerps a [BarAreaData] based on [t] value, check [Tween.lerp].
  static BarAreaData lerp(BarAreaData a, BarAreaData b, double t) {
    return BarAreaData(
      show: b.show,
      spotsLine: BarAreaSpotsLine.lerp(a.spotsLine, b.spotsLine, t),
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
        spotsLine,
        cutOffY,
        applyCutOffY,
      ];
}

/// Holds data about filling below or above space of the bar line,
class BetweenBarsData with EquatableMixin {
  BetweenBarsData({
    required this.fromIndex,
    required this.toIndex,
    Color? color,
    this.gradient,
  }) : color = color ??
            ((color == null && gradient == null)
                ? Colors.blueGrey.withOpacity(0.5)
                : null);

  /// The index of the lineBarsData from where the area has to be rendered
  final int fromIndex;

  /// The index of the lineBarsData until where the area has to be rendered
  final int toIndex;

  /// If provided, this [BetweenBarsData] draws with this [color]
  /// Otherwise we use  [gradient] to draw the background.
  /// It throws an exception if you provide both [color] and [gradient]
  final Color? color;

  /// If provided, this [BetweenBarsData] draws with this [gradient].
  /// Otherwise we use [color] to draw the background.
  /// It throws an exception if you provide both [color] and [gradient]
  final Gradient? gradient;

  /// Lerps a [BetweenBarsData] based on [t] value, check [Tween.lerp].
  static BetweenBarsData lerp(BetweenBarsData a, BetweenBarsData b, double t) {
    return BetweenBarsData(
      fromIndex: b.fromIndex,
      toIndex: b.toIndex,
      color: Color.lerp(a.color, b.color, t),
      gradient: Gradient.lerp(a.gradient, b.gradient, t),
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        fromIndex,
        toIndex,
        color,
        gradient,
      ];
}

/// Holds data for drawing line on the spots under the [BarAreaData].
class BarAreaSpotsLine with EquatableMixin {
  /// If [show] is true, [LineChart] draws some lines on above or below the spots,
  /// you can customize the appearance of the lines using [flLineStyle]
  /// and you can decide to show or hide the lines on each spot using [checkToShowSpotLine].
  const BarAreaSpotsLine({
    this.show = false,
    this.flLineStyle = const FlLine(),
    this.checkToShowSpotLine = showAllSpotsBelowLine,
    this.applyCutOffY = true,
  });

  /// Determines to show or hide all the lines.
  final bool show;

  /// Holds appearance of drawing line on the spots.
  final FlLine flLineStyle;

  /// Checks to show or hide lines on the spots.
  final CheckToShowSpotLine checkToShowSpotLine;

  /// Determines to inherit the cutOff properties from its parent [BarAreaData]
  final bool applyCutOffY;

  /// Lerps a [BarAreaSpotsLine] based on [t] value, check [Tween.lerp].
  static BarAreaSpotsLine lerp(
    BarAreaSpotsLine a,
    BarAreaSpotsLine b,
    double t,
  ) {
    return BarAreaSpotsLine(
      show: b.show,
      checkToShowSpotLine: b.checkToShowSpotLine,
      flLineStyle: FlLine.lerp(a.flLineStyle, b.flLineStyle, t),
      applyCutOffY: b.applyCutOffY,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        show,
        flLineStyle,
        checkToShowSpotLine,
        applyCutOffY,
      ];
}

/// It used for determine showing or hiding [BarAreaSpotsLine]s
///
/// Gives you the checking spot, and you have to decide to
/// show or not show the line on the provided spot.
typedef CheckToShowSpotLine = bool Function(FlSpot spot);

/// Shows all spot lines.
bool showAllSpotsBelowLine(FlSpot spot) {
  return true;
}

/// The callback passed to get the color of a [FlSpot]
///
/// The callback receives [FlSpot], which is the target spot,
/// [double] is the percentage of spot along the bar line,
/// [LineChartBarData] is the chart's bar.
/// It should return a [Color] that needs to be used for drawing target.
typedef GetDotColorCallback = Color Function(FlSpot, double, LineChartBarData);

/// If there is one color in [LineChartBarData.mainColors], it returns that color,
/// otherwise it returns the color along the gradient colors based on the [xPercentage].
Color _defaultGetDotColor(FlSpot _, double xPercentage, LineChartBarData bar) {
  if (bar.gradient != null && bar.gradient is LinearGradient) {
    return lerpGradient(
      bar.gradient!.colors,
      bar.gradient!.getSafeColorStops(),
      xPercentage / 100,
    );
  }
  return bar.gradient?.colors.first ?? bar.color ?? Colors.blueGrey;
}

/// If there is one color in [LineChartBarData.mainColors], it returns that color in a darker mode,
/// otherwise it returns the color along the gradient colors based on the [xPercentage] in a darker mode.
Color _defaultGetDotStrokeColor(
  FlSpot spot,
  double xPercentage,
  LineChartBarData bar,
) {
  Color color;
  if (bar.gradient != null && bar.gradient is LinearGradient) {
    color = lerpGradient(
      bar.gradient!.colors,
      bar.gradient!.getSafeColorStops(),
      xPercentage / 100,
    );
  } else {
    color = bar.gradient?.colors.first ?? bar.color ?? Colors.blueGrey;
  }
  return color.darken();
}

/// The callback passed to get the painter of a [FlSpot]
///
/// The callback receives [FlSpot], which is the target spot,
/// [LineChartBarData] is the chart's bar.
/// [int] is the index position of the spot.
/// It should return a [FlDotPainter] that needs to be used for drawing target.
typedef GetDotPainterCallback = FlDotPainter Function(
  FlSpot,
  double,
  LineChartBarData,
  int,
);

FlDotPainter _defaultGetDotPainter(
  FlSpot spot,
  double xPercentage,
  LineChartBarData bar,
  int index, {
  double? size,
}) {
  return FlDotCirclePainter(
    radius: size,
    color: _defaultGetDotColor(spot, xPercentage, bar),
    strokeColor: _defaultGetDotStrokeColor(spot, xPercentage, bar),
  );
}

/// This class holds data about drawing spot dots on the drawing bar line.
class FlDotData with EquatableMixin {
  /// set [show] false to prevent dots from drawing,
  /// if you want to show or hide dots in some spots,
  /// override [checkToShowDot] to handle it in your way.
  const FlDotData({
    this.show = true,
    this.checkToShowDot = showAllDots,
    this.getDotPainter = _defaultGetDotPainter,
  });

  /// Determines show or hide all dots.
  final bool show;

  /// Checks to show or hide an individual dot.
  final CheckToShowDot checkToShowDot;

  /// Callback which is called to set the painter of the given [FlSpot].
  /// The [FlSpot] is provided as parameter to this callback
  final GetDotPainterCallback getDotPainter;

  /// Lerps a [FlDotData] based on [t] value, check [Tween.lerp].
  static FlDotData lerp(FlDotData a, FlDotData b, double t) {
    return FlDotData(
      show: b.show,
      checkToShowDot: b.checkToShowDot,
      getDotPainter: b.getDotPainter,
    );
  }

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        show,
        checkToShowDot,
        getDotPainter,
      ];
}

/// It determines showing or hiding [FlDotData] on the spots.
///
/// It gives you the checking [FlSpot] and you should decide to
/// show or hide the dot on this spot by returning true or false.
typedef CheckToShowDot = bool Function(FlSpot spot, LineChartBarData barData);

/// Shows all dots on spots.
bool showAllDots(FlSpot spot, LineChartBarData barData) {
  return true;
}

/// Shows a text label
abstract class FlLineLabel with EquatableMixin {
  /// Draws a title on the line, align it with [alignment] over the line,
  /// applies [padding] for spaces, and applies [style] for changing color,
  /// size, ... of the text.
  /// [show] determines showing label or not.
  const FlLineLabel({
    required this.show,
    required this.padding,
    required this.style,
    required this.alignment,
  });

  /// Determines showing label or not.
  final bool show;

  /// Inner spaces around the drawing text.
  final EdgeInsetsGeometry padding;

  /// Sets style of the drawing text.
  final TextStyle? style;

  /// Aligns the text on the line.
  final Alignment alignment;

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        show,
        padding,
        style,
        alignment,
      ];
}

/// Used for showing touch indicators (a thicker line and larger dot on the targeted spot).
///
/// It gives you the [spotIndexes] that touch happened, or manually targeted,
/// in the given [barData], you should return a list of [TouchedSpotIndicatorData],
/// length of this list should be equal to the [spotIndexes.length],
/// each [TouchedSpotIndicatorData] determines the look of showing indicator.
typedef GetTouchedSpotIndicator = List<TouchedSpotIndicatorData?> Function(
  LineChartBarData barData,
  List<int> spotIndexes,
);

/// Used for determine the touch indicator line's starting/end point.
typedef GetTouchLineY = double Function(
  LineChartBarData barData,
  int spotIndex,
);

/// Used to calculate the distance between coordinates of a touch event and a spot
typedef CalculateTouchDistance = double Function(
  Offset touchPoint,
  Offset spotPixelCoordinates,
);

/// Default distanceCalculator only considers distance on x axis
double _xDistance(Offset touchPoint, Offset spotPixelCoordinates) {
  return (touchPoint.dx - spotPixelCoordinates.dx).abs();
}

/// Default presentation of touched indicators.
List<TouchedSpotIndicatorData> defaultTouchedIndicators(
  LineChartBarData barData,
  List<int> indicators,
) {
  return indicators.map((int index) {
    /// Indicator Line
    var lineColor = barData.gradient?.colors.first ?? barData.color;
    if (barData.dotData.show) {
      lineColor = _defaultGetDotColor(barData.spots[index], 0, barData);
    }
    const lineStrokeWidth = 4.0;
    final flLine = FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

    var dotSize = 10.0;
    if (barData.dotData.show) {
      dotSize = 4.0 * 1.8;
    }

    final dotData = FlDotData(
      getDotPainter: (spot, percent, bar, index) =>
          _defaultGetDotPainter(spot, percent, bar, index, size: dotSize),
    );

    return TouchedSpotIndicatorData(flLine, dotData);
  }).toList();
}

/// By default line starts from the bottom of the chart.
double defaultGetTouchLineStart(LineChartBarData barData, int spotIndex) {
  return -double.infinity;
}

/// By default line ends at the touched point.
double defaultGetTouchLineEnd(LineChartBarData barData, int spotIndex) {
  return barData.spots[spotIndex].y;
}

/// Holds representation data for showing tooltip popup on top of spots.
class LineTouchTooltipData with EquatableMixin {
  /// if [LineTouchData.handleBuiltInTouches] is true,
  /// [LineChart] shows a tooltip popup on top of spots automatically when touch happens,
  /// otherwise you can show it manually using [LineChartData.showingTooltipIndicators].
  /// Tooltip shows on top of spots, with [tooltipBgColor] as a background color,
  /// and you can set corner radius using [tooltipRoundedRadius].
  /// If you want to have a padding inside the tooltip, fill [tooltipPadding],
  /// or If you want to have a bottom margin, set [tooltipMargin].
  /// Content of the tooltip will provide using [getTooltipItems] callback, you can override it
  /// and pass your custom data to show in the tooltip.
  /// You can restrict the tooltip's width using [maxContentWidth].
  /// Sometimes, [LineChart] shows the tooltip outside of the chart,
  /// you can set [fitInsideHorizontally] true to force it to shift inside the chart horizontally,
  /// also you can set [fitInsideVertically] true to force it to shift inside the chart vertically.
  const LineTouchTooltipData({
    this.tooltipBgColor = const Color.fromRGBO(96, 125, 139, 1),
    this.tooltipRoundedRadius = 4,
    this.tooltipPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.tooltipMargin = 16,
    this.tooltipHorizontalAlignment = FLHorizontalAlignment.center,
    this.tooltipHorizontalOffset = 0,
    this.maxContentWidth = 120,
    this.getTooltipItems = defaultLineTooltipItem,
    this.fitInsideHorizontally = false,
    this.fitInsideVertically = false,
    this.showOnTopOfTheChartBoxArea = false,
    this.rotateAngle = 0.0,
    this.tooltipBorder = BorderSide.none,
  });

  /// The tooltip background color.
  final Color tooltipBgColor;

  /// Sets a rounded radius for the tooltip.
  final double tooltipRoundedRadius;

  /// Applies a padding for showing contents inside the tooltip.
  final EdgeInsets tooltipPadding;

  /// Applies a bottom margin for showing tooltip on top of rods.
  final double tooltipMargin;

  /// Controls showing tooltip on left side, right side or center aligned with spot, default is center
  final FLHorizontalAlignment tooltipHorizontalAlignment;

  /// Applies horizontal offset for showing tooltip, default is zero.
  final double tooltipHorizontalOffset;

  /// Restricts the tooltip's width.
  final double maxContentWidth;

  /// Retrieves data for showing content inside the tooltip.
  final GetLineTooltipItems getTooltipItems;

  /// Forces the tooltip to shift horizontally inside the chart, if overflow happens.
  final bool fitInsideHorizontally;

  /// Forces the tooltip to shift vertically inside the chart, if overflow happens.
  final bool fitInsideVertically;

  /// Forces the tooltip container to top of the line, default 'false'
  final bool showOnTopOfTheChartBoxArea;

  /// Controls the rotation of the tooltip.
  final double rotateAngle;

  /// The tooltip border color.
  final BorderSide tooltipBorder;

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        tooltipBgColor,
        tooltipRoundedRadius,
        tooltipPadding,
        tooltipMargin,
        tooltipHorizontalAlignment,
        tooltipHorizontalOffset,
        maxContentWidth,
        getTooltipItems,
        fitInsideHorizontally,
        fitInsideVertically,
        showOnTopOfTheChartBoxArea,
        rotateAngle,
        tooltipBorder,
      ];
}

/// Provides a [LineTooltipItem] for showing content inside the [LineTouchTooltipData].
///
/// You can override [LineTouchTooltipData.getTooltipItems], it gives you
/// [touchedSpots] list that touch happened on,
/// then you should and pass your custom [LineTooltipItem] list
/// (length should be equal to the [touchedSpots.length]),
/// to show inside the tooltip popup.
typedef GetLineTooltipItems = List<LineTooltipItem?> Function(
  List<LineBarSpot> touchedSpots,
);

/// Default implementation for [LineTouchTooltipData.getTooltipItems].
List<LineTooltipItem> defaultLineTooltipItem(List<LineBarSpot> touchedSpots) {
  return touchedSpots.map((LineBarSpot touchedSpot) {
    final textStyle = TextStyle(
      color: touchedSpot.bar.gradient?.colors.first ??
          touchedSpot.bar.color ??
          Colors.blueGrey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    return LineTooltipItem(touchedSpot.y.toString(), textStyle);
  }).toList();
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
  )   : spotIndex = bar.spots.indexOf(spot),
        super(spot.x, spot.y);

  /// Is the [LineChartBarData] that this spot is inside of.
  final LineChartBarData bar;

  /// Is the index of our [bar], in the [LineChartData.lineBarsData] list,
  final int barIndex;

  /// Is the index of our [super.spot], in the [LineChartBarData.spots] list.
  final int spotIndex;

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        bar,
        barIndex,
        spotIndex,
        x,
        y,
      ];
}

/// A [LineBarSpot] that holds information about the event that selected it
class TouchLineBarSpot extends LineBarSpot {
  TouchLineBarSpot(
    super.bar,
    super.barIndex,
    super.spot,
    this.distance,
  );

  /// Distance in pixels from where the user taped
  final double distance;
}

/// Holds data of showing each row item in the tooltip popup.
class LineTooltipItem with EquatableMixin {
  /// Shows a [text] with [textStyle], [textDirection],
  /// and optional [children] as a row in the tooltip popup.
  const LineTooltipItem(
    this.text,
    this.textStyle, {
    this.textAlign = TextAlign.center,
    this.textDirection = TextDirection.ltr,
    this.children,
  });

  /// Showing text.
  final String text;

  /// Style of showing text.
  final TextStyle textStyle;

  /// Align of showing text.
  final TextAlign textAlign;

  /// Direction of showing text.
  final TextDirection textDirection;

  /// List<TextSpan> add further style and format to the text of the tooltip
  final List<TextSpan>? children;

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        text,
        textStyle,
        textAlign,
        textDirection,
        children,
      ];
}

/// details of showing indicator when touch happened on [LineChart]
/// [indicatorBelowLine] we draw a vertical line below of the touched spot
/// [touchedSpotDotData] we draw a larger dot on the touched spot to bold it
class TouchedSpotIndicatorData with EquatableMixin {
  /// if [LineTouchData.handleBuiltInTouches] is true,
  /// [LineChart] shows a thicker line and larger spot as indicator automatically when touch happens,
  /// otherwise you can show it manually using [LineChartBarData.showingIndicators].
  /// [indicatorBelowLine] determines line's style, and
  /// [touchedSpotDotData] determines dot's style.
  const TouchedSpotIndicatorData(
    this.indicatorBelowLine,
    this.touchedSpotDotData,
  );

  /// Determines line's style.
  final FlLine indicatorBelowLine;

  /// Determines dot's style.
  final FlDotData touchedSpotDotData;

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [
        indicatorBelowLine,
        touchedSpotDotData,
      ];
}

/// Holds data for showing tooltips over a line
class ShowingTooltipIndicators with EquatableMixin {
  /// [LineChart] shows some tooltips over each [LineChartBarData],
  /// and [showingSpots] determines in which spots this tooltip should be shown.
  const ShowingTooltipIndicators(this.showingSpots);

  /// Determines the spots that each tooltip should be shown.
  final List<LineBarSpot> showingSpots;

  /// Used for equality check, see [EquatableMixin].
  @override
  List<Object?> get props => [showingSpots];
}


/// It lerps a [LineChartData] to another [LineChartData] (handles animation for updating values)
class LineChartDataTween extends Tween<LineChartData> {
  LineChartDataTween({required super.begin, required super.end});

  /// Lerps a [LineChartData] based on [t] value, check [Tween.lerp].
  @override
  LineChartData lerp(double t) => begin!.lerp(begin!, end!, t);
}
