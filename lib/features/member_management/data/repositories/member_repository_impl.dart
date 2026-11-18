import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/member_repository.dart';
import '../datasources/member_remote_datasource.dart';
import '../models/member_model.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<MemberEntity>> getMembers() {
    return _remoteDataSource.getMembers();
  }

  @override
  Future<void> createMember(MemberEntity member) {
    return _remoteDataSource.createMember(MemberModel.fromEntity(member));
  }

  @override
  Future<void> updateMember(MemberEntity member) {
    return _remoteDataSource.updateMember(MemberModel.fromEntity(member));
  }

  @override
  Future<void> deleteMember(int userId) {
    return _remoteDataSource.deleteMember(userId);
  }
}
