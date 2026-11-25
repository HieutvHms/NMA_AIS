import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../domain/entities/ais_target_entity.dart';
import '../../domain/entities/ais_type_mapper.dart';

/// Bottom Sheet hiển thị thông tin chi tiết khi người dùng chạm vào một marker trên bản đồ.
class AisTargetDetailSheet extends StatelessWidget {
  final AisTargetEntity target;
  final VoidCallback onCenterCamera;
  final VoidCallback? onClose;

  const AisTargetDetailSheet({
    super.key,
    required this.target,
    required this.onCenterCamera,
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required AisTargetEntity target,
    required VoidCallback onCenterCamera,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AisTargetDetailSheet(target: target, onCenterCamera: onCenterCamera),
    );
  }

  void _handleClose(BuildContext context) {
    if (onClose != null) {
      onClose!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStation = target.isStationOrAton;
    final badgeColor = isStation ? const Color(0xFF0F766E) : AppColors.primary;
    final badgeBg = isStation
        ? const Color(0xFFCCFBF1)
        : AppColors.primaryLight;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 250) {
          _handleClose(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 16.r,
              offset: Offset(0, -4.h),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.borderDark,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: SvgPicture.asset(
                      isStation
                          ? 'assets/icons/tram_thu.svg'
                          : 'assets/icons/ship.svg',
                      width: 32.r,
                      height: 32.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MMSI: ${target.mmsi}',
                          style: AppTextStyles.s16w600(
                            color: AppColors.textPrimary,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 3.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            AisTypeMapper.detailLabel(target.type),
                            style: AppTextStyles.s11w600(color: badgeColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _handleClose(context),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 22.r,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              const Divider(height: 1, color: AppColors.divider),
              SizedBox(height: 8.h),
              _InfoRow(
                icon: Icons.tag_rounded,
                label: 'Mã MMSI',
                value: target.mmsi,
              ),
              _InfoRow(
                icon: Icons.category_outlined,
                label: 'Loại bản tin (Type)',
                value: AisTypeMapper.detailLabel(target.type),
              ),
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Tọa độ (Lat, Lng)',
                value:
                    '${target.latitude.toStringAsFixed(6)}, ${target.longitude.toStringAsFixed(6)}',
              ),
              _InfoRow(
                icon: Icons.access_time_rounded,
                label: 'Cập nhật cuối',
                value: target.formattedTime,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 18.r, color: AppColors.primary),
          SizedBox(width: 10.w),
          Text(
            label,
            style: AppTextStyles.s13w500(color: AppColors.textSecondary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.s13w600(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
