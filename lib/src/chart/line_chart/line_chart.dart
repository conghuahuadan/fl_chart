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

  final List<SpotMo> spots;

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

class SpotMo {

  const SpotMo(this.x, this.y);

  final double x;
  final double y;

  @override
  String toString() => '($x, $y)';

  static const SpotMo nullSpot = SpotMo(double.nan, double.nan);

  static const SpotMo zero = SpotMo(0, 0);

  bool isNull() => this == nullSpot;

  bool isNotNull() => !isNull();
}