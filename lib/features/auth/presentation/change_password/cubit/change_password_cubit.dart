import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/error_mapper.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../domain/usecases/change_password_usecase.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordUseCase _changePasswordUseCase;

  ChangePasswordCubit({required ChangePasswordUseCase changePasswordUseCase})
    : _changePasswordUseCase = changePasswordUseCase,
      super(const ChangePasswordState());

  void onOldPasswordChanged(String value) {
    final shouldResetStatus = state.status == ChangePasswordStatus.failure;
    emit(
      state.copyWith(
        oldPassword: value,
        status: shouldResetStatus ? ChangePasswordStatus.initial : null,
        clearError: shouldResetStatus,
      ),
    );
  }

  void onNewPasswordChanged(String value) {
    final shouldResetStatus = state.status == ChangePasswordStatus.failure;
    emit(
      state.copyWith(
        newPassword: value,
        status: shouldResetStatus ? ChangePasswordStatus.initial : null,
        clearError: shouldResetStatus,
      ),
    );
  }

  void onConfirmPasswordChanged(String value) {
    final shouldResetStatus = state.status == ChangePasswordStatus.failure;
    emit(
      state.copyWith(
        confirmPassword: value,
        status: shouldResetStatus ? ChangePasswordStatus.initial : null,
        clearError: shouldResetStatus,
      ),
    );
  }

  void toggleObscureOld() {
    emit(state.copyWith(obscureOld: !state.obscureOld));
  }

  void toggleObscureNew() {
    emit(state.copyWith(obscureNew: !state.obscureNew));
  }

  void toggleObscureConfirm() {
    emit(state.copyWith(obscureConfirm: !state.obscureConfirm));
  }

  void clearError() {
    if (state.status == ChangePasswordStatus.failure &&
        state.errorType == ChangePasswordErrorType.general) {
      emit(
        state.copyWith(status: ChangePasswordStatus.initial, clearError: true),
      );
    }
  }

  Future<void> submit() async {
    // if (!state.canSubmit) return;

    emit(
      state.copyWith(status: ChangePasswordStatus.submitting, clearError: true),
    );

    try {
      await _changePasswordUseCase(
        oldPassword: state.oldPassword,
        newPassword: state.newPassword,
      );
      emit(
        state.copyWith(status: ChangePasswordStatus.success, clearError: true),
      );
    } on ValidationException catch (e) {
      final isWrongOldPassword = e.errors.containsKey('oldPassword');
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: e.message.isNotEmpty
              ? e.message
              : 'Mật khẩu hiện tại không đúng.',
          errorType: isWrongOldPassword
              ? ChangePasswordErrorType.wrongCurrentPassword
              : ChangePasswordErrorType.general,
        ),
      );
    } catch (e) {
      final mappedMessage = ErrorMapper.map(e).message;
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: mappedMessage.isNotEmpty
              ? mappedMessage
              : 'Không thể cập nhật mật khẩu. Vui lòng thử lại.',
          errorType: ChangePasswordErrorType.general,
        ),
      );
    }
  }
}
