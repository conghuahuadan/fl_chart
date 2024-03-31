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


/// Lerps [LineChartBarData] list based on [t] value, check [Tween.lerp].
List<LineChartBarData>? lerpLineChartBarDataList(
  List<LineChartBarData>? a,
  List<LineChartBarData>? b,
  double t,
) =>
    lerpList(a, b, t, lerp: LineChartBarData.lerp);

