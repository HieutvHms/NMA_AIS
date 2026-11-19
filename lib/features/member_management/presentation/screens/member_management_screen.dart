import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/commom/dia_logs/app_confirm_dialog.dart';
import '../../../../app/commom/inputs/app_search_bar.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../auth/presentation/login/cubit/auth_cubit.dart';
import '../../../auth/presentation/login/cubit/auth_state.dart';
import '../../domain/entities/member_entity.dart';
import '../cubit/member_management_cubit.dart';
import '../cubit/member_management_state.dart';
import '../widgets/common/member_access_denied_view.dart';
import '../widgets/detail/member_detail_sheet.dart';
import '../widgets/forms/create_member_sheet.dart';
import '../widgets/forms/edit_member_sheet.dart';
import '../widgets/list/member_list_body.dart';
import '../widgets/list/member_list_item.dart';
import '../widgets/list/member_top_bar.dart';

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

  Future<void> _openCreateMember() async {
    final member = await CreateMemberSheet.show(context);
    if (member != null && mounted) {
      await context.read<MemberManagementCubit>().createMember(member);
    }
  }

  Future<void> _openEditMember(MemberEntity member) async {
    final updated = await EditMemberSheet.show(context, member);
    if (updated != null && mounted) {
      await context.read<MemberManagementCubit>().updateMember(updated);
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
        _openEditMember(member);
        break;
      case MemberItemAction.toggleLock:
        SnackbarHelper.showInfo(
          context,
          message: 'Tính năng khoá/mở khoá tài khoản đang chờ backend hỗ trợ.',
        );
        break;
      case MemberItemAction.delete:
        _confirmDeleteMember(member);
        break;
    }
  }

  void _handleFeedback(BuildContext context, MemberManagementState state) {
    if (state is! MemberManagementLoaded) return;
    if (state.actionMessage != null) {
      SnackbarHelper.showSuccess(context, message: state.actionMessage!);
      context.read<MemberManagementCubit>().clearFeedback();
    } else if (state.actionError != null) {
      SnackbarHelper.showError(context, message: state.actionError!);
      context.read<MemberManagementCubit>().clearFeedback();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCurrentUserAdmin()) {
      return MemberAccessDeniedView(onBack: () => context.pop());
    }

    final cubit = context.read<MemberManagementCubit>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<MemberManagementCubit, MemberManagementState>(
          listener: _handleFeedback,
          builder: (context, state) {
            return Column(
              children: [
                MemberTopBar(
                  onBack: () => context.pop(),
                  onAddMember: _openCreateMember,
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
                    borderRadius: 12.r,
                    height: 40.h,
                    onChanged: cubit.searchMembers,
                    onClear: () => cubit.searchMembers(''),
                  ),
                ),
                Expanded(
                  child: MemberListBody(
                    state: state,
                    onRefresh: () => cubit.loadMembers(forceRefresh: true),
                    onRetry: () => cubit.loadMembers(forceRefresh: true),
                    onMemberTap: (member) =>
                        MemberDetailSheet.show(context, member),
                    onMemberAction: _handleMemberAction,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
