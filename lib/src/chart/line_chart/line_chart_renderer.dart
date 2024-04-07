import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_painter.dart';
import 'package:fl_chart/src/utils/canvas_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LineChartLeaf extends LeafRenderObjectWidget {
  const LineChartLeaf({
    super.key,
    required this.spots,
    required this.color,
  });

  final List<SpotMo> spots;
  final Color color;

  @override
  RenderLineChart createRenderObject(BuildContext context) =>
      RenderLineChart(context,  spots, color);

}

class RenderLineChart extends RenderBox {
  RenderLineChart(
      BuildContext context, List<SpotMo> spots, Color color)
      : _buildContext = context,
        _spots = spots,
        _color = color;

  BuildContext _buildContext;

  List<SpotMo> _spots;
  Color _color;

  @visibleForTesting
  LineChartPainter painter = LineChartPainter();

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas
      ..save()
      ..translate(offset.dx, offset.dy);
    painter.paint(_buildContext, CanvasWrapper(canvas, size), _spots, _color);
    canvas.restore();
  }

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  bool hitTestSelf(Offset position) => true;
}
