import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/device_entity.dart';

class DeviceConnectionInfoSection extends StatelessWidget {
  final DeviceEntity device;
  final String formattedTime;

  const DeviceConnectionInfoSection({
    super.key,
    required this.device,
    required this.formattedTime,
  });

  String _networkStatusText(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return 'Đã kết nối';
      case DeviceStatus.offline:
        return 'Mất kết nối';
      case DeviceStatus.unknown:
        return 'Chưa xác định';
    }
  }

  String _formatDateTime(DateTime? time) {
    if (time == null) return 'Chưa có dữ liệu';
    return DateFormat('dd/MM/yyyy HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _DeviceInfoTile(
        icon: Icons.badge_outlined,
        iconColor: AppColors.primary,
        label: 'MMSI',
        value: device.mmsi.isNotEmpty ? device.mmsi : '-',
      ),
      _DeviceInfoTile(
        icon: Icons.sim_card_outlined,
        iconColor: const Color(0xFF0284C7),
        label: 'Serial SIM',
        value: device.simSerial.isNotEmpty ? device.simSerial : '-',
      ),
      _DeviceInfoTile(
        icon: Icons.signal_cellular_alt_rounded,
        iconColor: AppColors.online,
        label: 'Tín hiệu 4G',
        value: device.signalStrength > 0
            ? '${device.signalStrength >= 28 ? 85 : (device.signalStrength * 3)}%'
            : 'Không có sóng',
      ),
      _DeviceInfoTile(
        icon: Icons.language_rounded,
        iconColor: AppColors.primary,
        label: 'Trạng thái mạng',
        value: _networkStatusText(device.status),
      ),
      _DeviceInfoTile(
        icon: Icons.alt_route_rounded,
        iconColor: Colors.deepPurple,
        label: 'Cổng nhận dữ liệu AIS',
        value: 'Port ${device.aisPort}',
      ),
      _DeviceInfoTile(
        icon: Icons.access_time_rounded,
        iconColor: AppColors.alertWarning,
        label: 'Gửi tin gần nhất',
        value: formattedTime,
      ),
      _DeviceInfoTile(
        icon: Icons.radar_rounded,
        iconColor: const Color(0xFF0D9488),
        label: 'Nhận AIS gần nhất',
        value: _formatDateTime(device.lastAisTime),
      ),
      if (device.status == DeviceStatus.offline && device.offlineAtUtc != null)
        _DeviceInfoTile(
          icon: Icons.wifi_off_rounded,
          iconColor: AppColors.offline,
          label: 'Mất kết nối lúc',
          value: _formatDateTime(device.offlineAtUtc),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thông tin kết nối', style: AppTextStyles.s15w600()),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderDark),
            boxShadow: [
              BoxShadow(
                color: AppColors.textBlack.withValues(alpha: 0.15),
                blurRadius: 10.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: 52,
                    color: Color(0xFFF1F5F9),
                  ),
                tiles[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DeviceInfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DeviceInfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22.r),
          SizedBox(width: 14.w),
          Text(
            label,
            style: AppTextStyles.s14w500(color: AppColors.textSecondary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.s13w500(),
            ),
          ),
        ],
      ),
    );
  }
}
