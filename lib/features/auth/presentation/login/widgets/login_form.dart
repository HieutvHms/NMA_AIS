import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/commom/buttons/app_button.dart';
import '../../../../../app/commom/inputs/app_text_field.dart';
import '../../../../../core/utils/snackbar_helper.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'forgot_password_button.dart';
import 'package:ais/app/theme/app_colors.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AuthCubit>().state;
      if (state is Unauthenticated && state.errorMessage != null) {
        SnackbarHelper.showError(context, message: state.errorMessage!);
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state is AuthLoading) return;
    FocusScope.of(context).unfocus();
    authCubit.login(_usernameController.text, _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated && state.errorMessage != null) {
          SnackbarHelper.showError(context, message: state.errorMessage!);
        } else if (state is Authenticated) {
          SnackbarHelper.showSuccess(context, message: 'Đăng nhập thành công');
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _usernameController,
              hintText: 'Tên đăng nhập',
              enabled: !isLoading,
              prefixSvgPath: 'assets/icons/sign_in/ic_user.svg',
              borderRadius: 16.r,
              fillColor: Colors.white,
              borderColor: AppColors.borderDark,
              borderWidth: 0.5,
              focusedBorderColor: AppColors.primary,
              focusedBorderWidth: 0.8,
              height: 46.h,
            ),
            SizedBox(height: 14.h),
            AppTextField(
              controller: _passwordController,
              hintText: 'Nhập mật khẩu',
              enabled: !isLoading,
              prefixSvgPath: 'assets/icons/sign_in/ic_pass.svg',
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              borderRadius: 16.r,
              fillColor: Colors.white,
              borderColor: AppColors.borderDark,
              borderWidth: 0.5,
              focusedBorderColor: AppColors.primary,
              focusedBorderWidth: 0.8,
              height: 46.h,
            ),
            SizedBox(height: 20.h),
            AppButton(
              text: 'Đăng nhập',
              height: 46.h,
              borderRadius: 12.r,
              isLoading: isLoading,
              onPressed: _handleLogin,
            ),
            IgnorePointer(
              ignoring: isLoading,
              child: const ForgotPasswordButton(),
            ),
          ],
        );
      },
    );
  }
}
