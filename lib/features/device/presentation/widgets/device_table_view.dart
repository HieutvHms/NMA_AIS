import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_style.dart';
import '../../domain/entities/device_entity.dart';

class DeviceTableView extends StatefulWidget {
  final List<DeviceEntity> devices;
  final ValueChanged<DeviceEntity> onEdit;
  final ValueChanged<DeviceEntity> onDelete;
  final ValueChanged<DeviceEntity> onSelect;

  const DeviceTableView({
    super.key,
    required this.devices,
    required this.onEdit,
    required this.onDelete,
    required this.onSelect,
  });

  @override
  State<DeviceTableView> createState() => _DeviceTableViewState();
}

class _DeviceTableViewState extends State<DeviceTableView> {
  late final ScrollController _leftVerticalController;
  late final ScrollController _rightVerticalController;
  late final ScrollController _horizontalController;
  bool _isSyncing = false;

  final DateFormat _dateFormat = DateFormat('HH:mm:ss dd-MM-yyyy');

  // Chiều rộng các cột
  static final double colSttWidth = 44.w;
  static final double colNameWidth = 135.w;
  static final double colImeiWidth = 148.w;
  static final double colSimWidth = 180.w;
  static final double colPortWidth = 95.w;
  static final double colStatusWidth = 100.w;
  static final double colLastMsgWidth = 155.w;
  static final double colLastAisWidth = 155.w;
  static final double colSignalWidth = 95.w;
  static final double colModuleWidth = 145.w;
  static final double colActionWidth = 105.w;

  static final double rowHeight = 40.h;
  static final double headerHeight = 42.h;

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
      padding: EdgeInsets.symmetric(horizontal: 8.w),
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
              style: AppTextStyles.titleSmall3(color: Colors.white),
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
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF8FAFC),
        border: Border(
          // Đường kẻ ngang ngăn cách giữa các hàng
          bottom: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
          // Đường kẻ dọc ngăn cách giữa các cột
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
          style: AppTextStyles.bodyMedium(color: AppColors.textHint),
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
                      return InkWell(
                        onTap: () => widget.onSelect(item),
                        child: Row(
                          children: [
                            _buildDataCell(
                              Text(
                                '${index + 1}',
                                style: AppTextStyles.body13(),
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
                                style: AppTextStyles.body13(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              colNameWidth,
                              isEven,
                            ),
                          ],
                        ),
                      );
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
                        _buildHeaderCell(
                          'Thao tác',
                          colActionWidth,
                          isCenter: true,
                          showBorderRight: false,
                        ),
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
                          return InkWell(
                            onTap: () => widget.onSelect(item),
                            child: Row(
                              children: [
                                _buildDataCell(
                                  Text(
                                    item.imei,
                                    style: AppTextStyles.body13(),
                                  ),
                                  colImeiWidth,
                                  isEven,
                                ),
                                _buildDataCell(
                                  Text(
                                    item.simSerial.isEmpty
                                        ? '-'
                                        : item.simSerial,
                                    style: AppTextStyles.body13(),
                                  ),
                                  colSimWidth,
                                  isEven,
                                ),
                                _buildDataCell(
                                  Text(
                                    '${item.aisPort}',
                                    style: AppTextStyles.body13(),
                                  ),
                                  colPortWidth,
                                  isEven,
                                  isCenter: true,
                                ),
                                _buildDataCell(
                                  Text(
                                    item.status.label,
                                    style: AppTextStyles.labelSmall(
                                      color: item.status == DeviceStatus.online
                                          ? const Color(0xFF2E7D32)
                                          : (item.status ==
                                                    DeviceStatus.maintenance
                                                ? const Color(0xFFED6C02)
                                                : const Color(0xFFD32F2F)),
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
                                    style: AppTextStyles.body13(),
                                  ),
                                  colLastMsgWidth,
                                  isEven,
                                ),
                                _buildDataCell(
                                  Text(
                                    item.lastAisTime != null
                                        ? _dateFormat.format(item.lastAisTime!)
                                        : '00:00:00 01-01-2000',
                                    style: AppTextStyles.body13(),
                                  ),
                                  colLastAisWidth,
                                  isEven,
                                ),
                                _buildDataCell(
                                  Text(
                                    '${item.signalStrength}',
                                    style: AppTextStyles.body13(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  colSignalWidth,
                                  isEven,
                                  isCenter: true,
                                ),
                                _buildDataCell(
                                  Text(
                                    item.aisModuleType,
                                    style: AppTextStyles.body13(),
                                  ),
                                  colModuleWidth,
                                  isEven,
                                ),
                                _buildDataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () => widget.onEdit(item),
                                        borderRadius: BorderRadius.circular(6.r),
                                        child: Padding(
                                          padding: EdgeInsets.all(6.r),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: 18.r,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      InkWell(
                                        onTap: () => widget.onDelete(item),
                                        borderRadius: BorderRadius.circular(6.r),
                                        child: Padding(
                                          padding: EdgeInsets.all(6.r),
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: 18.r,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  colActionWidth,
                                  isEven,
                                  isCenter: true,
                                  showBorderRight: false,
                                ),
                              ],
                            ),
                          );
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
