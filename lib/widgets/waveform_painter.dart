import 'dart:math';
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final int barCount;
  final double barWidth;

  WaveformPainter({
    required this.animation,
    required this.color,
    this.barCount = 7,
    this.barWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;

    final spacing = barCount > 1
        ? (size.width - barCount * barWidth) / (barCount - 1)
        : 0.0;

    for (int i = 0; i < barCount; i++) {
      final phase = (animation.value * 2 * pi) + (i * pi / (barCount / 2));
      final barHeight =
          size.height * 0.25 + (sin(phase) * size.height * 0.35).abs();
      final x = i * (barWidth + spacing) + barWidth / 2;
      final top = (size.height - barHeight) / 2;

      canvas.drawLine(
        Offset(x, top),
        Offset(x, top + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter old) => true; 
}
