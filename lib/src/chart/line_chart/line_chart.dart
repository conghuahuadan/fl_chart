import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_renderer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LineChart extends StatefulWidget {
  const LineChart(
    this.data, {
    this.chartRendererKey,
    super.key,
  });

  final LineChartData data;

  final Key? chartRendererKey;

  /// Creates a [_LineChartState]
  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  @override
  Widget build(BuildContext context) {
    final showingData = _getData();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffeeeeee)),
      ),
      child: LineChartLeaf(
        data: showingData,
      ),
    );
  }

  LineChartData _getData() {
    var newData = widget.data;
    return newData;
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {}
}
