import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

@visibleForTesting
List<T>? lerpList<T>(
  List<T>? a,
  List<T>? b,
  double t, {
  required T Function(T, T, double) lerp,
}) {
  if (a != null && b != null && a.length == b.length) {
    return List.generate(a.length, (i) {
      return lerp(a[i], b[i], t);
    });
  } else if (a != null && b != null) {
    return List.generate(b.length, (i) {
      return lerp(i >= a.length ? b[i] : a[i], b[i], t);
    });
  } else {
    return b;
  }
}


/// Lerps [int] list based on [t] value, check [Tween.lerp].
List<int>? lerpIntList(List<int>? a, List<int>? b, double t) =>
    lerpList(a, b, t, lerp: lerpInt);

/// Lerps [int] list based on [t] value, check [Tween.lerp].
int lerpInt(int a, int b, double t) => (a + (b - a) * t).round();


/// Lerps [FlSpot] list based on [t] value, check [Tween.lerp].
List<FlSpot>? lerpFlSpotList(List<FlSpot>? a, List<FlSpot>? b, double t) =>
    lerpList(a, b, t, lerp: FlSpot.lerp);

/// Lerps [HorizontalLine] list based on [t] value, check [Tween.lerp].
List<HorizontalLine>? lerpHorizontalLineList(
  List<HorizontalLine>? a,
  List<HorizontalLine>? b,
  double t,
) =>
    lerpList(a, b, t, lerp: HorizontalLine.lerp);

/// Lerps [VerticalLine] list based on [t] value, check [Tween.lerp].
List<VerticalLine>? lerpVerticalLineList(
  List<VerticalLine>? a,
  List<VerticalLine>? b,
  double t,
) =>
    lerpList(a, b, t, lerp: VerticalLine.lerp);

/// Lerps [HorizontalRangeAnnotation] list based on [t] value, check [Tween.lerp].
List<HorizontalRangeAnnotation>? lerpHorizontalRangeAnnotationList(
  List<HorizontalRangeAnnotation>? a,
  List<HorizontalRangeAnnotation>? b,
  double t,
) =>
    lerpList(a, b, t, lerp: HorizontalRangeAnnotation.lerp);

/// Lerps [VerticalRangeAnnotation] list based on [t] value, check [Tween.lerp].
List<VerticalRangeAnnotation>? lerpVerticalRangeAnnotationList(
  List<VerticalRangeAnnotation>? a,
  List<VerticalRangeAnnotation>? b,
  double t,
) =>
    lerpList(a, b, t, lerp: VerticalRangeAnnotation.lerp);

/// Lerps [LineChartBarData] list based on [t] value, check [Tween.lerp].
List<LineChartBarData>? lerpLineChartBarDataList(
  List<LineChartBarData>? a,
  List<LineChartBarData>? b,
  double t,
) =>
    lerpList(a, b, t, lerp: LineChartBarData.lerp);

/// Lerps [BetweenBarsData] list based on [t] value, check [Tween.lerp].
List<BetweenBarsData>? lerpBetweenBarsDataList(
  List<BetweenBarsData>? a,
  List<BetweenBarsData>? b,
  double t,
) =>
    lerpList(a, b, t, lerp: BetweenBarsData.lerp);


/// Lerps between a [LinearGradient] colors, based on [t]
Color lerpGradient(List<Color> colors, List<double> stops, double t) {
  final length = colors.length;
  if (stops.length != length) {
    /// provided gradientColorStops is invalid and we calculate it here
    stops = List.generate(length, (i) => (i + 1) / length);
  }

  for (var s = 0; s < stops.length - 1; s++) {
    final leftStop = stops[s];
    final rightStop = stops[s + 1];

    final leftColor = colors[s];
    final rightColor = colors[s + 1];

    if (t <= leftStop) {
      return leftColor;
    } else if (t < rightStop) {
      final sectionT = (t - leftStop) / (rightStop - leftStop);
      return Color.lerp(leftColor, rightColor, sectionT)!;
    }
  }
  return colors.last;
}
