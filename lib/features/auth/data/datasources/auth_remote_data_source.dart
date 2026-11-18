import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> refreshToken({required String refreshToken});

  Future<void> logout({required String refreshToken});
}
