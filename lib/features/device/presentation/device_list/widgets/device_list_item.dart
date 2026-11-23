import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../../../app/theme/app_colors.dart';

import '../../../domain/entities/device_entity.dart';

class DeviceListItem extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onTap;

  const DeviceListItem({super.key, required this.device, required this.onTap});

  Color _getStatusColor() {
    switch (device.status) {
      case DeviceStatus.online:
        return AppColors.online;
      case DeviceStatus.offline:
        return AppColors.offline;
      case DeviceStatus.unknown:
        return AppColors.unknown;
    }
  }

  String _formatLastUpdated(DateTime? time) {
    if (time == null) return 'Chưa cập nhật';
    final diff = DateTime.now().difference(time);
    if (diff.isNegative || diff.inSeconds < 60) {
      return 'Vừa xong';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    }
    return DateFormat('dd/MM HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final radius = BorderRadius.circular(16.r);
    final lastUpdatedText = _formatLastUpdated(device.lastMessageTime);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceSecondary.withValues(alpha: 0.15),
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.stationName,
                              style: AppTextStyles.s15w500(),
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
                                style: AppTextStyles.s13w500(
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'IMEI: ${device.imei}',
                              style: AppTextStyles.s13w500(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            lastUpdatedText,
                            style: AppTextStyles.s12w400(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
