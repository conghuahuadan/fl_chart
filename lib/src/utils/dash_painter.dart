
import 'dart:ui';

class DashPainter {

  const DashPainter({this.step = 2, this.span = 2,});
  final double step;
  final double span;

  double get partLength => step + span;

  void paint(Canvas canvas, Path path, Paint paint) {
    final pms = path.computeMetrics();
    for (final pm in pms) {
      final count = pm.length ~/ partLength;
      for (var i = 0; i < count; i++) {
        canvas.drawPath(
            pm.extractPath(partLength * i, partLength * i + step), paint,);
      }
      final tail = pm.length % partLength;
      canvas.drawPath(pm.extractPath(pm.length-tail, pm.length), paint);
    }
  }
}