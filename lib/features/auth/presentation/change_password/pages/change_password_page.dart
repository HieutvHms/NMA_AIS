import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/commom/inputs/app_text_field.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../../../core/utils/snackbar_helper.dart';
import '../cubit/change_password_cubit.dart';
import '../cubit/change_password_state.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  static const _primaryColor = Color(0xFF1C63C8);
  static const _titleColor = Color(0xFF0F2F66);
  static const _inputFillColor = Color(0xFFF7F9FC);
  static const _inputBorderColor = Color(0xFFE3E8F0);
  static const _successColor = Color(0xFF15803D);
  static const _errorColor = Color(0xFFC62828);

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _oldFocusNode = FocusNode();
  final _newFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _oldFocusNode.dispose();
    _newFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.r,
              color: _primaryColor,
            ),
          ),
          title: Text(
            'Đổi mật khẩu',
            style: AppTextStyles.s16w600(color: _titleColor),
          ),
        ),
        body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
          listener: (context, state) {
            if (state.status == ChangePasswordStatus.success) {
              SnackbarHelper.showSuccess(
                context,
                message: 'Thay đổi mật khẩu thành công.',
              );
              context.pop();
            } else if (state.status == ChangePasswordStatus.failure) {
              if (state.errorType ==
                  ChangePasswordErrorType.wrongCurrentPassword) {
                _oldFocusNode.requestFocus();
              } else {
                SnackbarHelper.showError(
                  context,
                  message:
                      state.errorMessage ??
                      'Không thể cập nhật mật khẩu. Vui lòng thử lại.',
                );
                context.read<ChangePasswordCubit>().clearError();
              }
            }
          },
          builder: (context, state) {
            final cubit = context.read<ChangePasswordCubit>();

            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Mật khẩu hiện tại',
                      isRequired: true,
                      hintText: 'Nhập mật khẩu hiện tại',
                      controller: _oldPasswordController,
                      focusNode: _oldFocusNode,
                      textInputAction: TextInputAction.next,
                      isPassword: true,
                      enabled: !state.isSubmitting,
                      prefixSvgPath: 'assets/icons/sign_in/ic_pass.svg',
                      fillColor: _inputFillColor,
                      borderColor: state.currentPasswordError != null
                          ? _errorColor
                          : _inputBorderColor,
                      focusedBorderColor: state.currentPasswordError != null
                          ? _errorColor
                          : _primaryColor,
                      height: 46.h,
                      borderRadius: 12.r,
                      onChanged: cubit.onOldPasswordChanged,
                      onSubmitted: (_) => _newFocusNode.requestFocus(),
                    ),
                    if (state.currentPasswordError != null) ...[
                      SizedBox(height: 6.h),
                      Text(
                        state.currentPasswordError!,
                        style: AppTextStyles.s12w500(color: _errorColor),
                      ),
                    ],
                    SizedBox(height: 16.h),
                    AppTextField(
                      label: 'Mật khẩu mới',
                      isRequired: true,
                      hintText: 'Nhập mật khẩu mới',
                      controller: _newPasswordController,
                      focusNode: _newFocusNode,
                      textInputAction: TextInputAction.next,
                      isPassword: true,
                      enabled: !state.isSubmitting,
                      prefixSvgPath: 'assets/icons/sign_in/ic_pass.svg',
                      fillColor: _inputFillColor,
                      borderColor: _inputBorderColor,
                      focusedBorderColor: _primaryColor,
                      height: 46.h,
                      borderRadius: 12.r,
                      onChanged: cubit.onNewPasswordChanged,
                      onSubmitted: (_) => _confirmFocusNode.requestFocus(),
                    ),
                    SizedBox(height: 12.h),

                    // Thanh độ mạnh 4 đoạn + nhãn
                    // PasswordStrengthBar(strength: state.strength),
                    // SizedBox(height: 12.h),

                    // Checklist 4 quy tắc
                    // PasswordRuleChecklist(
                    //   hasMinLength: state.hasMinLength,
                    //   hasUpperAndLower: state.hasUpperAndLower,
                    //   hasDigit: state.hasDigit,
                    //   differsFromOld: state.differsFromOld,
                    // ),
                    //SizedBox(height: 18.h),
                    AppTextField(
                      label: 'Xác nhận mật khẩu mới',
                      isRequired: true,
                      hintText: 'Nhập lại mật khẩu mới',
                      controller: _confirmPasswordController,
                      focusNode: _confirmFocusNode,
                      textInputAction: TextInputAction.done,
                      isPassword: true,
                      enabled: !state.isSubmitting,
                      prefixSvgPath: 'assets/icons/sign_in/ic_pass.svg',
                      fillColor: _inputFillColor,
                      borderColor: state.isConfirmMatched
                          ? _successColor
                          : (state.isConfirmMismatched
                                ? _errorColor
                                : _inputBorderColor),
                      focusedBorderColor: state.isConfirmMatched
                          ? _successColor
                          : (state.isConfirmMismatched
                                ? _errorColor
                                : _primaryColor),
                      showSuccessIcon: state.isConfirmMatched,
                      height: 46.h,
                      borderRadius: 12.r,
                      onChanged: cubit.onConfirmPasswordChanged,
                      onSubmitted: (_) {
                        _dismissKeyboard();
                        cubit.submit();
                      },
                    ),
                    if (state.hasConfirmInput) ...[
                      SizedBox(height: 6.h),
                      Text(
                        state.isConfirmMatched
                            ? 'Mật khẩu khớp'
                            : 'Mật khẩu xác nhận không khớp',
                        style: AppTextStyles.s12w500(
                          color: state.isConfirmMatched
                              ? _successColor
                              : _errorColor,
                        ),
                      ),
                    ],
                    SizedBox(height: 24.h),

                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          disabledBackgroundColor: _primaryColor.withValues(
                            alpha: 0.4,
                          ),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white.withValues(
                            alpha: 0.85,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        onPressed: () {
                          _dismissKeyboard();
                          cubit.submit();
                        },
                        child: state.isSubmitting
                            ? SizedBox(
                                width: 22.r,
                                height: 22.r,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Cập nhật mật khẩu',
                                style: AppTextStyles.s15w600(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
