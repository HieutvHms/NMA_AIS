import 'package:flutter/material.dart';

class PortFilterBottomSheet extends StatelessWidget {
  final List<int> allowedPorts;
  final int? selectedPort;
  final ValueChanged<int?> onPortSelected;

  const PortFilterBottomSheet({
    super.key,
    required this.allowedPorts,
    required this.selectedPort,
    required this.onPortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text(
              'Lọc dữ liệu theo UDP Port (MON-03)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(
              selectedPort == null
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
            ),
            title: const Text('Tất cả các Port được cấp quyền'),
            onTap: () {
              onPortSelected(null);
              Navigator.pop(context);
            },
          ),
          ...allowedPorts.map(
            (port) => ListTile(
              leading: Icon(
                selectedPort == port
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text('UDP Port $port'),
              onTap: () {
                onPortSelected(port);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

