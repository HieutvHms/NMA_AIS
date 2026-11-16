import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../app/commom/buttons/app_button.dart';
import '../../../../app/commom/inputs/app_text_field.dart';
import '../../cubit/ais_config_cubit.dart';
import '../../cubit/ais_config_state.dart';

class AisConfigScreen extends StatefulWidget {
  final String deviceId;

  const AisConfigScreen({super.key, required this.deviceId});

  @override
  State<AisConfigScreen> createState() => _AisConfigScreenState();
}

class _AisConfigScreenState extends State<AisConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mmsiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AisConfigCubit>().loadConfig(widget.deviceId);
  }

  @override
  void dispose() {
    _mmsiController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận cập nhật MMSI'),
        content: Text(
          'Bạn có chắc chắn muốn đổi MMSI thành ${_mmsiController.text.trim()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AisConfigCubit>().updateMmsi(
            widget.deviceId,
            _mmsiController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cấu hình AIS (M04)')),
      body: BlocConsumer<AisConfigCubit, AisConfigState>(
        listener: (context, state) {
          if (state.config != null && _mmsiController.text.isEmpty) {
            _mmsiController.text = state.config!.mmsi;
          }
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MMSI hiện tại: ${state.config?.mmsi ?? "Đang tải..."}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'MMSI mới (AIS-01)',
                    controller: _mmsiController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.validateMmsi,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Gửi cấu hình MMSI',
                    icon: Icons.save_outlined,
                    isLoading: state.isLoading,
                    onPressed: _confirmAndSubmit,
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

