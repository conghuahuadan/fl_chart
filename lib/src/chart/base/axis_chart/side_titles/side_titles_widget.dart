import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_helper.dart';
import 'package:fl_chart/src/chart/base/axis_chart/side_titles/side_titles_flex.dart';
import 'package:fl_chart/src/extensions/edge_insets_extension.dart';
import 'package:fl_chart/src/extensions/fl_border_data_extension.dart';
import 'package:fl_chart/src/extensions/fl_titles_data_extension.dart';
import 'package:fl_chart/src/utils/utils.dart';
import 'package:flutter/material.dart';

class SideTitlesWidget extends StatelessWidget {
  const SideTitlesWidget({
    super.key,
    required this.side,
    required this.axisChartData,
    required this.parentSize,
  });
  final AxisSide side;
  final AxisChartData axisChartData;
  final Size parentSize;

  bool get isHorizontal => side == AxisSide.top || side == AxisSide.bottom;

  bool get isVertical => !isHorizontal;

  double get minX => axisChartData.minX;

  double get maxX => axisChartData.maxX;

  double get baselineX => axisChartData.baselineX;

  double get minY => axisChartData.minY;

  double get maxY => axisChartData.maxY;

  double get baselineY => axisChartData.baselineY;

  double get axisMin => isHorizontal ? minX : minY;

  double get axisMax => isHorizontal ? maxX : maxY;

  double get axisBaseLine => isHorizontal ? baselineX : baselineY;

  bool get isLeftOrTop => side == AxisSide.left || side == AxisSide.top;

  bool get isRightOrBottom => side == AxisSide.right || side == AxisSide.bottom;

  Axis get direction => isHorizontal ? Axis.horizontal : Axis.vertical;

  Axis get counterDirection => isHorizontal ? Axis.vertical : Axis.horizontal;

  Alignment get alignment {
    switch (side) {
      case AxisSide.left:
        return Alignment.centerLeft;
      case AxisSide.top:
        return Alignment.topCenter;
      case AxisSide.right:
        return Alignment.centerRight;
      case AxisSide.bottom:
        return Alignment.bottomCenter;
    }
  }

  EdgeInsets get thisSidePadding {
    return EdgeInsets.all(0);
  }

  double get thisSidePaddingTotal {
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final axisViewSize = isHorizontal ? parentSize.width : parentSize.height;
    return Align(
      alignment: alignment,
      child: Flex(
        direction: counterDirection,
        mainAxisSize: MainAxisSize.min,
        children: [

        ],
      ),
    );
  }
}

class _AxisTitleWidget extends StatelessWidget {
  const _AxisTitleWidget({
    required this.axisTitles,
    required this.side,
    required this.axisViewSize,
  });
  final AxisTitles axisTitles;
  final AxisSide side;
  final double axisViewSize;

  int get axisNameQuarterTurns {
    switch (side) {
      case AxisSide.right:
        return 3;
      case AxisSide.left:
        return 3;
      case AxisSide.top:
        return 0;
      case AxisSide.bottom:
        return 0;
    }
  }

  bool get isHorizontal => side == AxisSide.top || side == AxisSide.bottom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isHorizontal ? axisViewSize : axisTitles.axisNameSize,
      height: isHorizontal ? axisTitles.axisNameSize : axisViewSize,
      child: Center(
        child: RotatedBox(
          quarterTurns: axisNameQuarterTurns,
          child: axisTitles.axisNameWidget,
        ),
      ),
    );
  }
}
