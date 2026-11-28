import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../../device/domain/entities/device_entity.dart';
import '../../../monitoring/domain/entities/ais_target_entity.dart';

class OverviewAlertsSection extends StatelessWidget {
  final List<DeviceEntity> offlineDevices;
  final List<AisTargetEntity> abnormalAtons;
  final VoidCallback onViewAllDevicesTap;
  final ValueChanged<DeviceEntity> onDeviceTap;
  final VoidCallback onAtonTap;

  const OverviewAlertsSection({
    super.key,
    required this.offlineDevices,
    required this.abnormalAtons,
    required this.onViewAllDevicesTap,
    required this.onDeviceTap,
    required this.onAtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalAlerts = offlineDevices.length + abnormalAtons.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Cần chú ý',
              style: AppTextStyles.s16w600(color: AppColors.textPrimary),
            ),
            if (totalAlerts > 0) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.offlineBg,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$totalAlerts',
                  style: AppTextStyles.s11w600(color: AppColors.error),
                ),
              ),
            ],
            const Spacer(),
            if (totalAlerts > 3)
              GestureDetector(
                onTap: onViewAllDevicesTap,
                child: Text(
                  'Xem tất cả',
                  style: AppTextStyles.s12w600(color: AppColors.primary),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        if (totalAlerts == 0) _buildHealthyCard() else ..._buildAlertItems(),
      ],
    );
  }

  Widget _buildHealthyCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.onlineBg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.online.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: AppColors.online,
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hệ thống hoạt động ổn định',
                  style: AppTextStyles.s14w600(color: AppColors.textPrimary),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Tất cả thiết bị 4G và phao đèn AIS đều bình thường',
                  style: AppTextStyles.s12w500(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAlertItems() {
    final items = <Widget>[];
    const maxVisible = 3;

    for (final device in offlineDevices) {
      if (items.length >= maxVisible) break;
      final title = device.stationName.trim().isNotEmpty
          ? device.stationName.trim()
          : 'Thiết bị ${device.imei}';
      final lastTime = _formatTime(
        device.offlineAtUtc ?? device.lastMessageTime,
      );

      items.add(
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _AlertTile(
            icon: Icons.router_rounded,
            iconColor: AppColors.error,
            bgColor: AppColors.offlineBg.withValues(alpha: 0.65),
            title: title,
            subtitle: lastTime != null
                ? 'Ngoại tuyến · Lần cuối $lastTime'
                : 'Ngoại tuyến · IMEI ${device.imei}',
            onTap: () => onDeviceTap(device),
          ),
        ),
      );
    }

    for (final aton in abnormalAtons) {
      if (items.length >= maxVisible) break;
      final isLightError = aton.lightStatus?.toUpperCase() == 'ERROR';
      final reason = isLightError
          ? 'Đèn báo lỗi · MMSI ${aton.mmsi}'
          : 'Điện áp thấp ${aton.formattedVoltage ?? ''} · MMSI ${aton.mmsi}';

      items.add(
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _AlertTile(
            icon: isLightError
                ? Icons.lightbulb_outline_rounded
                : Icons.battery_alert_rounded,
            iconColor: AppColors.warning,
            bgColor: AppColors.maintenanceBg.withValues(alpha: 0.8),
            title: 'Phao / Đèn ${aton.displayTitle}',
            subtitle: reason,
            onTap: onAtonTap,
          ),
        ),
      );
    }

    return items;
  }

  String? _formatTime(DateTime? dt) {
    if (dt == null) return null;
    final local = dt.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final ss = local.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
}

class _AlertTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AlertTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: iconColor, size: 22.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s14w600(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s12w500(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.r,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
