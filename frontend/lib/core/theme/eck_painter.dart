import 'package:flutter/material.dart';

class EkgPainter extends CustomPainter {
  final List<double> data;
  final Color color;


  EkgPainter(this.data, {this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = (0.3 * 0xFF).round();
    final paint = Paint()
      ..color = color.withAlpha(alpha)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final dx = size.width / (data.length - 1);
    path.moveTo(0, size.height / 2 - data[0] * 20);

    for (var i = 1; i < data.length; i++) {
      path.lineTo(i * dx, size.height / 2 - data[i] * 20);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant EkgPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
