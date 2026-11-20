import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/member_entity.dart';
import '../../cubit/member_management_state.dart';
import 'member_list_item.dart';

class MemberListBody extends StatelessWidget {
  final MemberManagementState state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<MemberEntity> onMemberTap;
  final void Function(MemberEntity member, MemberItemAction action)
  onMemberAction;

  const MemberListBody({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.onMemberTap,
    required this.onMemberAction,
  });

  @override
  Widget build(BuildContext context) {
    if (state is MemberManagementInitial || state is MemberManagementLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MemberManagementError) {
      return _buildErrorView((state as MemberManagementError).message);
    }

    if (state is MemberManagementLoaded) {
      final loaded = state as MemberManagementLoaded;
      if (loaded.filteredMembers.isEmpty) {
        return _buildEmptyView(hasQuery: loaded.searchQuery.trim().isNotEmpty);
      }
      return _buildMemberList(loaded.filteredMembers);
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48.r,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.s14w500(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView({required bool hasQuery}) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 60.h),
          Icon(
            hasQuery ? Icons.search_off_rounded : Icons.group_outlined,
            size: 40.r,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 12.h),
          Text(
            hasQuery
                ? 'Không tìm thấy thành viên phù hợp'
                : 'Chưa có thành viên nào',
            textAlign: TextAlign.center,
            style: AppTextStyles.s14w500(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberList(List<MemberEntity> members) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(12.w, 1.h, 12.w, 12.h),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Thành viên · ${members.length}',
              style: AppTextStyles.s14w500(color: AppColors.textSecondary),
            ),
          ),
          SizedBox(height: 4.h),
          for (var i = 0; i < members.length; i++) ...[
            MemberListItem(
              member: members[i],
              onTap: () => onMemberTap(members[i]),
              onActionSelected: (action) => onMemberAction(members[i], action),
            ),
            if (i < members.length - 1) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}
