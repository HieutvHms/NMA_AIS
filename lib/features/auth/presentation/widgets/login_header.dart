import 'package:flutter/material.dart';
import '../../../../app/theme/text_style.dart';
import 'ais_logo_icon.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AisLogoIcon(size: 72),
        const SizedBox(height: 14),
        Text(
          'AIS Manager',
          textAlign: TextAlign.center,
          style: AppTextStyles.body13(),
        ),
        const SizedBox(height: 6),
        Text(
          'Quản lý và cấu hình thiết bị AIS',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium(),
        ),
      ],
    );
  }
}
