import 'dart:math' as math;
import 'package:flutter/material.dart';

class AisBeaconIcon extends StatelessWidget {
  final double size;
  final Color color;

  const AisBeaconIcon({
    super.key,
    this.size = 38,
    this.color = const Color(0xFF1B63C6),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AisBeaconPainter(color: color)),
    );
  }
}

class _AisBeaconPainter extends CustomPainter {
  final Color color;

  _AisBeaconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.8, w * 0.058)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Tọa độ đỉnh trạm phát sóng (beacon head)
    final beaconCenter = Offset(w * 0.5, h * 0.42);

    // 1. Sóng phát bên Trái ((
    canvas.drawArc(
      Rect.fromCircle(center: beaconCenter, radius: w * 0.28),
      math.pi * 0.72,
      math.pi * 0.56,
      false,
      strokePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: beaconCenter, radius: w * 0.44),
      math.pi * 0.72,
      math.pi * 0.56,
      false,
      strokePaint,
    );

    // 2. Sóng phát bên Phải ))
    canvas.drawArc(
      Rect.fromCircle(center: beaconCenter, radius: w * 0.28),
      -math.pi * 0.28,
      math.pi * 0.56,
      false,
      strokePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: beaconCenter, radius: w * 0.44),
      -math.pi * 0.28,
      math.pi * 0.56,
      false,
      strokePaint,
    );

    // 3. Đỉnh tháp phát sóng (hình tròn nhỏ)
    canvas.drawCircle(beaconCenter, w * 0.065, fillPaint);

    // 4. Chân tháp chữ A
    final towerPath = Path()
      ..moveTo(w * 0.33, h * 0.90)
      ..lineTo(w * 0.46, h * 0.50)
      ..lineTo(w * 0.54, h * 0.50)
      ..lineTo(w * 0.67, h * 0.90);
    canvas.drawPath(towerPath, strokePaint);

    // 5. Thanh ngang chữ A
    canvas.drawLine(
      Offset(w * 0.38, h * 0.72),
      Offset(w * 0.62, h * 0.72),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AisBeaconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
