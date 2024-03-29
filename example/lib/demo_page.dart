import 'package:fl_chart_app/line_chart_sample0.dart';
import 'package:flutter/widgets.dart';

class DemoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DemoPageState();
  }
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff272d42),
      child: const Center(
        child: LineChartSample0(),
      ),
    );
  }
}
