import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_scaffold_widget.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_helper.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_renderer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Renders a line chart as a widget, using provided [LineChartData].
class LineChart extends ImplicitlyAnimatedWidget {
  /// [data] determines how the [LineChart] should be look like,
  /// when you make any change in the [LineChartData], it updates
  /// new values with animation, and duration is [swapAnimationDuration].
  /// also you can change the [swapAnimationCurve]
  /// which default is [Curves.linear].
  const LineChart(
    this.data, {
    this.chartRendererKey,
    super.key,
    super.duration = const Duration(milliseconds: 150),
    super.curve = Curves.linear,
  });

  /// Determines how the [LineChart] should be look like.
  final LineChartData data;

  /// We pass this key to our renderers which are supposed to
  /// render the chart itself (without anything around the chart).
  final Key? chartRendererKey;

  /// Creates a [_LineChartState]
  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends AnimatedWidgetBaseState<LineChart> {
  /// we handle under the hood animations (implicit animations) via this tween,
  /// it lerps between the old [LineChartData] to the new one.
  LineChartDataTween? _lineChartDataTween;

  final Map<int, List<int>> _showingTouchedIndicators = {};

  final _lineChartHelper = LineChartHelper();

  @override
  Widget build(BuildContext context) {
    final showingData = _getData();

    return AxisChartScaffoldWidget(
      chart: LineChartLeaf(
        data: _withTouchedIndicators(_lineChartDataTween!.evaluate(animation)),
        targetData: _withTouchedIndicators(showingData),
        key: widget.chartRendererKey,
      ),
      data: showingData,
    );
  }

  LineChartData _withTouchedIndicators(LineChartData lineChartData) {

    return lineChartData.copyWith(
      lineBarsData: lineChartData.lineBarsData.map((barData) {
        final index = lineChartData.lineBarsData.indexOf(barData);
        return barData.copyWith(
          showingIndicators: _showingTouchedIndicators[index] ?? [],
        );
      }).toList(),
    );
  }

  LineChartData _getData() {
    var newData = widget.data;

    /// Calculate minX, maxX, minY, maxY for [LineChartData] if they are null,
    /// it is necessary to render the chart correctly.
    if (newData.minX.isNaN ||
        newData.maxX.isNaN ||
        newData.minY.isNaN ||
        newData.maxY.isNaN) {
      final values = _lineChartHelper.calculateMaxAxisValues(
        newData.lineBarsData,
      );
      newData = newData.copyWith(
        minX: newData.minX.isNaN ? values.minX : newData.minX,
        maxX: newData.maxX.isNaN ? values.maxX : newData.maxX,
        minY: newData.minY.isNaN ? values.minY : newData.minY,
        maxY: newData.maxY.isNaN ? values.maxY : newData.maxY,
      );
    }
    return newData;
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _lineChartDataTween = visitor(
      _lineChartDataTween,
      _getData(),
      (dynamic value) =>
          LineChartDataTween(begin: value as LineChartData, end: widget.data),
    ) as LineChartDataTween?;
  }
}
