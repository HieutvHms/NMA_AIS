import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/text_style.dart';
import '../../../domain/entities/device_entity.dart';

class DeviceTableView extends StatefulWidget {
  final List<DeviceEntity> devices;
  final ValueChanged<DeviceEntity>? onSelect;

  const DeviceTableView({super.key, required this.devices, this.onSelect});

  @override
  State<DeviceTableView> createState() => _DeviceTableViewState();
}

class _DeviceTableViewState extends State<DeviceTableView> {
  late final ScrollController _leftVerticalController;
  late final ScrollController _rightVerticalController;
  late final ScrollController _horizontalController;
  bool _isSyncing = false;

  final DateFormat _dateFormat = DateFormat('HH:mm:ss dd-MM-yyyy');

  double get colSttWidth => 50.w;
  double get colNameWidth => 130.w;
  double get colImeiWidth => 148.w;
  double get colSimWidth => 195.w;
  double get colPortWidth => 170.w;
  double get colStatusWidth => 100.w;
  double get colLastMsgWidth => 200.w;
  double get colLastAisWidth => 200.w;
  double get colSignalWidth => 130.w;
  double get colModuleWidth => 130.w;
  double get colActionWidth => 105.w;

  double get rowHeight => 40.h;
  double get headerHeight => 42.h;

  @override
  void initState() {
    super.initState();
    _leftVerticalController = ScrollController();
    _rightVerticalController = ScrollController();
    _horizontalController = ScrollController();

    _leftVerticalController.addListener(() {
      if (_isSyncing) return;
      if (!_rightVerticalController.hasClients ||
          !_leftVerticalController.hasClients) {
        return;
      }
      final target = _leftVerticalController.offset.clamp(
        0.0,
        _rightVerticalController.position.maxScrollExtent,
      );
      if ((_rightVerticalController.offset - target).abs() > 0.5) {
        _isSyncing = true;
        _rightVerticalController.jumpTo(target);
        _isSyncing = false;
      }
    });

    _rightVerticalController.addListener(() {
      if (_isSyncing) return;
      if (!_leftVerticalController.hasClients ||
          !_rightVerticalController.hasClients) {
        return;
      }
      final target = _rightVerticalController.offset.clamp(
        0.0,
        _leftVerticalController.position.maxScrollExtent,
      );
      if ((_leftVerticalController.offset - target).abs() > 0.5) {
        _isSyncing = true;
        _leftVerticalController.jumpTo(target);
        _isSyncing = false;
      }
    });
  }

