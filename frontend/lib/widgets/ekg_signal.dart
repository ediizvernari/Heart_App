import 'package:flutter/material.dart';
import 'package:frontend/core/theme/eck_painter.dart';

class EkgSignal extends StatelessWidget {
  final List<double> data;

  final double bottomOffset;

  final double height;

  final Color color;

  const EkgSignal({
    Key? key,
    required this.data,
    this.bottomOffset = 140,
    this.height = 60,
    this.color = const Color.fromRGBO(255, 255, 255, .3),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: bottomOffset,
      left: 0,
      right: 0,
      child: CustomPaint(
        size: Size(width, height),
        painter: EkgPainter(data, color: color),
      ),
    );
  }
}
