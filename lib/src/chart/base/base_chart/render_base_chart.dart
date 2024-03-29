// coverage:ignore-file
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// It implements shared logics between our renderers such as touch/pointer events recognition, size, layout, ...
abstract class RenderBaseChart extends RenderBox {
  /// We use [FlTouchData] to retrieve [FlTouchData.touchCallback] and [FlTouchData.mouseCursorResolver]
  /// to invoke them when touch happens.
  RenderBaseChart(BuildContext context)
      : _buildContext = context {
  }

  // We use buildContext to retrieve Theme data
  BuildContext get buildContext => _buildContext;
  BuildContext _buildContext;
  set buildContext(BuildContext value) {
    _buildContext = value;
    markNeedsPaint();
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
