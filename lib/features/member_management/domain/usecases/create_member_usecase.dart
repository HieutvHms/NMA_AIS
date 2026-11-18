import '../entities/member_entity.dart';
import '../repositories/member_repository.dart';

/// UseCase tạo mới thành viên (`POST /user/update` type: 1).
class CreateMemberUseCase {
  final MemberRepository _repository;

  CreateMemberUseCase(this._repository);

  Future<void> call(MemberEntity member) {
    return _repository.createMember(member);
  }
}
