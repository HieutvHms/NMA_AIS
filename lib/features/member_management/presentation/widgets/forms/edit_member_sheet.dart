import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/commom/inputs/app_text_field.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/member_entity.dart';

class EditMemberSheet extends StatefulWidget {
  final MemberEntity member;

  const EditMemberSheet({super.key, required this.member});

  static Future<MemberEntity?> show(BuildContext context, MemberEntity member) {
    return Navigator.of(context).push<MemberEntity>(
      MaterialPageRoute(builder: (_) => EditMemberSheet(member: member)),
    );
  }

  @override
  State<EditMemberSheet> createState() => _EditMemberSheetState();
}

class _EditMemberSheetState extends State<EditMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _udpPortController;

  static final _emailRegex = RegExp(r'^\S+@\S+\.\S+$');

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.member.username);
    _nameController = TextEditingController(text: widget.member.name);
    _emailController = TextEditingController(text: widget.member.email);
    _phoneController = TextEditingController(text: widget.member.phone);
    _udpPortController = TextEditingController(text: widget.member.udpPort);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _udpPortController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    Navigator.of(context).pop(
      widget.member.copyWith(
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
          'Chỉnh sửa thành viên',
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
                  prefixSvgPath: 'assets/icons/sign_in/ic_user.svg',
                  enabled: false,
                  fillColor: const Color(0xFFF1F5F9),
                  borderColor: const Color(0xFFCBD5E1),
                  height: 40.h,
                ),
                SizedBox(height: 14.h),
                AppTextField(
                  controller: _nameController,
                  label: 'Họ và tên',
                  isRequired: true,
                  hintText: 'Nhập họ và tên',
                  prefixSvgPath: 'assets/icons/member/ic_name.svg',
                  borderColor: const Color(0xFFCBD5E1),
                  height: 40.h,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Không được để trống.';
                    }
                    return null;
                  },
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
                  hintText: '0900000002',
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
                  isRequired: true,
                  hintText: '8010',
                  prefixIcon: Icons.settings_ethernet_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  borderColor: const Color(0xFFCBD5E1),
                  height: 40.h,
                  onSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Không được để trống.';
                    }
                    return null;
                  },
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
                      'Lưu thay đổi',
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
}
