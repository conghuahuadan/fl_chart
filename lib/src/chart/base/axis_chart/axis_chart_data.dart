
class FlSpot {

  const FlSpot(this.x, this.y);

  final double x;
  final double y;

  @override
  String toString() => '($x, $y)';

  static const FlSpot nullSpot = FlSpot(double.nan, double.nan);

  static const FlSpot zero = FlSpot(0, 0);

  bool isNull() => this == nullSpot;

  bool isNotNull() => !isNull();
}
