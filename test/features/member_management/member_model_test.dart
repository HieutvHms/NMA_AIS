import 'package:ais/features/member_management/data/models/member_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemberModel udpPort list serialization', () {
    test('fromJson parses list of strings for udpPort', () {
      final model = MemberModel.fromJson({
        'id': '64a000000000000000000001',
        'userId': 2,
        'username': 'user_demo',
        'email': 'demo@example.com',
        'name': 'Nguyễn Văn A',
        'phone': '0900000000',
        'role': 1,
        'parentId': 1,
        'udpPort': ['8001', ' 8002 ', ''],
        'createdAt': '2026-11-18T03:00:00Z',
      });

      expect(model.udpPort, ['8001', '8002']);
    });

    test('fromJson handles empty, null, or legacy string udpPort', () {
      expect(
        MemberModel.fromJson({'username': 'u1', 'udpPort': []}).udpPort,
        isEmpty,
      );
      expect(
        MemberModel.fromJson({'username': 'u2', 'udpPort': null}).udpPort,
        isEmpty,
      );
      expect(
        MemberModel.fromJson({'username': 'u3', 'udpPort': '8001, 8002'}).udpPort,
        ['8001', '8002'],
      );
    });

    test('toCreateJson and toUpdateJson send udpPort as List<String>', () {
      const model = MemberModel(
        userId: 5,
        username: 'user_con',
        password: 'secret',
        name: 'User con',
        email: 'usercon@example.com',
        phone: '0900000001',
        udpPort: [' 8002 ', '8003', ''],
      );

      final createJson = model.toCreateJson(1);
      expect(createJson['udpPort'], isA<List<String>>());
      expect(createJson['udpPort'], ['8002', '8003']);

      final updateJson = model.toUpdateJson();
      expect(updateJson['udpPort'], isA<List<String>>());
      expect(updateJson['udpPort'], ['8002', '8003']);
    });

    test('toCreateJson and toUpdateJson send empty list when no ports', () {
      const model = MemberModel(
        userId: 5,
        username: 'user_con',
      );

      expect(model.toCreateJson(1)['udpPort'], isEmpty);
      expect(model.toUpdateJson()['udpPort'], isEmpty);
    });
  });
}
