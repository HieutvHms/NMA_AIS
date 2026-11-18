import '../entities/member_entity.dart';

/// Repository quản trị thành viên (chỉ dành cho Admin).
abstract class MemberRepository {
  /// Lấy danh sách thành viên thuộc quyền quản lý của Admin hiện tại.
  Future<List<MemberEntity>> getMembers();

  /// Tạo mới một thành viên con dưới quyền Admin hiện tại (`type: 1`).
  Future<void> createMember(MemberEntity member);

  /// Cập nhật thông tin thành viên (`type: 2`).
  Future<void> updateMember(MemberEntity member);

  /// Xoá thành viên theo `userId` (`type: 3`).
  Future<void> deleteMember(int userId);
}
