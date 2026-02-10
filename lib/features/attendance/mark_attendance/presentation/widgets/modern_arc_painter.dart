import 'dart:math' as math;
import 'package:flutter/material.dart';

class ModernArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  ModernArcPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final rect = Rect.fromCircle(center: center, radius: size.width / 2);

    final basePaint = Paint()
      ..color = Colors.grey.withOpacity(.15)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, math.pi, math.pi, false, basePaint);

    final progressPaint = Paint()
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawArc(
      rect,
      math.pi,
      math.pi * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ModernArcPainter old) =>
      old.progress != progress;
}
