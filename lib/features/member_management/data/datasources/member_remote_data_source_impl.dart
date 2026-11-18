import 'package:dio/dio.dart';
import '../../../../core/base/base_remote_datasource.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../models/member_model.dart';
import 'member_remote_datasource.dart';

class MemberRemoteDataSourceImpl extends BaseRemoteDataSource
    implements MemberRemoteDataSource {
  final LocalStorage _localStorage;

  MemberRemoteDataSourceImpl(super.dio, this._localStorage);

  int get _currentUserId {
    final rawUserId = _localStorage.getUserId();
    return int.tryParse(rawUserId ?? '') ?? 0;
  }

  Future<dynamic> _safePost(String url, Map<String, dynamic> body) async {
    try {
      final response = await post(url, data: body);
      if (response is Map<String, dynamic> && response['success'] == false) {
        final message = response['message']?.toString().trim();
        throw ServerException(
          message: (message != null && message.isNotEmpty)
              ? message
              : 'Thao tác thất bại.',
        );
      }
      return response;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map &&
          data['message'] != null &&
          data['message'].toString().trim().isNotEmpty) {
        throw ServerException(
          message: data['message'].toString().trim(),
          statusCode: e.response?.statusCode,
        );
      } else if (data is String && data.trim().isNotEmpty) {
        throw ServerException(
          message: data.trim(),
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  @override
  Future<List<MemberModel>> getMembers() async {
    final currentUserId = _currentUserId;

    // Chỉ lấy danh sách thành viên con theo parentId (type: 2), không lấy thông tin Admin
    final response = await _safePost(AppConfig.userQueryUrl, {
      'type': 2,
      'userId': currentUserId,
    });

    if (response is! Map<String, dynamic> || response['data'] is! List) {
      return [];
    }

    final rawList = response['data'] as List;
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(MemberModel.fromJson)
        .where((member) => member.userId != currentUserId)
        .toList();
  }

  @override
  Future<void> createMember(MemberModel member) async {
    await _safePost(AppConfig.userUpdateUrl, {
      'type': 1,
      'data': member.toCreateJson(),
    });
  }

  @override
  Future<void> updateMember(MemberModel member) async {
    await _safePost(AppConfig.userUpdateUrl, {
      'type': 2,
      'data': member.toUpdateJson(),
    });
  }

  @override
  Future<void> deleteMember(int userId) async {
    await _safePost(AppConfig.userUpdateUrl, {
      'type': 3,
      'data': {'userId': userId},
    });
  }
}
