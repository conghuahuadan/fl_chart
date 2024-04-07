import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample0 extends StatefulWidget {
  const LineChartSample0({super.key});

  @override
  State<LineChartSample0> createState() => _LineChartSample0State();
}

class _LineChartSample0State extends State<LineChartSample0> {
  List<Color> gradientColors = [
    Color(0xFF50E4FF),
    Color(0xFF2196F3),
  ];

  bool showAvg = false;

  List<SpotMo> spots = [];
  List<double> array = [
    5942.0,
    5944.0,
    5938.0,
    5940.0,
    5940.0,
    5934.0,
    5938.0,
    5940.0,
    5938.0,
    5944.0,
    5940.0,
    5936.0,
    5936.0,
    5952.0,
    5946.0,
    5934.0,
    5922.0,
    5924.0,
    5932.0,
    5922.0,
    5932.0,
    5938.0,
    5942.0,
    5946.0,
    5948.0,
    5944.0,
    5942.0,
    5940.0,
    5946.0,
    5946.0
  ];

  @override
  void initState() {
    super.initState();

    spots.clear();
    for (int i = 0; i < array.length; i++) {
      double e = array[i];
      spots.add(SpotMo(i.toDouble(), e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(spots, Colors.green),
          ),
        ),
      ],
    );
  }
}
