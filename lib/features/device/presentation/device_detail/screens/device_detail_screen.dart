import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/device_entity.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DeviceEntity device;

  const DeviceDetailScreen({super.key, required this.device});

  Color _getStatusColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.online:
        return const Color(0xFF15803D);
      case DeviceStatus.offline:
        return const Color(0xFFDC2626);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(device.status);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedTime = device.updatedAt != null
        ? dateFormat.format(device.updatedAt!)
        : '14/11/2026 14:30';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
          tooltip: 'Quay lại',
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Chi tiết thiết bị',
          style: AppTextStyles.titleMediumBlack(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        children: [
          // 1. Header Card theo đúng Mockup 4
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D3B7A).withValues(alpha: 0.04),
                  blurRadius: 10.r,
                  offset: Offset(0, 2.h),
                ),
              ],
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon antenna ((A))
                SvgPicture.asset(
                  'assets/icons/device/ic_station.svg',
                  width: 36.r,
                  height: 36.r,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF1B63C6),
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
                              style: AppTextStyles.titleMediumBlack(),
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
                              style: AppTextStyles.labelSmall(
                                color: statusColor,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'IMEI: ${device.imei}',
                        style: AppTextStyles.bodySmall(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Cập nhật: $formattedTime',
                        style: AppTextStyles.bodySmall(
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // 2. Khối Thông tin kết nối theo Mockup 4
          Text('Thông tin kết nối', style: AppTextStyles.titleMediumBlack()),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.signal_cellular_alt_rounded,
                  iconColor: const Color(0xFF16A34A),
                  label: 'Tín hiệu 4G',
                  value: device.signalStrength > 0
                      ? '${device.signalStrength >= 28 ? 85 : (device.signalStrength * 3)}%'
                      : 'Không có sóng',
                ),
                const Divider(height: 1, indent: 52, color: Color(0xFFF1F5F9)),
                _buildInfoTile(
                  icon: Icons.language_rounded,
                  iconColor: const Color(0xFF1976D2),
                  label: 'Trạng thái mạng',
                  value: device.isOnline ? 'Đã kết nối' : 'Mất kết nối',
                ),
                const Divider(height: 1, indent: 52, color: Color(0xFFF1F5F9)),
                _buildInfoTile(
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFFED6C02),
                  label: 'Thời gian kết nối cuối',
                  value: formattedTime,
                ),
                const Divider(height: 1, indent: 52, color: Color(0xFFF1F5F9)),
                _buildInfoTile(
                  icon: Icons.alt_route_rounded,
                  iconColor: Colors.deepPurple,
                  label: 'Cổng nhận dữ liệu AIS',
                  value: 'Port ${device.aisPort}',
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // 3. Khối Chức năng theo Mockup 4
          Text('Chức năng', style: AppTextStyles.titleMediumBlack()),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.settings_outlined,
                  iconColor: const Color(0xFF1976D2),
                  title: 'Cấu hình thiết bị',
                  onTap: () => context.push(
                    '/devices/${device.imei}/config',
                    extra: device,
                  ),
                ),
                const Divider(height: 1, indent: 52, color: Color(0xFFF1F5F9)),
                _buildActionTile(
                  icon: Icons.show_chart_rounded,
                  iconColor: const Color(0xFF0284C7),
                  title: 'Xem dữ liệu AIS',
                  onTap: () => context.push('/monitoring'),
                ),
                const Divider(height: 1, indent: 52, color: Color(0xFFF1F5F9)),
                _buildActionTile(
                  icon: Icons.history_rounded,
                  iconColor: const Color(0xFF6366F1),
                  title: 'Lịch sử cấu hình',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tính năng lịch sử cấu hình đang được phát triển.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22.r),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: AppTextStyles.labelLarge2()),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24.r),
      title: Text(title, style: AppTextStyles.labelLarge2()),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: const Color(0xFF94A3B8),
        size: 22.r,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    );
  }
}
