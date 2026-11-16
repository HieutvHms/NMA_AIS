import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/commom/buttons/app_button.dart';
import '../../data/models/vessel_model.dart';

class VesselDetailScreen extends StatelessWidget {
  final VesselModel vessel;

  const VesselDetailScreen({super.key, required this.vessel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vessel.isBuoy ? 'Chi tiết Phao AIS' : 'Chi tiết Tàu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('MMSI', vessel.mmsi),
                    const Divider(),
                    _row('Tên', vessel.name),
                    if (vessel.isBuoy && vessel.atonType != null) ...[
                      const Divider(),
                      _row('Loại phao (AtoN Type)', vessel.atonType!),
                    ],
                    const Divider(),
                    _row('Vĩ độ (Latitude)', '${vessel.latitude}'),
                    const Divider(),
                    _row('Kinh độ (Longitude)', '${vessel.longitude}'),
                    if (!vessel.isBuoy) ...[
                      const Divider(),
                      _row('Tốc độ (Speed)', '${vessel.speed ?? 0} kn'),
                      const Divider(),
                      _row('Hướng (Course)', '${vessel.course ?? 0}°'),
                    ],
                    const Divider(),
                    _row('UDP Port', '${vessel.udpPort}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!vessel.isBuoy)
              AppButton(
                label: 'Xem lộ trình di chuyển (M07)',
                icon: Icons.route,
                onPressed: () =>
                    context.push('/monitoring/route/${vessel.mmsi}'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

