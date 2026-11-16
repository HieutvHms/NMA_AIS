import 'package:flutter/material.dart';

class BuoyConfigScreen extends StatelessWidget {
  final String deviceId;

  const BuoyConfigScreen({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cấu hình Phao AIS (M05)')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chức năng cấu hình phao (M05)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Đang chờ xác nhận đặc tả chi tiết từ đối tác (MMSI phao, Tên phao, Loại phao, Vị trí phao, Trạng thái phao).',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

