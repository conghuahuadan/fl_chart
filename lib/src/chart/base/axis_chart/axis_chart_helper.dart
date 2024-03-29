import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/utils/utils.dart';
import 'package:flutter/material.dart';

class AxisChartHelper {
  factory AxisChartHelper() {
    return _singleton;
  }

  AxisChartHelper._internal();
  static final _singleton = AxisChartHelper._internal();

}
