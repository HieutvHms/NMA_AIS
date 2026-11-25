import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/commom/inputs/app_text_field.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../../../core/utils/validators.dart';

class UdpPortListField extends StatefulWidget {
  final List<String> ports;
  final ValueChanged<List<String>> onChanged;
  final String label;
  final String hintText;
  final bool isRequired;

  const UdpPortListField({
    super.key,
    required this.ports,
    required this.onChanged,
    this.label = 'Cổng UDP',
    this.hintText = '8001',
    this.isRequired = false,
  });

  @override
  State<UdpPortListField> createState() => UdpPortListFieldState();
}

class UdpPortListFieldState extends State<UdpPortListField> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Nếu người dùng đã nhập cổng nhưng chưa bấm nút thêm,
  /// tự động validate và thêm vào danh sách trước khi submit form.
  bool commitPendingInput() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      if (_errorText != null) {
        setState(() => _errorText = null);
      }
      if (widget.isRequired && widget.ports.isEmpty) {
        setState(() => _errorText = 'Vui lòng thêm ít nhất 1 cổng UDP.');
        return false;
      }
      return true;
    }
    return _addPort(trimmed);
  }

  bool _addPort(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return false;

    final validationError = Validators.validateUdpPort(trimmed, required: true);
    if (validationError != null) {
      setState(() => _errorText = validationError);
      return false;
    }

    if (widget.ports.contains(trimmed)) {
      setState(() => _errorText = 'Cổng UDP "$trimmed" đã tồn tại.');
      return false;
    }

    final updated = [...widget.ports, trimmed];
    _controller.clear();
    setState(() => _errorText = null);
    widget.onChanged(updated);
    return true;
  }

  void _removePort(String port) {
    final updated = widget.ports.where((item) => item != port).toList();
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: widget.label,
            style: AppTextStyles.s12w500(color: AppColors.textPrimary),
            children: [
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: _controller,
                hintText: widget.hintText,
                prefixIcon: Icons.settings_ethernet_rounded,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                borderColor: _errorText != null
                    ? Colors.redAccent
                    : const Color(0xFFCBD5E1),
                height: 40.h,
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  }
                },
                onSubmitted: _addPort,
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              height: 40.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => _addPort(_controller.text),
                icon: Icon(Icons.add_rounded, size: 18.r),
                label: Text(
                  'Thêm',
                  style: AppTextStyles.s13w500(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        if (_errorText != null) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              _errorText!,
              style: AppTextStyles.s11w500(color: Colors.redAccent),
            ),
          ),
        ],
        if (widget.ports.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.ports
                .map(
                  (port) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          port,
                          style: AppTextStyles.s13w500(
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: () => _removePort(port),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16.r,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
