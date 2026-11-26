import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../domain/entities/ais_target_entity.dart';

/// Bottom Sheet hiển thị thông tin chi tiết khi người dùng chạm vào một marker trên bản đồ.
class AisTargetDetailSheet extends StatelessWidget {
  final AisTargetEntity target;
  final VoidCallback onCenterCamera;
  final VoidCallback? onClose;

  const AisTargetDetailSheet({
    super.key,
    required this.target,
    required this.onCenterCamera,
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required AisTargetEntity target,
    required VoidCallback onCenterCamera,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AisTargetDetailSheet(target: target, onCenterCamera: onCenterCamera),
    );
  }

  void _handleClose(BuildContext context) {
    if (onClose != null) {
      onClose!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStation = target.isStationOrAton;
    final badgeBg = isStation
        ? const Color(0xFFCCFBF1)
        : AppColors.primaryLight;

    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.45;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Khu vực thanh kéo & header: vuốt xuống để đóng sheet
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > 250) {
                  _handleClose(context);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.borderDark,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Container(
                        width: 40.r,
                        height: 40.r,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: SvgPicture.asset(
                          isStation
                              ? 'assets/icons/tram_thu.svg'
                              : 'assets/icons/ship.svg',
                          width: 32.r,
                          height: 32.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin ${target.displayTitle}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.s16w600(
                                color: AppColors.textPrimary,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                            // SizedBox(height: 3.h),
                            // Container(
                            //   padding: EdgeInsets.symmetric(
                            //     horizontal: 8.w,
                            //     vertical: 2.h,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: badgeBg,
                            //     borderRadius: BorderRadius.circular(6.r),
                            //   ),
                            //   child: Text(
                            //     AisTypeMapper.detailLabel(target.type),
                            //     style: AppTextStyles.s11w600(color: badgeColor),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _handleClose(context),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20.r,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),
            const Divider(height: 1, color: AppColors.divider),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: 8.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _InfoRow(label: 'MMSI', value: target.mmsi),
                    _InfoRow(label: 'MMSI Type', value: target.mmsiType),
                    _InfoRow(
                      label: 'Lat',
                      value: target.latitude.toStringAsFixed(6),
                    ),
                    _InfoRow(
                      label: 'Lng',
                      value: target.longitude.toStringAsFixed(6),
                    ),
                    //_InfoRow(label: 'Type', value: target.vesselType),
                    _InfoRow(label: 'UTC', value: target.formattedUtc),
                    _InfoRow(label: 'Local', value: target.formattedLocal),
                    _InfoRow(
                      label: 'Received',
                      value: target.formattedReceived,
                    ),
                    _InfoRow(
                      label: 'MessageType',
                      value: target.type.toString(),
                    ),
                    //_InfoRow(label: 'DesMMSI(Msg6)', value: target.desMmsi),
                    _InfoRow(
                      label: 'Voltage(Msg6)',
                      value: target.formattedVoltage,
                    ),
                    _InfoRow(
                      label: 'Current(Msg6)',
                      value: target.formattedCurrent,
                    ),
                    _InfoRow(label: 'Light(Msg6)', value: target.lightStatus),
                    _InfoRow(label: 'AIDType(Msg21)', value: target.aidType),
                    _InfoRow(
                      label: 'BoatA(Msg21)',
                      value: target.boatA?.toString(),
                    ),
                    _InfoRow(
                      label: 'BoatB(Msg21)',
                      value: target.boatB?.toString(),
                    ),
                    _InfoRow(
                      label: 'BoatC(Msg21)',
                      value: target.boatC?.toString(),
                    ),
                    _InfoRow(
                      label: 'BoatD(Msg21)',
                      value: target.boatD?.toString(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final displayValue = (value != null && value!.trim().isNotEmpty)
        ? value!.trim()
        : '—';
    final isEmpty = displayValue == '—';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              '$label:',
              style: AppTextStyles.s13w600(color: AppColors.textBlack),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 6,
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.s13w500(
                color: isEmpty
                    ? AppColors.textSecondary.withValues(alpha: 0.6)
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
