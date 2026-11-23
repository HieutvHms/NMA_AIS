import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../app/commom/app_bar/searchable_app_bar.dart';
import '../../../../../app/commom/tables/ais_device_table_view.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../../../core/utils/snackbar_helper.dart';
import '../../../domain/entities/device_entity.dart';
import '../../device_list/cubit/device_list_cubit.dart';
import '../../device_list/cubit/device_list_state.dart';

class DeviceTableScreen extends StatefulWidget {
  const DeviceTableScreen({super.key});

  @override
  State<DeviceTableScreen> createState() => _DeviceTableScreenState();
}

class _DeviceTableScreenState extends State<DeviceTableScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DeviceListCubit>().loadDevices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SearchableAppBar(
        title: 'Bảng thiết bị',
        backgroundColor: AppColors.background,
        textColor: AppColors.textPrimary,
        titleStyle: AppTextStyles.s16w600(),
        searchHintText: 'Tìm kiếm',
        searchController: _searchController,
        searchBackgroundColor: Colors.white,
        searchBorder: Border.all(color: const Color(0xFFCBD5E1)),
        onSearch: (val) =>
            context.read<DeviceListCubit>().loadDevices(query: val),
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/devices');
          }
        },
      ),
      body: BlocConsumer<DeviceListCubit, DeviceListState>(
        listener: (context, state) {
          if (state is DeviceListError) {
            SnackbarHelper.showError(context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is DeviceListLoading || state is DeviceListInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DeviceListError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: AppTextStyles.s14w500()),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context
                        .read<DeviceListCubit>()
                        .loadDevices(forceRefresh: true),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }
          if (state is DeviceListLoaded) {
            return AisDeviceTableView<DeviceEntity>(
              items: state.devices,
              emptyMessage: 'Không có dữ liệu thiết bị',
              rowBuilder: (item) => AisDeviceTableRow(
                stationName: item.stationName,
                imei: item.imei,
                mmsi: item.mmsi,
                simSerial: item.simSerial,
                aisPort: item.aisPort,
                statusLabel: item.status.label,
                statusColor: item.status == DeviceStatus.online
                    ? const Color(0xFF15803D)
                    : (item.status == DeviceStatus.offline
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF64748B)),
                lastMessageTime: item.lastMessageTime,
                lastAisTime: item.lastAisTime,
                signalStrength: item.signalStrength,
                aisModuleType: item.aisModuleType,
              ),
              onSelect: (dev) =>
                  context.push('/devices/${dev.imei}', extra: dev),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
