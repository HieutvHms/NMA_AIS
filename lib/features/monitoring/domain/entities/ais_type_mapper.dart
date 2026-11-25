/// Nhóm phân loại đối tượng hiển thị trên bản đồ AIS.
enum AisTargetKind {
  /// Trạm gốc (Type 4) và AtoN - Phao, đèn biển (Type 21)
  stationOrAton,

  /// Tàu thuyền các loại (Type 1, 2, 3, 18, 19, 24, ...)
  vessel,
}

/// Nơi duy nhất quy định mapping giữa loại bản tin AIS (Type) và cách hiển thị.
/// Khi nghiệp vụ thay đổi quy tắc phân loại icon, chỉ cần chỉnh tại file này.
class AisTypeMapper {
  AisTypeMapper._();

  /// Danh sách mã Type được xem là Trạm gốc hoặc Phao báo hiệu hàng hải (AtoN).
  static const Set<int> stationOrAtonTypes = {
    4, // Base Station Report (Trạm gốc)
    21, // Aid-to-Navigation Report (AtoN: Phao, đèn biển)
  };

  /// Xác định nhóm đối tượng để chọn icon marker tương ứng.
  static AisTargetKind resolveKind(int type) {
    return stationOrAtonTypes.contains(type)
        ? AisTargetKind.stationOrAton
        : AisTargetKind.vessel;
  }

  /// Kiểm tra nhanh đối tượng có phải Trạm / Phao AtoN hay không.
  static bool isStationOrAton(int type) =>
      resolveKind(type) == AisTargetKind.stationOrAton;

  /// Nhãn ngắn gọn dùng cho bảng / danh sách.
  static String shortLabel(int type) => 'Type $type';

  /// Nhãn mô tả chi tiết loại bản tin AIS dùng cho màn hình chi tiết (Bottom Sheet).
  static String detailLabel(int type) {
    return switch (type) {
      4 => 'Type 4 (Trạm gốc)',
      21 => 'Type 21 (Phao / Đèn biển AtoN)',
      1 || 2 || 3 => 'Type $type (Tàu Class A)',
      18 || 19 => 'Type $type (Tàu Class B)',
      24 => 'Type 24 (Dữ liệu tĩnh)',
      _ => 'Type $type (Tàu thuyền)',
    };
  }
}
