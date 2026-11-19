import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/commom/inputs/app_text_field.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/member_entity.dart';

/// Màn hình tạo mới thành viên con (`POST /user/update` type: 1).
class CreateMemberSheet extends StatefulWidget {
  const CreateMemberSheet({super.key});

  static Future<MemberEntity?> show(BuildContext context) {
    return Navigator.of(context).push<MemberEntity>(
      MaterialPageRoute(builder: (_) => const CreateMemberSheet()),
    );
  }

  @override
  State<CreateMemberSheet> createState() => _CreateMemberSheetState();
}

class _CreateMemberSheetState extends State<CreateMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _udpPortController = TextEditingController();

  bool _hasMinPasswordLength = false;

  static final _emailRegex = RegExp(r'^\S+@\S+\.\S+$');

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _udpPortController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final isValid = _passwordController.text.length >= 6;
    if (isValid != _hasMinPasswordLength) {
      setState(() => _hasMinPasswordLength = isValid);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(
      MemberEntity(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        udpPort: _udpPortController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20.r,
            color: AppColors.textAppbar,
          ),
        ),
        title: Text(
          'Thêm thành viên',
          style: AppTextStyles.s16w600(color: AppColors.textAppbar),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: _usernameController,
                  label: 'Tên đăng nhập',
                  isRequired: true,
                  hintText: 'Tên đăng nhập',
                  prefixSvgPath: 'assets/icons/sign_in/ic_user.svg',
                  borderColor: const Color(0xFFCBD5E1),
                  height: 40.h,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên đăng nhập.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 14.h),
                AppTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu',
                  isRequired: true,
                  hintText: 'Nhập mật khẩu',
                  prefixSvgPath: 'assets/icons/sign_in/ic_pass.svg',
                  isPassword: true,
                  borderColor: const Color(0xFFCBD5E1),
                  height: 40.h,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mật khẩu.';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu tối thiểu 6 ký tự.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8.h),
                _buildPasswordHelperRow(),
                SizedBox(height: 22.h),

                Row(
                  children: [
                    Text(
                      'THÔNG TIN CÁ NHÂN',
                      style: AppTextStyles.s12w500(
                        color: AppColors.textSecondary,
                      ).copyWith(letterSpacing: 0.4),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'Tuỳ chọn',
                        style: AppTextStyles.s10w500(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: _nameController,
                  label: 'Họ và tên',
                  hintText: 'Nguyễn Văn A',
                  prefixSvgPath: 'assets/icons/member/ic_name.svg',
                  borderColor: const Color(0xFFCBD5E1),
                  height: 40.h,
                ),
                SizedBox(height: 14.h),
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'member@hms.vn',
                  prefixSvgPath: 'assets/icons/member/ic_email.svg',
                  keyboardType: TextInputType.emailAddress,
                  borderColor: const Color(0xFFCBD5E1),
                  height: 40.h,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isNotEmpty && !_emailRegex.hasMatch(trimmed)) {
                      return 'Email không hợp lệ.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 14.h),
                AppTextField(
                  controller: _phoneController,
                  label: 'Số điện thoại',
                  hintText: '0900000001',
                  prefixSvgPath: 'assets/icons/member/ic_phone.svg',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  borderColor: const Color(0xFFCBD5E1),
                  height: 40.h,
                ),
                SizedBox(height: 14.h),
                AppTextField(
                  controller: _udpPortController,
                  label: 'Cổng UDP',
                  hintText: '8002',
                  prefixIcon: Icons.settings_ethernet_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  borderColor: const Color(0xFFCBD5E1),
                  height: 40.h,
                  onSubmitted: (_) => _submit(),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: _submit,
                    child: Text(
                      'Tạo thành viên',
                      style: AppTextStyles.s15w600(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordHelperRow() {
    final statusColor = _hasMinPasswordLength
        ? AppColors.online
        : AppColors.textMuted;

    return Row(
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 16.r,
          color: statusColor,
        ),
        SizedBox(width: 6.w),
        Text(
          'Tối thiểu 6 ký tự',
          style: AppTextStyles.s12w500(color: statusColor),
        ),
      ],
    );
  }
}
