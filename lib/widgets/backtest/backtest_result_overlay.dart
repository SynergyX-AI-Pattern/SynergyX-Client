import 'dart:math' as math;
import 'package:flutter/material.dart';

class BacktestresultOverlay extends CustomPainter {
  final int start;
  final int end;
  final int total;
  final List<int> patternPoints;

  const BacktestresultOverlay({
    required this.start,
    required this.end,
    required this.total,
    required this.patternPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0 || end < start) return;

    final double candleWidth = size.width / total;
    final Rect highlightRect = Rect.fromLTWH(
      start * candleWidth,
      0,
      (end - start + 1) * candleWidth,
      size.height,
    );

    final Paint fill = Paint()
      ..color = Colors.amber.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(highlightRect, fill);

    final Paint border = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(highlightRect, border);

    if (patternPoints.length >= 2) {
      final double minY = patternPoints.reduce(math.min).toDouble();
      final double maxY = patternPoints.reduce(math.max).toDouble();
      final double diffY = (maxY - minY == 0) ? 1 : maxY - minY;

      final Path path = Path();
      for (int i = 0; i < patternPoints.length; i++) {
        final double x =
            highlightRect.left + (i / (patternPoints.length - 1)) * highlightRect.width;
        final double normY = (patternPoints[i] - minY) / diffY;
        final double y = highlightRect.bottom - normY * highlightRect.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final Paint line = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(covariant BacktestresultOverlay oldDelegate) {
    return start != oldDelegate.start ||
        end != oldDelegate.end ||
        total != oldDelegate.total ||
        patternPoints != oldDelegate.patternPoints;
  }
}