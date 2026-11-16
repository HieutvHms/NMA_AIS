import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/text_style.dart';
import '../cubit/device_config_state.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.labelSmall(color: color).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfigStatusChip extends StatelessWidget {
  final ConfigSubmissionStatus status;

  const ConfigStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ConfigSubmissionStatus.unchanged:
        return const StatusBadge(label: 'Chưa thay đổi', color: Colors.grey);
      case ConfigSubmissionStatus.sending:
        return const StatusBadge(
            label: 'Đang gửi yêu cầu', color: Colors.blue);
      case ConfigSubmissionStatus.sent:
        return const StatusBadge(
            label: 'Đã gửi yêu cầu', color: Colors.indigo);
      case ConfigSubmissionStatus.success:
        return const StatusBadge(label: 'Thành công', color: Colors.green);
      case ConfigSubmissionStatus.failure:
        return const StatusBadge(label: 'Thất bại', color: Colors.red);
      case ConfigSubmissionStatus.noResponse:
        return const StatusBadge(
            label: 'Không nhận được phản hồi', color: Colors.orange);
    }
  }
}
