import '../repositories/member_repository.dart';

/// UseCase xoá thành viên (`POST /user/update` type: 3).
class DeleteMemberUseCase {
  final MemberRepository _repository;

  DeleteMemberUseCase(this._repository);

  Future<void> call(int userId) {
    return _repository.deleteMember(userId);
  }
}

