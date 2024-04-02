import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart' hide Image;


class CanvasWrapper {
  CanvasWrapper(
    this.canvas,
    this.size,
  );
  final Canvas canvas;
  final Size size;

  void save() => canvas.save();

  void restore() => canvas.restore();

  void drawPath(Path path, Paint paint) => canvas.drawPath(path, paint);

  void saveLayer(Rect bounds, Paint paint) => canvas.saveLayer(bounds, paint);

}
