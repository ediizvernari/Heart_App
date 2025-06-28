import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

/// A radial gauge widget that displays the cardiovascular disease risk
/// threshold value with one decimal precision and clear color zones.
class ThresholdCvdGauge extends StatelessWidget {
  /// The raw percentage value (0–100) to display in the gauge.
  final double value;

  /// Lower limit of the yellow zone (percent).
  static const double _yellowThresholdStart = 45.0;

  /// Lower limit of the red zone (percent).
  static const double _redThresholdStart = 55.0;

  const ThresholdCvdGauge({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure the value stays within 0 and 100
    final double clampedValue = value.clamp(0.0, 100.0);

    // Determine pointer color based on thresholds
    final Color pointerColor;
    if (clampedValue < _yellowThresholdStart) {
      pointerColor = Colors.green;
    } else if (clampedValue < _redThresholdStart) {
      pointerColor = Colors.yellow;
    } else {
      pointerColor = Colors.red;
    }

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 100,
          interval: 10,
          showTicks: true,
          showLabels: true,
          axisLabelStyle: const GaugeTextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          minorTicksPerInterval: 0,
          showAxisLine: true,
          startAngle: 180,
          endAngle: 0,
          axisLineStyle: const AxisLineStyle(
            thickness: 0.15,
            thicknessUnit: GaugeSizeUnit.factor,
            color: Colors.white24,
            cornerStyle: CornerStyle.bothFlat,
          ),
          pointers: <GaugePointer>[
            RangePointer(
              value: clampedValue,
              color: pointerColor,
              width: 0.15,
              sizeUnit: GaugeSizeUnit.factor,
              cornerStyle: CornerStyle.bothFlat,
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(
                '${clampedValue.toStringAsFixed(1)}%',
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
