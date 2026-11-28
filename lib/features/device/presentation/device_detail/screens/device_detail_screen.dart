import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/device_entity.dart';
import '../widgets/device_actions_section.dart';
import '../widgets/device_connection_info_section.dart';
import '../widgets/device_detail_header_card.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DeviceEntity device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final formattedTime = device.lastMessageTime != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(device.lastMessageTime!)
        : 'Chưa có dữ liệu';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: AppColors.textAppbar,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Chi tiết thiết bị',
          style: AppTextStyles.s16w600(color: AppColors.textAppbar),
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        children: [
          DeviceDetailHeaderCard(device: device, formattedTime: formattedTime),
          SizedBox(height: 20.h),
          DeviceConnectionInfoSection(
            device: device,
            formattedTime: formattedTime,
          ),
          SizedBox(height: 20.h),
          DeviceActionsSection(
            onConfigTap: () {
              final routeId = device.imei.isNotEmpty ? device.imei : 'detail';
              context.push('/devices/$routeId/config', extra: device);
            },
            onViewAisTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tính năng đang được phát triển.'),
                ),
              );
            },
            onHistoryTap: () {
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
    );
  }
}
