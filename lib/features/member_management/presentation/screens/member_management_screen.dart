import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/commom/dia_logs/app_confirm_dialog.dart';
import '../../../../app/commom/inputs/app_search_bar.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/member_entity.dart';
import '../cubit/member_management_cubit.dart';
import '../cubit/member_management_state.dart';
import '../widgets/create_member_sheet.dart';
import '../widgets/edit_member_sheet.dart';
import '../widgets/member_detail_sheet.dart';
import '../widgets/member_list_item.dart';

class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({super.key});

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_isCurrentUserAdmin()) {
      context.read<MemberManagementCubit>().loadMembers();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isCurrentUserAdmin() {
    final authState = context.read<AuthCubit>().state;
    return authState is Authenticated && authState.user.isAdmin;
  }

  Future<void> _openCreateMemberSheet() async {
    final params = await CreateMemberSheet.show(context);
    if (params != null && mounted) {
      await context.read<MemberManagementCubit>().createMember(params);
    }
  }

  Future<void> _openEditMemberSheet(MemberEntity member) async {
    final params = await EditMemberSheet.show(context, member);
    if (params != null && mounted) {
      await context.read<MemberManagementCubit>().updateMember(params);
    }
  }

  void _confirmDeleteMember(MemberEntity member) {
    AppConfirmDialog.showDelete(
      context,
      itemName: 'thành viên "${member.displayName}"',
      onConfirm: () {
        context.read<MemberManagementCubit>().deleteMember(member);
      },
    );
  }

  void _handleMemberAction(MemberEntity member, MemberItemAction action) {
    switch (action) {
      case MemberItemAction.viewDetail:
        MemberDetailSheet.show(context, member);
        break;
      case MemberItemAction.edit:
        _openEditMemberSheet(member);
        break;
      case MemberItemAction.toggleLock:
        _showBackendPendingDialog(
          title: 'Khoá tài khoản',
          message:
              'API hiện chưa có trường trạng thái khoá và endpoint khoá/mở khoá thành viên.',
        );
        break;
      case MemberItemAction.delete:
        _confirmDeleteMember(member);
        break;
    }
  }

  void _showBackendPendingDialog({
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          title,
          style: AppTextStyles.s16w600(color: AppColors.textPrimary),
        ),
        content: Text(
          message,
          style: AppTextStyles.s14w400(color: AppColors.textSecondary),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Đã hiểu',
              style: AppTextStyles.s14w500(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCurrentUserAdmin()) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_person_outlined,
                    size: 52.r,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Không có quyền truy cập',
                    style: AppTextStyles.s16w600(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Tính năng quản trị thành viên chỉ dành cho tài khoản Admin.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.s14w400(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () => context.pop(),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<MemberManagementCubit, MemberManagementState>(
          listener: (context, state) {
            if (state is MemberManagementLoaded) {
              if (state.actionMessage != null) {
                SnackbarHelper.showSuccess(
                  context,
                  message: state.actionMessage!,
                );
                context.read<MemberManagementCubit>().clearFeedback();
              } else if (state.actionError != null) {
                SnackbarHelper.showError(context, message: state.actionError!);
                context.read<MemberManagementCubit>().clearFeedback();
              }
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                _MemberTopBar(
                  onBack: () => context.pop(),
                  onAddMember: _openCreateMemberSheet,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 12.h),
                  child: AppSearchBar(
                    controller: _searchController,
                    hintText: 'Tìm theo tên hoặc email',
                    hintStyle: AppTextStyles.s13w400(
                      color: AppColors.textMuted,
                    ),
                    backgroundColor: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: 10.r,
                    height: 36.h,
                    onChanged: (value) {
                      context.read<MemberManagementCubit>().searchMembers(
                        value,
                      );
                    },
                    onClear: () {
                      context.read<MemberManagementCubit>().searchMembers('');
                    },
                  ),
                ),
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MemberManagementState state) {
    if (state is MemberManagementInitial || state is MemberManagementLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MemberManagementError) {
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
                state.message,
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
                onPressed: () => context
                    .read<MemberManagementCubit>()
                    .loadMembers(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is MemberManagementLoaded) {
      final members = state.filteredMembers;

      if (members.isEmpty) {
        final hasQuery = state.searchQuery.trim().isNotEmpty;
        return RefreshIndicator(
          onRefresh: () => context.read<MemberManagementCubit>().loadMembers(
            forceRefresh: true,
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 90.h),
              Icon(
                hasQuery ? Icons.search_off_rounded : Icons.group_outlined,
                size: 52.r,
                color: AppColors.textMuted,
              ),
              SizedBox(height: 12.h),
              Text(
                hasQuery
                    ? 'Không tìm thấy thành viên phù hợp'
                    : 'Chưa có thành viên nào',
                textAlign: TextAlign.center,
                style: AppTextStyles.s15w600(color: AppColors.textPrimary),
              ),
              SizedBox(height: 6.h),
              Text(
                hasQuery
                    ? 'Thử tìm với tên, email hoặc tên đăng nhập khác.'
                    : 'Nhấn nút thêm thành viên ở góc trên để tạo tài khoản con.',
                textAlign: TextAlign.center,
                style: AppTextStyles.s13w400(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => context.read<MemberManagementCubit>().loadMembers(
          forceRefresh: true,
        ),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 28.h),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
              child: Text(
                'Thành viên · ${members.length}',
                style: AppTextStyles.s14w500(color: AppColors.textSecondary),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D3B7A).withValues(alpha: 0.04),
                    blurRadius: 8.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Column(
                  children: [
                    for (var i = 0; i < members.length; i++) ...[
                      MemberListItem(
                        member: members[i],
                        onTap: () =>
                            MemberDetailSheet.show(context, members[i]),
                        onActionSelected: (action) =>
                            _handleMemberAction(members[i], action),
                      ),
                      if (i < members.length - 1)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 70.w,
                          endIndent: 14.w,
                          color: AppColors.divider,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _MemberTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onAddMember;

  const _MemberTopBar({required this.onBack, required this.onAddMember});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0.h, 12.w, 0.h),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 26.r,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Thành viên',
              style: AppTextStyles.s16w600(color: AppColors.primary),
            ),
          ),
          _HeaderIconButton(
            icon: Icons.person_add_alt_1_outlined,
            backgroundColor: const Color(0xFFDCEAFB),
            borderColor: const Color(0xFFC6DCF7),
            onTap: onAddMember,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor, width: 1),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 22.r, color: AppColors.primary),
        ),
      ),
    );
  }
}
