import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/device_entity.dart';

class DeviceDetailHeaderCard extends StatelessWidget {
  final DeviceEntity device;
  final String formattedTime;

  const DeviceDetailHeaderCard({
    super.key,
    required this.device,
    required this.formattedTime,
  });

  Color _getStatusColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return const Color(0xFF15803D);
      case DeviceStatus.offline:
        return const Color(0xFFDC2626);
      case DeviceStatus.unknown:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(device.status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textBlack.withValues(alpha: 0.15),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/icons/device/ic_station.svg',
            width: 36.r,
            height: 36.r,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        device.stationName,
                        style: AppTextStyles.s15w600(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        device.status.label,
                        style: AppTextStyles.s13w500(color: statusColor),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'IMEI: ${device.imei}',
                  style: AppTextStyles.s13w500(color: AppColors.textSecondary),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Cập nhật: $formattedTime',
                  style: AppTextStyles.s13w500(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
