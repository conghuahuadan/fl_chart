import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AxisChartScaffoldWidget extends StatelessWidget {
  const AxisChartScaffoldWidget({
    super.key,
    required this.chart,
    required this.data,
  });
  final Widget chart;
  final AxisChartData data;
  List<Widget> stackWidgets(BoxConstraints constraints) {
    final widgets = <Widget>[
      Container(
        decoration: BoxDecoration(
          border: data.borderData.isVisible() ? data.borderData.border : null,
        ),
        child: chart,
      ),
    ];
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(children: stackWidgets(constraints));
      },
    );
  }
}
