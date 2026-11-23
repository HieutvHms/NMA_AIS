import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';

enum DeviceSortOption {
  latestUpdated('Cập nhật gần nhất'),
  nameAsc('Tên A → Z');

  final String label;
  const DeviceSortOption(this.label);
}

class DeviceSortBottomSheet extends StatefulWidget {
  final DeviceSortOption initialSort;

  const DeviceSortBottomSheet({super.key, required this.initialSort});

  static Future<DeviceSortOption?> show(
    BuildContext context, {
    required DeviceSortOption initialSort,
  }) {
    return showModalBottomSheet<DeviceSortOption>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => DeviceSortBottomSheet(initialSort: initialSort),
    );
  }

  @override
  State<DeviceSortBottomSheet> createState() => _DeviceSortBottomSheetState();
}

class _DeviceSortBottomSheetState extends State<DeviceSortBottomSheet> {
  late DeviceSortOption _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.initialSort;
  }

  @override
  Widget build(BuildContext context) {
    const options = DeviceSortOption.values;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            Row(
              children: [
                Text(
                  'Sắp xếp',
                  style: AppTextStyles.s16w600(color: AppColors.textAppbar),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    setState(
                      () => _selectedSort = DeviceSortOption.latestUpdated,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderDark),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text('Đặt lại', style: AppTextStyles.s13w500()),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Danh sách lựa chọn radio
            for (int i = 0; i < options.length; i++) ...[
              _SortOptionRow(
                label: options[i].label,
                selected: _selectedSort == options[i],
                onTap: () => setState(() => _selectedSort = options[i]),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
            ],
            SizedBox(height: 16.h),

            // Nút Áp dụng
            SizedBox(
              height: 44.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selectedSort),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Áp dụng',
                  style: AppTextStyles.s14w600(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOptionRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortOptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFF94A3B8),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Container(
                      width: 11.r,
                      height: 11.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.s14w500(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
