import 'dart:ui';

import 'package:flutter/material.dart';

class KlineTrendChart extends StatefulWidget {
  const KlineTrendChart(
    this.spots,
    this.color, {
    this.chartRendererKey,
    super.key,
  });

  final Key? chartRendererKey;

  final List<SpotMo> spots;

  final Color color;

  @override
  _KlineTrendChartState createState() => _KlineTrendChartState();
}

class _KlineTrendChartState extends State<KlineTrendChart> {
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
}

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
      RenderLineChart(context, spots, color);
}

class RenderLineChart extends RenderBox {
  RenderLineChart(BuildContext context, List<SpotMo> spots, Color color)
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
    painter.paint(_buildContext, canvas, size, _spots, _color);
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

class LineChartPainter {
  LineChartPainter() : super() {
    _barPaint = Paint()..style = PaintingStyle.stroke;

    _barAreaPaint = Paint()..style = PaintingStyle.fill;

    _linePaint = Paint()..style = PaintingStyle.stroke;

    dashPainter = const DashPainter(step: 6, span: 3);
  }

  late Paint _linePaint;
  late Paint _barPaint;
  late Paint _barAreaPaint;

  Path linePath = Path();
  late DashPainter dashPainter;

  double minX = 0;
  double maxX = 0;
  double minY = 0;
  double maxY = 0;

  List<SpotMo> spots = [];

  Color color = Colors.transparent;

  Size size = const Size(0, 0);

  void paint(BuildContext context, Canvas canvas, Size size, List<SpotMo> spots,
      Color color) {
    this.spots = spots;
    this.color = color;
    this.size = size;

    minX = 0;
    maxX = spots.length.toDouble() - 1;
    if (spots.isNotEmpty) {
      minY = spots[0].y;
      maxY = spots[0].y;
      for (final spot in spots) {
        if (minY > spot.y) {
          minY = spot.y < minY ? spot.y : minY;
        }
        if (maxY < spot.y) {
          maxY = spot.y > maxY ? spot.y : maxY;
        }
      }
    }

    drawBarLine(canvas, size);
  }

  @visibleForTesting
  void drawBarLine(
    Canvas canvas,
    Size size,
  ) {
    final viewSize = size;

    final barPath = generateBarPath(viewSize, spots);

    final belowBarPath = generateBelowBarPath(viewSize, barPath, spots);

    drawBelowBar(
      canvas,
      size,
      belowBarPath,
    );
    drawBar(canvas, size, barPath);

    final double y = getPixelY(spots[spots.length - 1].y, viewSize);

    linePath
      ..moveTo(0, y)
      ..lineTo(viewSize.width, y);

    _linePaint
      ..strokeWidth = 0.3
      ..color = Color(0x80000000);
    dashPainter.paint(canvas, linePath, _linePaint);
  }

  @visibleForTesting
  Path generateBarPath(
    Size viewSize,
    List<SpotMo> barSpots,
  ) {
    return generateNormalBarPath(
      viewSize,
      barSpots,
    );
  }

  @visibleForTesting
  Path generateNormalBarPath(
    Size viewSize,
    List<SpotMo> barSpots,
  ) {
    final path = Path();
    final size = barSpots.length;

    var temp = Offset.zero;

    final x = getPixelX(barSpots[0].x, viewSize);
    final y = getPixelY(barSpots[0].y, viewSize);
    path.moveTo(x, y);
    if (size == 1) {
      path.lineTo(x, y);
    }
    for (var i = 1; i < size; i++) {
      final current = Offset(
        getPixelX(barSpots[i].x, viewSize),
        getPixelY(barSpots[i].y, viewSize),
      );

      final previous = Offset(
        getPixelX(barSpots[i - 1].x, viewSize),
        getPixelY(barSpots[i - 1].y, viewSize),
      );

      final next = Offset(
        getPixelX(barSpots[i + 1 < size ? i + 1 : i].x, viewSize),
        getPixelY(barSpots[i + 1 < size ? i + 1 : i].y, viewSize),
      );

      final controlPoint1 = previous + temp;

      const smoothness = 0.0;
      temp = ((next - previous) / 2) * smoothness;

      final controlPoint2 = current - temp;

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        current.dx,
        current.dy,
      );
    }

