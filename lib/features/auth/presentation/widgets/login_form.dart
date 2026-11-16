import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/commom/inputs/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'forgot_password_button.dart';
import 'login_submit_button.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

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
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
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
              textInputAction: TextInputAction.next,
              borderRadius: 14.r,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 15.h,
              ),
            ),
            SizedBox(height: 14.h),
            AppTextField(
              controller: _passwordController,
              hintText: 'Mật khẩu',
              prefixSvgPath: 'assets/icons/sign_in/ic_pass.svg',
              isPassword: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              borderRadius: 14.r,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 15.h,
              ),
            ),
            SizedBox(height: 20.h),
            LoginSubmitButton(
              isLoading: isLoading,
              onPressed: _handleLogin,
            ),
            SizedBox(height: 12.h),
            const ForgotPasswordButton(),
          ],
        );
      },
    );
  }
}

