import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/commom/buttons/app_button.dart';
import '../../../../app/commom/inputs/app_text_field.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'forgot_password_button.dart';

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
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().login(
      _usernameController.text,
      _passwordController.text,
    );
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
              prefixSvgPath: 'assets/icons/sign_in/ic_user.svg',
              borderRadius: 16.r,
              fillColor: Colors.white,
              borderColor: const Color.fromARGB(255, 137, 148, 164),
              borderWidth: 0.5,
              focusedBorderColor: const Color(0xFF1B63C6),
              focusedBorderWidth: 0.8,
              height: 46.h,
            ),
            SizedBox(height: 14.h),
            AppTextField(
              controller: _passwordController,
              hintText: 'Mật khẩu',
              prefixSvgPath: 'assets/icons/sign_in/ic_pass.svg',
              isPassword: true,
              onSubmitted: (_) => _handleLogin(),
              borderRadius: 16.r,
              fillColor: Colors.white,
              borderColor: const Color.fromARGB(255, 137, 148, 164),
              borderWidth: 0.5,
              focusedBorderColor: const Color(0xFF1B63C6),
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
            const ForgotPasswordButton(),
          ],
        );
      },
    );
  }
}
