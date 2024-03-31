import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';

/// Holds minX, maxX, minY, and maxY for use in [LineChartData]
class LineChartMinMaxAxisValues with EquatableMixin {
  const LineChartMinMaxAxisValues(
    this.minX,
    this.maxX,
    this.minY,
    this.maxY, {
    this.readFromCache = false,
  });
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final bool readFromCache;

  @override
  List<Object?> get props => [minX, maxX, minY, maxY, readFromCache];

  LineChartMinMaxAxisValues copyWith({
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
    bool? readFromCache,
  }) {
    return LineChartMinMaxAxisValues(
      minX ?? this.minX,
      maxX ?? this.maxX,
      minY ?? this.minY,
      maxY ?? this.maxY,
      readFromCache: readFromCache ?? this.readFromCache,
    );
  }
}
