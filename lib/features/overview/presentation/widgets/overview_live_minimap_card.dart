import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../../monitoring/domain/entities/ais_target_entity.dart';

/// Khối "Vị trí trực tiếp" hiển thị Minimap nhẹ vẽ bằng CustomPainter
/// (không tạo thêm GoogleMap PlatformView thứ 2), bấm vào chuyển sang tab Giám sát.
class OverviewLiveMinimapCard extends StatelessWidget {
  final List<AisTargetEntity> targets;
  final VoidCallback onOpenMapTap;

  const OverviewLiveMinimapCard({
    super.key,
    required this.targets,
    required this.onOpenMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        child: InkWell(
          onTap: onOpenMapTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 12.w, 10.h),
                child: Row(
                  children: [
                    Text(
                      'Vị trí trực tiếp',
                      style: AppTextStyles.s14w600(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Xem bản đồ',
                          style: AppTextStyles.s13w600(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18.r,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(17.r),
                ),
                child: SizedBox(
                  height: 152.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: _MaritimeMinimapPainter(targets: targets),
                      ),
                      Positioned(
                        left: 10.w,
                        bottom: 10.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 6.r,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7.r,
                                height: 7.r,
                                decoration: const BoxDecoration(
                                  color: AppColors.online,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                targets.isEmpty
                                    ? 'Chạm để mở bản đồ AIS'
                                    : '${targets.length} mục tiêu trên bản đồ',
                                style: AppTextStyles.s11w600(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaritimeMinimapPainter extends CustomPainter {
  final List<AisTargetEntity> targets;

  const _MaritimeMinimapPainter({required this.targets});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Nền biển xanh dịu
    final seaPaint = Paint()..color = const Color(0xFFC5E5F5);
    canvas.drawRect(Offset.zero & size, seaPaint);

    // 2. Đường lưới kinh vĩ tuyến mờ
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;
    for (int i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (int i = 1; i <= 4; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 3. Dải đất liền ven biển phía bên trái (hình khối mềm giống bản đồ)
    final landPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.28, 0)
      ..quadraticBezierTo(
        size.width * 0.24,
        size.height * 0.28,
        size.width * 0.30,
        size.height * 0.54,
      )
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.78,
        size.width * 0.24,
        size.height,
      )
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(landPath, Paint()..color = const Color(0xFFDCE9D5));
    canvas.drawPath(
      landPath,
      Paint()
        ..color = const Color(0xFFB7CFAF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // 4. Vẽ các chấm mục tiêu thật từ /ais/data vào vùng biển
    if (targets.isEmpty) return;

    final sampled = targets.length > 45 ? targets.sublist(0, 45) : targets;
    double minLat = sampled.first.latitude;
    double maxLat = sampled.first.latitude;
    double minLng = sampled.first.longitude;
    double maxLng = sampled.first.longitude;

    for (final t in sampled) {
      minLat = math.min(minLat, t.latitude);
      maxLat = math.max(maxLat, t.latitude);
      minLng = math.min(minLng, t.longitude);
      maxLng = math.max(maxLng, t.longitude);
    }

    final latSpan = math.max(maxLat - minLat, 0.02);
    final lngSpan = math.max(maxLng - minLng, 0.02);

    // Vùng vẽ nằm trọn bên phần biển (x: 34%..92%, y: 14%..78%)
    final plotLeft = size.width * 0.35;
    final plotWidth = size.width * 0.56;
    final plotTop = size.height * 0.14;
    final plotHeight = size.height * 0.62;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    final vesselFill = Paint()..color = AppColors.primary;
    final atonFill = Paint()..color = AppColors.error;

    for (final target in sampled) {
      final normX = ((target.longitude - minLng) / lngSpan).clamp(0.0, 1.0);
      final normY =
          1.0 - ((target.latitude - minLat) / latSpan).clamp(0.0, 1.0);

      final cx = plotLeft + normX * plotWidth;
      final cy = plotTop + normY * plotHeight;

      if (target.isStationOrAton) {
        // Phao / Đèn biển: chấm tròn đỏ có viền trắng
        canvas.drawCircle(Offset(cx, cy), 5.2, atonFill);
        canvas.drawCircle(Offset(cx, cy), 5.2, borderPaint);
      } else {
        // Tàu thuyền: tam giác xanh có viền trắng
        const r = 6.5;
        final tri = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx - r * 0.82, cy + r * 0.72)
          ..lineTo(cx + r * 0.82, cy + r * 0.72)
          ..close();
        canvas.drawPath(tri, vesselFill);
        canvas.drawPath(tri, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MaritimeMinimapPainter oldDelegate) {
    return oldDelegate.targets != targets;
  }
}