    return path;
  }

  @visibleForTesting
  Path generateBelowBarPath(
    Size viewSize,
    Path barPath,
    List<SpotMo> barSpots,
  ) {
    final belowBarPath = Path.from(barPath);

    var x = getPixelX(barSpots[barSpots.length - 1].x, viewSize);
    double y;
    y = getPixelY(0, viewSize);

    belowBarPath.lineTo(x, y);

    y = getPixelY(0, viewSize);
    belowBarPath.lineTo(x, y);

    x = getPixelX(barSpots[0].x, viewSize);
    y = getPixelY(barSpots[0].y, viewSize);
    belowBarPath
      ..lineTo(x, y)
      ..close();

    return belowBarPath;
  }

  @visibleForTesting
  Path generateAboveBarPath(
      Size viewSize, Path barPath, List<SpotMo> barSpots) {
    final aboveBarPath = Path.from(barPath);

    var x = getPixelX(barSpots[barSpots.length - 1].x, viewSize);
    double y;
    y = 0.0;

    aboveBarPath.lineTo(x, y);

    x = getPixelX(barSpots[0].x, viewSize);
    y = 0.0;

    aboveBarPath.lineTo(x, y);

    x = getPixelX(barSpots[0].x, viewSize);
    y = getPixelY(barSpots[0].y, viewSize);
    aboveBarPath
      ..lineTo(x, y)
      ..close();

    return aboveBarPath;
  }

  @visibleForTesting
  void drawBelowBar(
    Canvas canvas,
    Size size,
    Path belowBarPath,
  ) {
    final viewSize = size;

    final belowBarLargestRect = Rect.fromLTRB(
      0,
      0,
      viewSize.width,
      viewSize.height,
    );

    _barAreaPaint.setColorOrGradient(
      color.withOpacity(0.12),
      LinearGradient(
        colors: [
          color.withOpacity(0.12),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      belowBarLargestRect,
    );

    canvas.drawPath(belowBarPath, _barAreaPaint);
  }

  @visibleForTesting
  void drawBar(
    Canvas canvas,
    Size size,
    Path barPath,
  ) {
    _barPaint
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color
      ..maskFilter = null
      ..strokeWidth = 1
      ..transparentIfWidthIsZero();

    canvas.drawPath(barPath, _barPaint);
  }

  double getPixelX(double spotX, Size viewSize) {
    final deltaX = maxX - minX;
    if (deltaX == 0.0) {
      return 0;
    }
    return ((spotX - minX) / deltaX) * viewSize.width;
  }

  double getPixelY(double spotY, Size viewSize) {
    final deltaY = maxY - minY;
    if (deltaY == 0.0) {
      return viewSize.height;
    }
    return viewSize.height - (((spotY - minY) / deltaY) * viewSize.height);
  }
}

extension PaintExtension on Paint {
  void transparentIfWidthIsZero() {
    if (strokeWidth == 0) {
      shader = null;
      color = color.withOpacity(0);
    }
  }

  void setColorOrGradient(Color? color, Gradient? gradient, Rect rect) {
    if (gradient != null) {
      this.color = Colors.black;
      shader = gradient.createShader(rect);
    } else {
      this.color = color ?? Colors.transparent;
      shader = null;
    }
  }
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

class DashPainter {
  const DashPainter({
    this.step = 2,
    this.span = 2,
  });

  final double step;
  final double span;

  double get partLength => step + span;

  void paint(Canvas canvas, Path path, Paint paint) {
    PathMetrics pms = path.computeMetrics();
    for (final pm in pms) {
      final count = pm.length ~/ partLength;
      for (var i = 0; i < count; i++) {
        canvas.drawPath(
          pm.extractPath(partLength * i, partLength * i + step),
          paint,
        );
      }
      final tail = pm.length % partLength;
      canvas.drawPath(pm.extractPath(pm.length - tail, pm.length), paint);
      // print("pms: ${pms.length}, ${pm.length}");
    }
  }
}