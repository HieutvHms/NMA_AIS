import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/device_entity.dart';

class DeviceListItem extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onTap;

  const DeviceListItem({super.key, required this.device, required this.onTap});

  Color _getStatusColor() {
    switch (device.status) {
      case DeviceStatus.online:
        return const Color(0xFF15803D);
      case DeviceStatus.offline:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final radius = BorderRadius.circular(16.r);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: const Color.fromARGB(255, 198, 204, 211),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D3B7A).withValues(alpha: 0.15),
            blurRadius: 6.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: const Color(0xFF1565C0).withValues(alpha: 0.08),
          highlightColor: const Color(0xFF1565C0).withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/device/ic_station.svg',
                  width: 36.r,
                  height: 36.r,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1565C0),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Hàng tiêu đề gồm: Tên thiết bị (chữ chính navy #0F2A4A) + Trạng thái
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.stationName,
                              style: AppTextStyles.s16w600(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7.r,
                                height: 7.r,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                device.status.label,
                                style: AppTextStyles.s14w500(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      // Số IMEI (chữ phụ xám xanh #5B6B82)
                      Text(
                        'IMEI: ${device.imei}',
                        style: AppTextStyles.s14w400(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                // Icon chevron nhỏ để gợi ý xem chi tiết
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 20.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
