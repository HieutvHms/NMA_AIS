import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_mapper.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/usecases/create_member_usecase.dart';
import '../../domain/usecases/delete_member_usecase.dart';
import '../../domain/usecases/get_members_usecase.dart';
import '../../domain/usecases/update_member_usecase.dart';
import 'member_management_state.dart';

class MemberManagementCubit extends Cubit<MemberManagementState> {
  final GetMembersUseCase _getMembersUseCase;
  final CreateMemberUseCase _createMemberUseCase;
  final UpdateMemberUseCase _updateMemberUseCase;
  final DeleteMemberUseCase _deleteMemberUseCase;

  List<MemberEntity> _cachedMembers = [];
  String _searchQuery = '';

  MemberManagementCubit({
    required GetMembersUseCase getMembersUseCase,
    required CreateMemberUseCase createMemberUseCase,
    required UpdateMemberUseCase updateMemberUseCase,
    required DeleteMemberUseCase deleteMemberUseCase,
  }) : _getMembersUseCase = getMembersUseCase,
       _createMemberUseCase = createMemberUseCase,
       _updateMemberUseCase = updateMemberUseCase,
       _deleteMemberUseCase = deleteMemberUseCase,
       super(const MemberManagementInitial());

  /// Tải danh sách thành viên từ server (hoặc dùng cache nếu không bắt buộc làm mới).
  Future<void> loadMembers({
    bool forceRefresh = false,
    String? actionMessage,
  }) async {
    if (_cachedMembers.isEmpty || forceRefresh) {
      if (state is! MemberManagementLoaded) {
        emit(const MemberManagementLoading());
      }
      try {
        _cachedMembers = await _getMembersUseCase();
      } catch (e) {
        emit(MemberManagementError(ErrorMapper.map(e).message));
        return;
      }
    }

    _emitFilteredState(actionMessage: actionMessage);
  }

  /// Lọc danh sách thành viên theo tên, email hoặc tên đăng nhập.
  void searchMembers(String query) {
    _searchQuery = query;
    if (state is MemberManagementLoaded) {
      _emitFilteredState();
    }
  }

  /// Tạo mới thành viên con qua `POST /user/update` (type: 1).
  Future<bool> createMember(MemberEntity member) async {
    final current = state;
    if (current is MemberManagementLoaded) {
      emit(current.copyWith(isSubmitting: true, clearFeedback: true));
    }

    try {
      await _createMemberUseCase(member);
      await loadMembers(
        forceRefresh: true,
        actionMessage: 'Tạo tài khoản "${member.username}" thành công.',
      );
      return true;
    } catch (e) {
      _emitActionError(e);
      return false;
    }
  }

  /// Cập nhật thông tin thành viên qua `POST /user/update` (type: 2).
  Future<bool> updateMember(MemberEntity member) async {
    final current = state;
    if (current is MemberManagementLoaded) {
      emit(current.copyWith(isSubmitting: true, clearFeedback: true));
    }

    try {
      await _updateMemberUseCase(member);
      await loadMembers(
        forceRefresh: true,
        actionMessage: 'Cập nhật thông tin thành công.',
      );
      return true;
    } catch (e) {
      _emitActionError(e);
      return false;
    }
  }

  /// Xoá thành viên qua `POST /user/update` (type: 3).
  Future<bool> deleteMember(MemberEntity member) async {
    final current = state;
    if (current is MemberManagementLoaded) {
      emit(current.copyWith(isSubmitting: true, clearFeedback: true));
    }

    try {
      await _deleteMemberUseCase(member.userId);
      await loadMembers(
        forceRefresh: true,
        actionMessage: 'Đã xoá thành viên "${member.displayName}".',
      );
      return true;
    } catch (e) {
      _emitActionError(e);
      return false;
    }
  }

  void clearFeedback() {
    final current = state;
    if (current is MemberManagementLoaded &&
        (current.actionMessage != null || current.actionError != null)) {
      emit(current.copyWith(clearFeedback: true));
    }
  }

  void _emitActionError(Object error) {
    final errorMessage = ErrorMapper.map(error).message;
    if (state is MemberManagementLoaded) {
      emit(
        (state as MemberManagementLoaded).copyWith(
          isSubmitting: false,
          actionError: errorMessage,
        ),
      );
    } else {
      emit(MemberManagementError(errorMessage));
    }
  }

  void _emitFilteredState({String? actionMessage}) {
    final trimmed = _searchQuery.trim().toLowerCase();
    final filtered = trimmed.isEmpty
        ? List<MemberEntity>.from(_cachedMembers)
        : _cachedMembers.where((member) {
            return member.displayName.toLowerCase().contains(trimmed) ||
                member.email.toLowerCase().contains(trimmed) ||
                member.username.toLowerCase().contains(trimmed);
          }).toList();

    emit(
      MemberManagementLoaded(
        allMembers: List<MemberEntity>.from(_cachedMembers),
        filteredMembers: filtered,
        searchQuery: _searchQuery,
        isSubmitting: false,
        actionMessage: actionMessage,
      ),
    );
  }
}
