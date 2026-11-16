import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/commom/inputs/app_search_bar.dart';
import 'package:go_router/go_router.dart';
import '../../cubit/monitoring_cubit.dart';
import '../../cubit/monitoring_state.dart';
import '../../data/models/vessel_model.dart';
import '../widgets/port_filter_bottom_sheet.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MonitoringCubit>().loadData();
  }

  void _openPortFilter(MonitoringState state) {
    showModalBottomSheet(
      context: context,
      builder: (_) => PortFilterBottomSheet(
        allowedPorts: state.allowedPorts,
        selectedPort: state.selectedPort,
        onPortSelected: (port) {
          context.read<MonitoringCubit>().loadData(
            selectedPort: port,
            clearPort: port == null,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BlocBuilder<MonitoringCubit, MonitoringState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Giám sát AIS (M06)'),
              actions: [
                TextButton.icon(
                  onPressed: () => _openPortFilter(state),
                  icon: const Icon(Icons.filter_list),
                  label: Text(
                    state.selectedPort != null
                        ? 'Port ${state.selectedPort}'
                        : 'Tất cả Port',
                  ),
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Tàu (MON-01)'),
                  Tab(text: 'Phao AIS (MON-02)'),
                ],
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: AppSearchBar(
                    hintText: 'Tìm kiếm theo MMSI hoặc tên...',
                    onChanged: (q) =>
                        context.read<MonitoringCubit>().loadData(query: q),
                  ),
                ),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          children: [
                            _buildList(context, state.vessels),
                            _buildList(context, state.buoys),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<VesselModel> list) {
    if (list.isEmpty) {
      return const Center(child: Text('Không có dữ liệu thu nhận.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          child: ListTile(
            leading: Icon(
              item.isBuoy ? Icons.anchor : Icons.directions_boat,
              color: Colors.blueAccent,
            ),
            title: Text(
              '${item.name} (${item.mmsi})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Tọa độ: ${item.latitude}, ${item.longitude} • Port: ${item.udpPort}',
            ),
            onTap: () =>
                context.push('/monitoring/detail/${item.mmsi}', extra: item),
          ),
        );
      },
    );
  }
}
