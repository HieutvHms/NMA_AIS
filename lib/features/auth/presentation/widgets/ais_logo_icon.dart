import 'dart:math' as math;
import 'package:flutter/material.dart';

class AisLogoIcon extends StatelessWidget {
  final double size;
  final Color color;

  const AisLogoIcon({
    super.key,
    this.size = 68,
    this.color = const Color(0xFF1E5BB0),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AisBeaconPainter(color: color),
      ),
    );
  }
}

class _AisBeaconPainter extends CustomPainter {
  final Color color;

  _AisBeaconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.5, size.height * 0.44);

    // Vòng sóng ngoài
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.40),
      math.pi * 0.80,
      math.pi * 1.40,
      false,
      strokePaint,
    );

    // Vòng sóng trong
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.26),
      math.pi * 0.82,
      math.pi * 1.36,
      false,
      strokePaint,
    );

    // Đỉnh phát sóng trung tâm
    canvas.drawCircle(center, size.width * 0.06, fillPaint);

    // Chân tháp chữ A của trạm/phao AIS
    final towerPath = Path()
      ..moveTo(size.width * 0.33, size.height * 0.88)
      ..lineTo(size.width * 0.45, size.height * 0.52)
      ..lineTo(size.width * 0.55, size.height * 0.52)
      ..lineTo(size.width * 0.67, size.height * 0.88);
    canvas.drawPath(towerPath, strokePaint);

    // Thanh ngang chữ A
    canvas.drawLine(
      Offset(size.width * 0.39, size.height * 0.70),
      Offset(size.width * 0.61, size.height * 0.70),
      strokePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.82),
      Offset(size.width * 0.65, size.height * 0.82),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AisBeaconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}