import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/text_style.dart';

class AisDeviceTableRow {
  final String stationName;
  final String imei;
  final String mmsi;
  final String simSerial;
  final int aisPort;
  final String statusLabel;
  final Color statusColor;
  final DateTime? lastMessageTime;
  final DateTime? lastAisTime;
  final int signalStrength;
  final String aisModuleType;

  const AisDeviceTableRow({
    required this.stationName,
    required this.imei,
    required this.mmsi,
    required this.simSerial,
    required this.aisPort,
    required this.statusLabel,
    required this.statusColor,
    this.lastMessageTime,
    this.lastAisTime,
    required this.signalStrength,
    required this.aisModuleType,
  });
}

class AisDeviceTableView<T> extends StatefulWidget {
  final List<T> items;
  final AisDeviceTableRow Function(T item) rowBuilder;
  final bool showActions;
  final bool showStatus;
  final bool showSignal;
  final String emptyMessage;
  final ValueChanged<T>? onSelect;
  final ValueChanged<T>? onEdit;
  final ValueChanged<T>? onDelete;

  const AisDeviceTableView({
    super.key,
    required this.items,
    required this.rowBuilder,
    this.showActions = false,
    this.showStatus = true,
    this.showSignal = true,
    this.emptyMessage = 'Không có dữ liệu trạm thu AIS',
    this.onSelect,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<AisDeviceTableView<T>> createState() => _AisDeviceTableViewState<T>();
}

class _AisDeviceTableViewState<T> extends State<AisDeviceTableView<T>> {
  late final ScrollController _leftVerticalController;
  late final ScrollController _rightVerticalController;
  late final ScrollController _horizontalController;
  bool _isSyncing = false;

  final DateFormat _dateFormat = DateFormat('HH:mm:ss dd-MM-yyyy');

  double get colSttWidth => 50.w;
  double get colNameWidth => 130.w;
  double get colImeiWidth => 150.w;
  double get colMmsiWidth => 100.w;
  double get colSimWidth => 200.w;
  double get colPortWidth => 90.w;
  double get colStatusWidth => 100.w;
  double get colLastMsgWidth => 170.w;
  double get colLastAisWidth => 170.w;
  double get colSignalWidth => 120.w;
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
        color: AppColors.primary,
        border: Border(
          right: showBorderRight
              ? BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.0,
                )
              : BorderSide.none,
          bottom: BorderSide(color: AppColors.primary, width: 1.0),
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
              style: AppTextStyles.s11w600(color: AppColors.textWhite),
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

  Widget _wrapRowTap(T item, Widget child) {
    if (widget.onSelect == null) return child;
    return InkWell(onTap: () => widget.onSelect!(item), child: child);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Center(
        child: Text(
          widget.emptyMessage,
          style: AppTextStyles.s14w500(color: AppColors.textSecondary),
        ),
      );
    }

    final double totalRightWidth =
        colImeiWidth +
        colMmsiWidth +
        colSimWidth +
        colPortWidth +
        (widget.showStatus ? colStatusWidth : 0) +
        colLastMsgWidth +
        colLastAisWidth +
        (widget.showSignal ? colSignalWidth : 0) +
        colModuleWidth +
        (widget.showActions ? colActionWidth : 0);

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
                Row(
                  children: [
                    _buildHeaderCell('STT', colSttWidth, isCenter: true),
                    _buildHeaderCell('Tên trạm', colNameWidth, isCenter: true),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _leftVerticalController,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final row = widget.rowBuilder(item);
                      final isEven = index % 2 == 0;
                      return _wrapRowTap(
                        item,
                        Row(
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
                                row.stationName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.s13w500(),
                              ),
                              colNameWidth,
                              isEven,
                              isCenter: true,
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
                    Row(
                      children: [
                        _buildHeaderCell('IMEI', colImeiWidth, isCenter: true),
                        _buildHeaderCell('MMSI', colMmsiWidth, isCenter: true),
                        _buildHeaderCell(
                          'Serial SIM',
                          colSimWidth,
                          isCenter: true,
                        ),
                        _buildHeaderCell(
                          'Cổng AIS',
                          colPortWidth,
                          isCenter: true,
                        ),
                        if (widget.showStatus)
                          _buildHeaderCell(
                            'Trạng thái',
                            colStatusWidth,
                            isCenter: true,
                          ),
                        _buildHeaderCell(
                          'Thời gian gửi tin gần nhất',
                          colLastMsgWidth,
                          isCenter: true,
                        ),
                        _buildHeaderCell(
                          'Thời gian nhận AIS gần nhất',
                          colLastAisWidth,
                          isCenter: true,
                        ),
                        if (widget.showSignal)
                          _buildHeaderCell(
                            'Cường độ sóng',
                            colSignalWidth,
                            isCenter: true,
                          ),
                        _buildHeaderCell(
                          'Loại module AIS',
                          colModuleWidth,
                          isCenter: true,
                          showBorderRight: widget.showActions,
                        ),
                        if (widget.showActions)
                          _buildHeaderCell(
                            'Thao tác',
                            colActionWidth,
                            isCenter: true,
                            showBorderRight: false,
                          ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _rightVerticalController,
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: widget.items.length,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final row = widget.rowBuilder(item);
                          final isEven = index % 2 == 0;
                          return _wrapRowTap(
                            item,
                            Row(
                              children: [
                                _buildDataCell(
                                  Text(
                                    row.imei,
                                    style: AppTextStyles.s13w500(),
                                    textAlign: TextAlign.center,
                                  ),
                                  colImeiWidth,
                                  isEven,
                                  isCenter: true,
                                ),
                                _buildDataCell(
                                  Text(
                                    row.mmsi.isEmpty ? '-' : row.mmsi,
                                    style: AppTextStyles.s13w500(),
                                    textAlign: TextAlign.center,
                                  ),
                                  colMmsiWidth,
                                  isEven,
                                  isCenter: true,
                                ),
                                _buildDataCell(
                                  Text(
                                    row.simSerial.isEmpty ? '-' : row.simSerial,
                                    style: AppTextStyles.s13w500(),
                                    textAlign: TextAlign.center,
                                  ),
                                  colSimWidth,
                                  isEven,
                                  isCenter: true,
                                ),
                                _buildDataCell(
                                  Text(
                                    '${row.aisPort}',
                                    style: AppTextStyles.s13w500(),
                                    textAlign: TextAlign.center,
                                  ),
                                  colPortWidth,
                                  isEven,
                                  isCenter: true,
                                ),
                                if (widget.showStatus)
                                  _buildDataCell(
                                    Text(
                                      row.statusLabel,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.s12w500(
                                        color: row.statusColor,
                                      ),
                                    ),
                                    colStatusWidth,
                                    isEven,
                                    isCenter: true,
                                  ),
                                _buildDataCell(
                                  Text(
                                    row.lastMessageTime != null
                                        ? _dateFormat.format(
                                            row.lastMessageTime!,
                                          )
                                        : '-',
                                    style: AppTextStyles.s12w500(),
                                    textAlign: TextAlign.center,
                                  ),
                                  colLastMsgWidth,
                                  isEven,
                                  isCenter: true,
                                ),
                                _buildDataCell(
                                  Text(
                                    row.lastAisTime != null
                                        ? _dateFormat.format(row.lastAisTime!)
                                        : '00:00:00 01-01-2000',
                                    style: AppTextStyles.s12w500(),
                                    textAlign: TextAlign.center,
                                  ),
                                  colLastAisWidth,
                                  isEven,
                                  isCenter: true,
                                ),
                                if (widget.showSignal)
                                  _buildDataCell(
                                    Text(
                                      '${row.signalStrength}',
                                      style: AppTextStyles.s12w500(),
                                      textAlign: TextAlign.center,
                                    ),
                                    colSignalWidth,
                                    isEven,
                                    isCenter: true,
                                  ),
                                _buildDataCell(
                                  Text(
                                    row.aisModuleType,
                                    style: AppTextStyles.s13w500(),
                                    textAlign: TextAlign.center,
                                  ),
                                  colModuleWidth,
                                  isEven,
                                  isCenter: true,
                                  showBorderRight: widget.showActions,
                                ),
                                if (widget.showActions)
                                  _buildDataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Material(
                                          color: const Color(0xFFE8F1FC),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          child: InkWell(
                                            onTap: () =>
                                                widget.onEdit?.call(item),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(7.r),
                                              child: SvgPicture.asset(
                                                'assets/icons/device/ic_edit.svg',
                                                width: 16.r,
                                                height: 16.r,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                      AppColors.primary,
                                                      BlendMode.srcIn,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Material(
                                          color: const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          child: InkWell(
                                            onTap: () =>
                                                widget.onDelete?.call(item),
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(7.r),
                                              child: SvgPicture.asset(
                                                'assets/icons/device/ic_delete.svg',
                                                width: 16.r,
                                                height: 16.r,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                      Color(0xFFDC2626),
                                                      BlendMode.srcIn,
                                                    ),
                                              ),
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
