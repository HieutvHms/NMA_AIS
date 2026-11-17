import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../app/commom/buttons/app_button.dart';
import '../../../../../app/commom/inputs/app_text_field.dart';
import '../cubit/device_config_cubit.dart';
import '../cubit/device_config_state.dart';
import '../../../domain/entities/device_entity.dart';
import '../widgets/config_confirm_dialog.dart';
import '../widgets/status_chip.dart';

class DeviceConfigScreen extends StatefulWidget {
  final DeviceEntity device;

  const DeviceConfigScreen({super.key, required this.device});

  @override
  State<DeviceConfigScreen> createState() => _DeviceConfigScreenState();
}

class _DeviceConfigScreenState extends State<DeviceConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _mainPortController;
  late final TextEditingController _secondaryPortController;
  late String _selectedAisType;

  final List<String> _aisDeviceTypes = const [
    'AIS AtoN Type 1',
    'AIS AtoN Type 3',
    'AIS Base Station',
  ];

  @override
  void initState() {
    super.initState();
    context.read<DeviceConfigCubit>().initDevice(widget.device);
    _nameController = TextEditingController(text: widget.device.stationName);
    _mainPortController = TextEditingController(
      text: widget.device.aisPort.toString(),
    );
    _secondaryPortController = TextEditingController(
      text: widget.device.secondaryUdpPort?.toString() ?? '',
    );
    _selectedAisType = widget.device.aisModuleType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mainPortController.dispose();
    _secondaryPortController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final mainPort = int.parse(_mainPortController.text.trim());
    final secondaryPort = _secondaryPortController.text.trim().isEmpty
        ? null
        : int.parse(_secondaryPortController.text.trim());

    final confirmed = await ConfigConfirmDialog.show(
      context,
      deviceName: _nameController.text.trim(),
      mainPort: mainPort,
      secondaryPort: secondaryPort,
      aisType: _selectedAisType,
    );

    if (!confirmed || !mounted) return;

    context.read<DeviceConfigCubit>().submitConfig(
          imei: widget.device.imei,
          stationName: _nameController.text.trim(),
          mainUdpPort: mainPort,
          secondaryUdpPort: secondaryPort,
          aisDeviceType: _selectedAisType,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cấu hình 4G (M03)', style: AppTextStyles.titleMediumAppBar()),
      ),
      body: BlocBuilder<DeviceConfigCubit, DeviceConfigState>(
        builder: (context, state) {
          final isBusy = state.status == ConfigSubmissionStatus.sending ||
              state.status == ConfigSubmissionStatus.sent;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trạng thái cấu hình:',
                        style: AppTextStyles.titleMediumBlack(),
                      ),
                      ConfigStatusChip(status: state.status),
                    ],
                  ),
                  if (state.message != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      state.message!,
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                  SizedBox(height: 20.h),
                  AppTextField(
                    label: 'Tên thiết bị 4G (DC-01)',
                    controller: _nameController,
                    validator: Validators.validateDeviceName,
                  ),
                  SizedBox(height: 14.h),
                  AppTextField(
                    label: 'UDP Port chính (DC-02)',
                    controller: _mainPortController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        Validators.validateUdpPort(v, required: true),
                  ),
                  SizedBox(height: 14.h),
                  AppTextField(
                    label: 'UDP Port phụ (DC-03)',
                    controller: _secondaryPortController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        Validators.validateUdpPort(v, required: false),
                  ),
                  SizedBox(height: 14.h),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAisType,
                    decoration: InputDecoration(
                      labelText: 'Loại thiết bị AIS kết nối (DC-04)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    items: _aisDeviceTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type, style: AppTextStyles.bodyMedium()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedAisType = value);
                      }
                    },
                  ),
                  SizedBox(height: 24.h),
                  AppButton(
                    label: 'Lưu và Gửi cấu hình (DC-05)',
                    icon: Icons.send,
                    isLoading: isBusy,
                    onPressed: _onSubmit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
