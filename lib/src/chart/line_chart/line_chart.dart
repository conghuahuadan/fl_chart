import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_renderer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LineChart extends StatefulWidget {
  const LineChart(
    this.spots,
    this.color, {
    this.chartRendererKey,
    super.key,
  });

  final Key? chartRendererKey;

  final List<FlSpot> spots;

  final Color color;

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffeeeeee)),
      ),
      child: LineChartLeaf(
        spots: widget.spots,
        color: widget.color,
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {}
}
