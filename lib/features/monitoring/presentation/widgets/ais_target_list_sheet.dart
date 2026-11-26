import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../app/commom/inputs/app_search_bar.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../domain/entities/ais_target_entity.dart';
import '../../domain/entities/ais_type_mapper.dart';
import '../cubit/map_monitoring_cubit.dart';
import '../cubit/map_monitoring_state.dart';

/// Bottom Sheet hiển thị TOÀN BỘ danh sách trạm và tàu mà user được phép xem
class AisTargetListSheet extends StatefulWidget {
  final ValueChanged<AisTargetEntity> onTargetTap;
  final ValueChanged<String> onSearchGlobalMmsi;

  const AisTargetListSheet({
    super.key,
    required this.onTargetTap,
    required this.onSearchGlobalMmsi,
  });

  static Future<void> show(
    BuildContext context, {
    required MapMonitoringCubit cubit,
    required ValueChanged<AisTargetEntity> onTargetTap,
    required ValueChanged<String> onSearchGlobalMmsi,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AisTargetListSheet(
          onTargetTap: onTargetTap,
          onSearchGlobalMmsi: onSearchGlobalMmsi,
        ),
      ),
    );
  }

  @override
  State<AisTargetListSheet> createState() => _AisTargetListSheetState();
}

class _AisTargetListSheetState extends State<AisTargetListSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AisTargetEntity> _filterTargets(List<AisTargetEntity> source) {
    final trimmed = _query.trim().toLowerCase();
    if (trimmed.isEmpty) return source;

    return source
        .where((item) {
          return item.mmsi.toLowerCase().contains(trimmed) ||
              AisTypeMapper.detailLabel(
                item.type,
              ).toLowerCase().contains(trimmed);
        })
        .toList(growable: false);
  }

  void _handleSubmitted(String rawValue, List<AisTargetEntity> allTargets) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return;

    final filtered = _filterTargets(allTargets);
    for (final item in filtered) {
      if (item.mmsi == trimmed) {
        Navigator.of(context).pop();
        widget.onTargetTap(item);
        return;
      }
    }
    if (filtered.length == 1) {
      Navigator.of(context).pop();
      widget.onTargetTap(filtered.first);
      return;
    }

    if (filtered.isEmpty) {
      Navigator.of(context).pop();
      widget.onSearchGlobalMmsi(trimmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.trim().isNotEmpty;
    final bottomKeyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomKeyboardInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.76,
        minChildSize: 0.45,
        maxChildSize: 0.94,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: SafeArea(
              top: false,
              child: BlocBuilder<MapMonitoringCubit, MapMonitoringState>(
                buildWhen: (prev, curr) =>
                    prev.allTargets != curr.allTargets ||
                    prev.isLoadingAllTargets != curr.isLoadingAllTargets ||
                    prev.allTargetsError != curr.allTargetsError,
                builder: (context, state) {
                  final allTargets = state.allTargets;
                  final filtered = _filterTargets(allTargets);

                  return Column(
                    children: [
                      SizedBox(height: 10.h),
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.borderDark,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 8.w, 6.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                hasQuery
                                    ? 'Danh sách đối tượng (${filtered.length}/${allTargets.length})'
                                    : 'Danh sách đối tượng (${allTargets.length})',
                                style: AppTextStyles.s16w600(
                                  color: AppColors.textAppbar,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                Icons.close,
                                size: 20.r,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
                        child: AppSearchBar(
                          controller: _searchController,
                          hintText: 'Tìm kiếm theo mã MMSI',
                          height: 36.h,
                          backgroundColor: AppColors.surfaceSecondary,
                          border: Border.all(color: AppColors.borderDark),
                          textStyle: AppTextStyles.s14w500(
                            color: AppColors.textPrimary,
                          ),
                          hintStyle: AppTextStyles.s13w400(
                            color: AppColors.textMuted,
                          ),
                          onChanged: (value) => setState(() => _query = value),
                          onClear: () => setState(() => _query = ''),
                          onSubmitted: (value) =>
                              _handleSubmitted(value, allTargets),
                        ),
                      ),
                      _buildTableHeader(),
                      const Divider(height: 1, color: AppColors.border),
                      Expanded(
                        child: _buildListBody(
                          state: state,
                          filtered: filtered,
                          hasQuery: hasQuery,
                          scrollController: scrollController,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListBody({
    required MapMonitoringState state,
    required List<AisTargetEntity> filtered,
    required bool hasQuery,
    required ScrollController scrollController,
  }) {
    if (state.isLoadingAllTargets && state.allTargets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.allTargetsError != null && state.allTargets.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 36.r,
                color: AppColors.textMuted,
              ),
              SizedBox(height: 8.h),
              Text(
                state.allTargetsError!,
                textAlign: TextAlign.center,
                style: AppTextStyles.s13w500(color: AppColors.textSecondary),
              ),
              SizedBox(height: 10.h),
              TextButton(
                onPressed: () => context
                    .read<MapMonitoringCubit>()
                    .loadAllTargets(forceRefresh: true),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return _buildEmptyState(hasQuery: hasQuery);
    }

    return ListView.separated(
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: filtered.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _TargetRowItem(
          stt: index + 1,
          target: item,
          onTap: () {
            Navigator.of(context).pop();
            widget.onTargetTap(item);
          },
        );
      },
    );
  }

  Widget _buildEmptyState({required bool hasQuery}) {
    final trimmed = _query.trim();
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 36.r, color: AppColors.textMuted),
            SizedBox(height: 8.h),
            Text(
              hasQuery
                  ? 'Không tìm thấy đối tượng "$trimmed"'
                  : 'Chưa có trạm hoặc tàu nào được phân quyền',
              textAlign: TextAlign.center,
              style: AppTextStyles.s13w500(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    final headerStyle = AppTextStyles.s12w600(color: AppColors.textSecondary);
    return Container(
      color: AppColors.surfaceSecondary,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      child: Row(
        children: [
          SizedBox(
            width: 38.w,
            child: Text('STT', style: headerStyle, textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 38.w,
            child: Center(
              child: Text(
                'Icon',
                style: headerStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'MMSI',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Type',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 68.w,
            child: Text(
              'Thời gian',
              textAlign: TextAlign.center,
              style: headerStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetRowItem extends StatelessWidget {
  final int stt;
  final AisTargetEntity target;
  final VoidCallback onTap;

  const _TargetRowItem({
    required this.stt,
    required this.target,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isStation = target.isStationOrAton;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            SizedBox(
              width: 38.w,
              child: Text(
                '$stt',
                textAlign: TextAlign.center,
                style: AppTextStyles.s12w500(color: AppColors.textSecondary),
              ),
            ),
            SizedBox(
              width: 38.w,
              child: Center(
                child: SvgPicture.asset(
                  isStation
                      ? 'assets/icons/tram_thu.svg'
                      : 'assets/icons/ship.svg',
                  width: 24.r,
                  height: 24.r,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                target.mmsi,
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.s13w600(color: AppColors.textPrimary),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${target.type}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.s12w500(color: AppColors.textPrimary),
              ),
            ),
            SizedBox(
              width: 68.w,
              child: Text(
                target.formattedTime,
                textAlign: TextAlign.center,
                style: AppTextStyles.s12w500(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
