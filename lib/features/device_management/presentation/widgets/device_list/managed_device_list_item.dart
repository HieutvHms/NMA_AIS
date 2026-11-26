import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/managed_device_entity.dart';

class ManagedDeviceListItem extends StatelessWidget {
  final ManagedDeviceEntity device;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ManagedDeviceListItem({
    super.key,
    required this.device,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/device/ic_station.svg',
                width: 34.r,
                height: 34.r,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF1565C0),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            device.stationName,
                            style: AppTextStyles.s14w500(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'IMEI: ${device.imei}',
                      style: AppTextStyles.s12w500(
                        color: const Color(0xFF5B6B82),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              // Nút Sửa và Xóa trực tiếp trên thẻ thiết bị
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: const Color(0xFFE8F1FC),
                    borderRadius: BorderRadius.circular(8.r),
                    child: InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.all(7.r),
                        child: SvgPicture.asset(
                          'assets/icons/device/ic_edit.svg',
                          width: 16.r,
                          height: 16.r,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textAppbar,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Material(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8.r),
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.all(7.r),
                        child: SvgPicture.asset(
                          'assets/icons/device/ic_delete.svg',
                          width: 16.r,
                          height: 16.r,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFDC2626),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Padding(
          //   padding: EdgeInsets.symmetric(vertical: 8.h),
          //   child: const Divider(
          //     height: 1,
          //     thickness: 1,
          //     color: Color(0xFFF1F5F9),
          //   ),
          // ),
          // // Hàng 2: Thông tin chi tiết 4G (Serial SIM, Cổng UDP, Cường độ sóng)
          // Row(
          //   children: [
          //     Icon(
          //       Icons.sim_card_outlined,
          //       size: 15.r,
          //       color: const Color(0xFF64748B),
          //     ),
          //     SizedBox(width: 4.w),
          //     Expanded(
          //       child: Text(
          //         'SIM: ${device.simSerial.isNotEmpty ? device.simSerial : "Chưa cập nhật"}',
          //         style: AppTextStyles.bodySmall(
          //           color: const Color(0xFF475569),
          //         ),
          //         maxLines: 1,
          //         overflow: TextOverflow.ellipsis,
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 6.h),
          // Wrap(
          //   spacing: 8.w,
          //   runSpacing: 6.h,
          //   children: [
          //     _InfoBadge(
          //       icon: Icons.router_outlined,
          //       label: 'UDP Port: ${device.aisPort}',
          //       color: const Color(0xFF1565C0),
          //     ),
          //     _InfoBadge(
          //       icon: Icons.signal_cellular_alt_rounded,
          //       label: device.isOnline && device.signalStrength > 0
          //           ? 'Sóng: ${device.signalStrength}/31 (${device.signalPercentage}%)'
          //           : 'Sóng: 0 (Mất sóng)',
          //       color: signalColor,
          //     ),
          //     _InfoBadge(
          //       icon: Icons.memory_rounded,
          //       label: device.aisModuleType,
          //       color: const Color(0xFF475569),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
