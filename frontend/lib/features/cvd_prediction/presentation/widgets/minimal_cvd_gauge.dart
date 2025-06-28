import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class CvdRiskGauge extends StatelessWidget {
  final double value;
  final List<Color> zoneColors;
  static const double _greenToYellow = 45.0;
  static const double _yellowToRed = 55.0;
  static const double _zoneThickness = 15.0;

  const CvdRiskGauge({
    Key? key,
    required this.value,
    this.zoneColors = const [
      Color(0xFF4CAF50),
      Color(0xFFFFC107),
      Color(0xFFF44336),
    ],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double clamped = value.clamp(0.0, 100.0);

    return SfRadialGauge(
      axes: [
        RadialAxis(
          minimum: 0,
          maximum: 100,
          startAngle: 180,
          endAngle: 0,
          showAxisLine: false,
          showTicks: true,
          showLabels: true,
          interval: 10,
          minorTicksPerInterval: 4,
          axisLabelStyle: const GaugeTextStyle(
            color: Colors.white,
            fontSize: 12,
          ),

          ranges: [
            GaugeRange(
              startValue: 0,
              endValue: 100,
              startWidth: _zoneThickness,
              endWidth: _zoneThickness,
              gradient: SweepGradient(
                colors: zoneColors,
                stops: const [
                  0.0,
                  _greenToYellow / 100,
                  _yellowToRed  / 100,
                ],
              ),
            ),
          ],

          pointers: [
            MarkerPointer(
              value: clamped,
              markerType: MarkerType.triangle,
              color: Colors.white,
              markerHeight: 16,
              markerWidth: 12,
            ),
          ],

          annotations: [
            GaugeAnnotation(
              widget: Text(
                '${clamped.toStringAsFixed(1)}%',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.white),
              ),
              positionFactor: 0.1,
              angle: 90,
            ),
          ],
        ),
      ],
    );
  }
}