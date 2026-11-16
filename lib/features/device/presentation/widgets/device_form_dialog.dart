import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/device_entity.dart';

class DeviceFormDialog extends StatefulWidget {
  final DeviceEntity? initialDevice;

  const DeviceFormDialog({super.key, this.initialDevice});

  static Future<DeviceEntity?> show(
    BuildContext context, {
    DeviceEntity? initialDevice,
  }) {
    return showDialog<DeviceEntity>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeviceFormDialog(initialDevice: initialDevice),
    );
  }

  @override
  State<DeviceFormDialog> createState() => _DeviceFormDialogState();
}

class _DeviceFormDialogState extends State<DeviceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _imeiController;
  late final TextEditingController _nameController;
  late final TextEditingController _portController;
  late final TextEditingController _simController;
  late String _selectedModuleType;

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
    _portController = TextEditingController(text: d?.aisPort.toString() ?? '6000');
    _simController = TextEditingController(text: d?.simSerial ?? '');
    _selectedModuleType = d?.aisModuleType ?? _moduleTypes.first;
  }

  @override
  void dispose() {
    _imeiController.dispose();
    _nameController.dispose();
    _portController.dispose();
    _simController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final initial = widget.initialDevice;
    final entity = DeviceEntity(
      id: _imeiController.text.trim(),
      imei: _imeiController.text.trim(),
      stationName: _nameController.text.trim(),
      aisPort: int.parse(_portController.text.trim()),
      simSerial: _simController.text.trim(),
      secondaryUdpPort: initial?.secondaryUdpPort,
      aisModuleType: _selectedModuleType,
      status: initial?.status ?? DeviceStatus.online,
      signalStrength: initial?.signalStrength ?? 25,
      lastMessageTime: initial?.lastMessageTime ?? DateTime.now(),
      lastAisTime: initial?.lastAisTime ?? DateTime(2000, 1, 1),
      updatedAt: DateTime.now(),
    );
    Navigator.of(context).pop(entity);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Chỉnh sửa thông tin trạm' : 'Thêm mới trạm AIS',
                style: AppTextStyles.titleMediumBlack(),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _nameController,
                style: AppTextStyles.bodyMedium(),
                decoration: InputDecoration(
                  labelText: 'Tên trạm *',
                  hintText: 'VD: CỬA NHƯỢNG, VŨNG ÁNG...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                validator: Validators.validateDeviceName,
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _imeiController,
                enabled: !isEdit,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.bodyMedium(),
                decoration: InputDecoration(
                  labelText: 'IMEI thiết bị 4G *',
                  hintText: '15 chữ số',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'IMEI không được để trống';
                  }
                  if (val.trim().length < 10) {
                    return 'IMEI không hợp lệ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _portController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.bodyMedium(),
                decoration: InputDecoration(
                  labelText: 'Cổng nhận dữ liệu AIS *',
                  hintText: 'VD: 6017, 6038...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                validator: (val) => Validators.validateUdpPort(val, required: true),
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: _simController,
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyMedium(),
                decoration: InputDecoration(
                  labelText: 'Serial SIM (Tùy chọn)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                initialValue: _selectedModuleType,
                decoration: InputDecoration(
                  labelText: 'Loại module AIS',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                items: _moduleTypes
                    .map((m) => DropdownMenuItem(value: m, child: Text(m, style: AppTextStyles.bodyMedium())))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedModuleType = val);
                },
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Hủy', style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
                  ),
                  SizedBox(width: 8.w),
                  FilledButton(
                    onPressed: _onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text(isEdit ? 'Lưu thay đổi' : 'Thêm mới', style: AppTextStyles.labelLarge2(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
