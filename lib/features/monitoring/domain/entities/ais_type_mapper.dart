/// Nhóm phân loại đối tượng hiển thị trên bản đồ AIS.
enum AisTargetKind {
  stationOrAton,

  /// Tàu thuyền các loại (Type 1, 2, 3, 18, 19, 24, ...)
  vessel,
}

class AisTypeMapper {
  AisTypeMapper._();

  static const Set<int> stationOrAtonTypes = {4, 6, 21};

  static AisTargetKind resolveKind(int type) {
    return stationOrAtonTypes.contains(type)
        ? AisTargetKind.stationOrAton
        : AisTargetKind.vessel;
  }

  static bool isStationOrAton(int type) =>
      resolveKind(type) == AisTargetKind.stationOrAton;

  static String detailLabel(int type) {
    return switch (type) {
      4 => 'Type 4 (Trạm gốc)',
      6 => 'Type 6 (Giám sát phao / đèn AtoN)',
      21 => 'Type 21 (Phao / Đèn biển AtoN)',
      1 || 2 || 3 => 'Type $type (Tàu Class A)',
      18 || 19 => 'Type $type (Tàu Class B)',
      24 => 'Type 24 (Dữ liệu tĩnh)',
      _ => 'Type $type (Tàu thuyền)',
    };
  }
}
