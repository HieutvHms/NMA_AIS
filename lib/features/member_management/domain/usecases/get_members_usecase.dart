import '../entities/member_entity.dart';
import '../repositories/member_repository.dart';

/// UseCase lấy danh sách thành viên.
class GetMembersUseCase {
  final MemberRepository _repository;

  GetMembersUseCase(this._repository);

  Future<List<MemberEntity>> call() {
    return _repository.getMembers();
  }
}

