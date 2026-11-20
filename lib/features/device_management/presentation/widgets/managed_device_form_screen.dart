import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/commom/buttons/app_button.dart';
import '../../../../app/commom/inputs/app_text_field.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/managed_device_entity.dart';

class ManagedDeviceFormScreen extends StatefulWidget {
  final ManagedDeviceEntity? initialDevice;

  const ManagedDeviceFormScreen({super.key, this.initialDevice});

  static Future<ManagedDeviceEntity?> open(
    BuildContext context, {
    ManagedDeviceEntity? initialDevice,
  }) {
    return context.push<ManagedDeviceEntity?>(
      '/profile/device-management/form',
      extra: initialDevice,
    );
  }

  @override
  State<ManagedDeviceFormScreen> createState() =>
      _ManagedDeviceFormScreenState();
}

class _ManagedDeviceFormScreenState extends State<ManagedDeviceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _imeiController;
  late final TextEditingController _nameController;
  late final TextEditingController _portController;
  late final TextEditingController _simController;
  late final TextEditingController _mmsiController;
  late String _selectedModuleType;
  late ManagedDeviceStatus _selectedStatus;

  final List<String> _moduleTypes = const [
    'AIS AtoN Type 1',
    'AIS AtoN Type 3',
    'AIS Base Station',
  ];

  bool get isEdit => widget.initialDevice != null;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDevice;
    _imeiController = TextEditingController(text: d?.imei ?? '');
    _nameController = TextEditingController(text: d?.stationName ?? '');
    _portController = TextEditingController(
      text: d != null && d.aisPort > 0 ? d.aisPort.toString() : '',
    );
    _simController = TextEditingController(text: d?.simSerial ?? '');
    _mmsiController = TextEditingController(text: d?.mmsi ?? '');
    _selectedModuleType = d?.aisModuleType ?? _moduleTypes.first;
    _selectedStatus = d?.status ?? ManagedDeviceStatus.online;
  }

  @override
  void dispose() {
    _imeiController.dispose();
    _nameController.dispose();
    _portController.dispose();
    _simController.dispose();
    _mmsiController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final initial = widget.initialDevice;
    final entity = ManagedDeviceEntity(
      imei: _imeiController.text.trim(),
      stationName: _nameController.text.trim(),
      aisPort: int.parse(_portController.text.trim()),
      simSerial: _simController.text.trim(),
      mmsi: _mmsiController.text.trim(),
      secondaryUdpPort: initial?.secondaryUdpPort,
      aisModuleType: _selectedModuleType,
      status: _selectedStatus,
      signalStrength: _selectedStatus == ManagedDeviceStatus.offline
          ? 0
          : (initial != null && initial.signalStrength > 0
                ? initial.signalStrength
                : 27),
      lastMessageTime: initial?.lastMessageTime ?? DateTime.now(),
      lastAisTime: initial?.lastAisTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
    context.pop(entity);
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textAppbar,
          ),
          tooltip: 'Quay lại',
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEdit ? 'Cập nhật trạm thu' : 'Thêm trạm thu',
          style: AppTextStyles.s16w600(color: AppColors.textAppbar),
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardSection(
                  title: 'Thông tin trạm thu',
                  svgPath: 'assets/icons/device/ic_info.svg',
                  children: [
                    AppTextField(
                      label: 'Tên trạm thu',
                      isRequired: true,
                      hintText: 'Nhập tên trạm ',
                      controller: _nameController,
                      showClearButton: true,
                      borderRadius: 12.r,
                      height: 42.h,
                      borderColor: const Color(0xFFCBD5E1),
                      validator: Validators.validateDeviceName,
                    ),
                    SizedBox(height: 12.h),
                    AppTextField(
                      label: 'Mã IMEI trạm thu',
                      isRequired: true,
                      hintText: 'Nhập mã IMEI',
                      controller: _imeiController,
                      enabled: !isEdit,
                      borderColor: const Color(0xFFCBD5E1),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      borderRadius: 12.r,
                      height: 42.h,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'IMEI không được để trống';
                        }
                        if (val.trim().length < 5) {
                          return 'IMEI không hợp lệ (tối thiểu 5 chữ số)';
                        }
                        return null;
                      },
                    ),
                    if (isEdit) ...[
                      SizedBox(height: 4.h),
                      Text(
                        '* Mã IMEI là định danh phần cứng, không thể sửa đổi sau khi tạo.',
                        style: AppTextStyles.s10w400(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: 12.h),
                    _buildModuleTypeDropdown(),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildCardSection(
                  title: 'Cấu hình mạng ',
                  svgPath: 'assets/icons/device/ic_internet.svg',
                  children: [
                    AppTextField(
                      label: 'Mã SIM',
                      isRequired: true,
                      hintText: 'Nhập số SIM',
                      controller: _simController,
                      showClearButton: true,
                      borderRadius: 12.r,
                      height: 42.h,
                      borderColor: const Color(0xFFCBD5E1),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Mã SIM không được để trống';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    AppTextField(
                      label: 'Mã MMSI',
                      isRequired: true,
                      hintText: 'Nhập mã MMSI',
                      controller: _mmsiController,
                      showClearButton: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      borderRadius: 12.r,
                      height: 42.h,
                      borderColor: const Color(0xFFCBD5E1),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'MMSI không được để trống';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12.h),
                    AppTextField(
                      label: 'Cổng UDP nhận dữ liệu AIS',
                      isRequired: true,
                      hintText: 'VD: 6000',
                      controller: _portController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      borderRadius: 12.r,
                      height: 42.h,
                      borderColor: const Color(0xFFCBD5E1),
                      validator: (val) =>
                          Validators.validateUdpPort(val, required: true),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                AppButton(
                  text: isEdit ? 'Lưu' : 'Thêm',
                  onPressed: _onSave,
                  height: 44.h,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    IconData? icon,
    String? svgPath,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              if (svgPath != null)
                SvgPicture.asset(
                  svgPath,
                  width: 18.r,
                  height: 18.r,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                )
              else if (icon != null)
                Icon(icon, size: 18.r, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                title,
                style: AppTextStyles.s13w500(color: AppColors.primary),
              ),
            ],
          ),
        ),

        // 2. Card trắng bo góc chỉ chứa các trường nhập liệu
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildModuleTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Loại module AIS',
              style: AppTextStyles.s12w500(color: AppColors.textPrimary),
            ),
            // Text(' *', style: AppTextStyles.s13w500(color: AppColors.error)),
          ],
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          initialValue: _selectedModuleType,
          style: AppTextStyles.s14w500(color: const Color(0xFF0F172A)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Color(0xFF1565C0),
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: _moduleTypes.map((type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedModuleType = val);
            }
          },
        ),
      ],
    );
  }
}
