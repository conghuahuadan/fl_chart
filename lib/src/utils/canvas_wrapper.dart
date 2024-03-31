import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart' hide Image;

typedef DrawCallback = void Function();

/// Proxies Canvas functions
///
/// We wrapped the canvas here, because we needed to write tests for our drawing system.
/// Now in tests we can verify that these functions called with a specific value.
class CanvasWrapper {
  CanvasWrapper(
    this.canvas,
    this.size,
  );
  final Canvas canvas;
  final Size size;

  /// Directly calls [Canvas.save]
  void save() => canvas.save();

  /// Directly calls [Canvas.restore]
  void restore() => canvas.restore();

  /// Directly calls [Canvas.drawPath]
  void drawPath(Path path, Paint paint) => canvas.drawPath(path, paint);

  /// Directly calls [Canvas.saveLayer]
  void saveLayer(Rect bounds, Paint paint) => canvas.saveLayer(bounds, paint);

}
