import 'package:dio/dio.dart';
import '../../../../core/base/base_remote_datasource.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl extends BaseRemoteDataSource
    implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(super.dio);

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final body = await post(
        AppConfig.loginUrl,
        data: {'username': username, 'password': password},
      );

      if (body is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Dữ liệu phản hồi không đúng định dạng',
        );
      }

      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ServerException(message: 'Không nhận được dữ liệu token');
      }

      final accessToken = data['accessToken']?.toString() ?? '';
      final refreshToken = data['refreshToken']?.toString();

      // Lấy userId trực tiếp từ response của BE
      final userId = data['userId']?.toString() ??
          data['id']?.toString() ??
          '1';

      return UserModel(
        id: userId,
        username: username,
        role: 'admin',
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final body = await post(
        AppConfig.refreshTokenUrl,
        data: {'refreshToken': refreshToken},
      );

      if (body is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Dữ liệu làm mới token không hợp lệ',
        );
      }

      final success = body['success'] == true;
      if (!success) {
        throw ServerException(
          message: body['message']?.toString() ?? 'Lỗi làm mới phiên đăng nhập',
        );
      }

      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const ServerException(
          message: 'Không nhận được dữ liệu token mới',
        );
      }

      return {
        'accessToken': data['accessToken']?.toString() ?? '',
        'expiresIn':
            int.tryParse(data['expiresIn']?.toString() ?? '900') ?? 900,
        'refreshToken': data['refreshToken']?.toString() ?? '',
        'refreshExpiresAt': data['refreshExpiresAt']?.toString() ?? '',
      };
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final res = e.response!.data as Map<String, dynamic>;
        final message = res['message']?.toString();
        if (message != null && message.isNotEmpty) {
          throw ServerException(
            message: message,
            statusCode: e.response?.statusCode,
          );
        }
      }
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      final body = await post(AppConfig.logoutUrl);

      if (body is Map<String, dynamic>) {
        final success = body['success'] == true;
        if (!success) {
          throw ServerException(
            message:
                body['message']?.toString() ?? 'Đăng xuất không thành công',
          );
        }
      }
    } on DioException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