  @override
  void dispose() {
    _leftVerticalController.dispose();
    _rightVerticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  Widget _buildHeaderCell(
    String text,
    double width, {
    bool isCenter = false,
    bool showBorderRight = true,
  }) {
    return Container(
      width: width,
      height: headerHeight,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        border: Border(
          right: showBorderRight
              ? BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.0,
                )
              : BorderSide.none,
          bottom: const BorderSide(color: Color(0xFF1565C0), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: isCenter
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.s12w600(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(
    Widget child,
    double width,
    bool isEven, {
    bool isCenter = false,
    bool showBorderRight = true,
  }) {
    return Container(
      width: width,
      height: rowHeight,
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF8FAFC),
        border: Border(
          bottom: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          right: showBorderRight
              ? const BorderSide(color: Color(0xFFE2E8F0), width: 1.0)
              : BorderSide.none,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.devices.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu thiết bị',
          style: AppTextStyles.s14w500(color: AppColors.textSecondary),
        ),
      );
    }

    final double totalRightWidth =
        colImeiWidth +
        colSimWidth +
        colPortWidth +
        colStatusWidth +
        colLastMsgWidth +
        colLastAisWidth +
        colSignalWidth +
        colModuleWidth +
        colActionWidth;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFCBD5E1), width: 1.0)),
      ),
      child: Row(
        children: [
          // 1. Khối 2 cột cố định bên trái (STT + Tên trạm)
          SizedBox(
            width: colSttWidth + colNameWidth,
            child: Column(
              children: [
                // Header cố định bên trái
                Row(
                  children: [
                    _buildHeaderCell('STT', colSttWidth, isCenter: true),
                    _buildHeaderCell('Tên trạm', colNameWidth),
                  ],
                ),
                // Data list cố định bên trái
                Expanded(
                  child: ListView.builder(
                    controller: _leftVerticalController,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: widget.devices.length,
                    itemBuilder: (context, index) {
                      final item = widget.devices[index];
                      final isEven = index % 2 == 0;
                      final rowWidget = Row(
                        children: [
                          _buildDataCell(
                            Text(
                              '${index + 1}',
                              style: AppTextStyles.s13w500(),
                            ),
                            colSttWidth,
                            isEven,
                            isCenter: true,
                          ),
                          _buildDataCell(
                            Text(
                              item.stationName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.s13w500(),
                            ),
                            colNameWidth,
                            isEven,
                          ),
                        ],
                      );
                      if (widget.onSelect != null) {
                        return InkWell(
                          onTap: () => widget.onSelect!(item),
                          child: rowWidget,
                        );
                      }
                      return rowWidget;
                    },
                  ),
                ),
              ],
            ),
          ),

          // 2. Khối các cột cuộn ngang bên phải
          Expanded(
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalRightWidth,
                child: Column(
                  children: [
                    // Header các cột cuộn ngang
                    Row(
                      children: [
                        _buildHeaderCell('IMEI', colImeiWidth),
                        _buildHeaderCell('Serial SIM', colSimWidth),
                        _buildHeaderCell(
                          'Cổng nhận dữ liệu AIS',
                          colPortWidth,
                          isCenter: true,
                        ),
                        _buildHeaderCell(
                          'Trạng thái',
                          colStatusWidth,
                          isCenter: true,
                        ),
                        _buildHeaderCell(
                          'Thời gian gửi tin gần nhất',
                          colLastMsgWidth,
                        ),
                        _buildHeaderCell(
                          'Thời gian nhận AIS gần nhất',
                          colLastAisWidth,
                        ),
                        _buildHeaderCell(
                          'Cường độ sóng',
                          colSignalWidth,
                          isCenter: true,
                        ),
                        _buildHeaderCell('Loại module AIS', colModuleWidth),
                      ],
                    ),
                    // Danh sách dữ liệu các cột cuộn ngang
                    Expanded(
                      child: ListView.builder(
                        controller: _rightVerticalController,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: widget.devices.length,
                        itemBuilder: (context, index) {
                          final item = widget.devices[index];
                          final isEven = index % 2 == 0;
                          final rowWidget = Row(
                            children: [
                              _buildDataCell(
                                Text(item.imei, style: AppTextStyles.s13w500()),
                                colImeiWidth,
                                isEven,
                              ),
                              _buildDataCell(
                                Text(
                                  item.simSerial.isEmpty ? '-' : item.simSerial,
                                  style: AppTextStyles.s13w500(),
                                ),
                                colSimWidth,
                                isEven,
                              ),
                              _buildDataCell(
                                Text(
                                  '${item.aisPort}',
                                  style: AppTextStyles.s13w500(),
                                ),
                                colPortWidth,
                                isEven,
                                isCenter: true,
                              ),
                              _buildDataCell(
                                Text(
                                  item.status.label,
                                  style: AppTextStyles.s13w500(
                                    color: item.status == DeviceStatus.online
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                                colStatusWidth,
                                isEven,
                                isCenter: true,
                              ),
                              _buildDataCell(
                                Text(
                                  item.lastMessageTime != null
                                      ? _dateFormat.format(
                                          item.lastMessageTime!,
                                        )
                                      : '-',
                                  style: AppTextStyles.s13w500(),
                                ),
                                colLastMsgWidth,
                                isEven,
                              ),
                              _buildDataCell(
                                Text(
                                  item.lastAisTime != null
                                      ? _dateFormat.format(item.lastAisTime!)
                                      : '00:00:00 01-01-2000',
                                  style: AppTextStyles.s13w500(),
                                ),
                                colLastAisWidth,
                                isEven,
                              ),
                              _buildDataCell(
                                Text(
                                  '${item.signalStrength}',
                                  style: AppTextStyles.s13w500(),
                                ),
                                colSignalWidth,
                                isEven,
                                isCenter: true,
                              ),
                              _buildDataCell(
                                Text(
                                  item.aisModuleType,
                                  style: AppTextStyles.s13w500(),
                                ),
                                colModuleWidth,
                                isEven,
                              ),
                            ],
                          );
                          if (widget.onSelect != null) {
                            return InkWell(
                              onTap: () => widget.onSelect!(item),
                              child: rowWidget,
                            );
                          }
                          return rowWidget;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
