import '../entities/member_entity.dart';
import '../repositories/member_repository.dart';

/// UseCase cập nhật thông tin thành viên (`POST /user/update` type: 2).
class UpdateMemberUseCase {
  final MemberRepository _repository;

  UpdateMemberUseCase(this._repository);

  Future<void> call(MemberEntity member) {
    return _repository.updateMember(member);
  }
}
