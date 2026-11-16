import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import 'ais_beacon_icon.dart';
import '../../domain/entities/device_entity.dart';

/// Item hàng thiết bị hiển thị theo đúng chuẩn Mockup 3: Danh sách thiết bị
class DeviceListItem extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onTap;

  const DeviceListItem({super.key, required this.device, required this.onTap});

  Color _getStatusColor() {
    switch (device.status) {
      case DeviceStatus.online:
        return const Color(0xFF16A34A);
      case DeviceStatus.offline:
        return const Color(0xFFDC2626);
      case DeviceStatus.maintenance:
        return const Color(0xFFEA580C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      padding: EdgeInsets.all(8.w),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon trạm thu phát AIS dạng ((A)) theo đúng Mockup 3
                AisBeaconIcon(size: 38.r, color: const Color(0xFF1B63C6)),
                SizedBox(width: 14.w),
                // Thông tin trạm / thiết bị
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tên trạm / thiết bị (vd: AIS Device 001)
                      Text(
                        device.stationName,
                        style: AppTextStyles.titleMediumBlack(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      // Số IMEI
                      Text(
                        'IMEI: ${device.imei}',
                        style: AppTextStyles.bodySmall(
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      // Trạng thái kết nối (Dấu chấm tròn màu + tên trạng thái)
                      Row(
                        children: [
                          Container(
                            width: 6.5.r,
                            height: 6.5.r,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            device.status.label,
                            style: AppTextStyles.bodySmall(
                              color: statusColor,
                            ).copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Nút mũi tên chuyển sang màn hình Chi tiết thiết bị
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFFCBD5E1),
                  size: 24.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
