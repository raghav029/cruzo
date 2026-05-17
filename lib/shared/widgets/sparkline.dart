import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double height;
  final double width;

  const Sparkline({
    super.key,
    required this.data,
    required this.color,
    this.height = 28,
    this.width = 120,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return SizedBox(height: height, width: width);
    return SizedBox(
      height: height,
      width: width == double.infinity ? null : width,
      child: CustomPaint(painter: _SparklinePainter(data: data, color: color)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  const _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double span = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);
    final int n = data.length;

    final points = List.generate(n, (i) {
      final x = (i / (n - 1)) * size.width;
      final y = size.height - ((data[i] - minVal) / span) * (size.height - 4) - 2;
      return Offset(x, y);
    });

    // fill path
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = color.withAlpha(41)); // 16% ≈ 41/255

    // stroke
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color;
}
