import '../models/member_model.dart';

abstract class MemberRemoteDataSource {
  Future<List<MemberModel>> getMembers();
  Future<void> createMember(MemberModel member);
  Future<void> updateMember(MemberModel member);
  Future<void> deleteMember(int userId);
}
