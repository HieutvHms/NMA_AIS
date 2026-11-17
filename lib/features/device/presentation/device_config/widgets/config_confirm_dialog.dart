import 'package:flutter/material.dart';

class ConfigConfirmDialog extends StatelessWidget {
  final String deviceName;
  final int mainPort;
  final int? secondaryPort;
  final String aisType;

  const ConfigConfirmDialog({
    super.key,
    required this.deviceName,
    required this.mainPort,
    this.secondaryPort,
    required this.aisType,
  });

  static Future<bool> show(
    BuildContext context, {
    required String deviceName,
    required int mainPort,
    int? secondaryPort,
    required String aisType,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfigConfirmDialog(
        deviceName: deviceName,
        mainPort: mainPort,
        secondaryPort: secondaryPort,
        aisType: aisType,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận cấu hình 4G'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vui lòng kiểm tra thông tin trước khi gửi xuống thiết bị:'),
          const SizedBox(height: 12),
          _buildRow('Tên thiết bị:', deviceName),
          _buildRow('UDP Port chính:', '$mainPort'),
          _buildRow(
            'UDP Port phụ:',
            secondaryPort != null ? '$secondaryPort' : 'Chưa cấu hình',
          ),
          _buildRow('Loại thiết bị AIS:', aisType),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Xác nhận gửi'),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

