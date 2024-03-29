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

  List<FlSpot> spots = [];
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
      spots.add(FlSpot(i.toDouble(), e));
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
            child: LineChart(
              mainData(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const Text('MAR', style: style);
        break;
      case 5:
        text = const Text('JUN', style: style);
        break;
      case 8:
        text = const Text('SEP', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      titlesData: const FlTitlesData(
        show: false,
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: spots.length.toDouble()-1,
      minY: array.reduce((value, element) => value < element ? value : element),
      maxY: array.reduce((value, element) => value > element ? value : element),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
