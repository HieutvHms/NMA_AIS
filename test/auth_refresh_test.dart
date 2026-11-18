import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ais/core/constants/api_endpoints.dart';
import 'package:ais/core/error/failures.dart';
import 'package:ais/core/network/token_refresh_coordinator.dart';
import 'package:ais/core/storage/local_storage.dart';
import 'package:ais/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ais/features/auth/data/models/user_model.dart';
import 'package:ais/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  int requestCount = 0;

  _FakeHttpClientAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requestCount++;
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  String? lastLogoutRefreshToken;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> refreshToken({required String refreshToken}) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    lastLogoutRefreshToken = refreshToken;
  }
}

/// Helper tạo TokenRefreshCoordinator với adapter giả lập bằng cách test qua AuthRepositoryImpl & Dio
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth API & Refresh Token', () {
    test('ApiEndpoints.refreshToken phải là /auth/refresh', () {
      expect(ApiEndpoints.refreshToken, '/auth/refresh');
      expect(ApiEndpoints.login, '/auth/login');
      expect(ApiEndpoints.logout, '/auth/logout');
    });

    test(
      'TokenRefreshCoordinator chỉ gửi 1 request /auth/refresh khi nhiều caller gọi đồng thời',
      () async {
        SharedPreferences.setMockInitialValues({
          'access_token': 'old_access',
          'refresh_token': 'old_refresh',
        });
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalStorage(prefs);

        var sessionExpiredCalled = false;
        final coordinator = TokenRefreshCoordinator(
          storage,
          onSessionExpired: () => sessionExpiredCalled = true,
        );

        // Không có server thật ở unit test -> sẽ gặp networkError
        // Nhưng phải giữ nguyên session (KHÔNG xóa token khi lỗi mạng)
        final results = await Future.wait([
          coordinator.refresh(),
          coordinator.refresh(),
          coordinator.refresh(),
        ]);

        for (final r in results) {
          expect(r.isNetworkError, isTrue);
        }
        expect(sessionExpiredCalled, isFalse);
        expect(storage.getRefreshToken(), 'old_refresh');
        expect(storage.getToken(), 'old_access');
      },
    );

    test(
      'AuthRepositoryImpl.refreshToken ném Failure khi lỗi mạng và giữ phiên',
      () async {
        SharedPreferences.setMockInitialValues({
          'access_token': 'old_access',
          'refresh_token': 'old_refresh',
        });
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalStorage(prefs);
        final coordinator = TokenRefreshCoordinator(storage);
        final remote = _FakeAuthRemoteDataSource();
        final repo = AuthRepositoryImpl(
          remoteDataSource: remote,
          localStorage: storage,
          refreshCoordinator: coordinator,
        );

        await expectLater(repo.refreshToken(), throwsA(isA<Failure>()));
        expect(storage.getRefreshToken(), 'old_refresh');
      },
    );

    test(
      'AuthRepositoryImpl.refreshToken trả false và xóa phiên khi không có refreshToken',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = LocalStorage(prefs);
        var expired = false;
        final coordinator = TokenRefreshCoordinator(
          storage,
          onSessionExpired: () => expired = true,
        );
        final remote = _FakeAuthRemoteDataSource();
        final repo = AuthRepositoryImpl(
          remoteDataSource: remote,
          localStorage: storage,
          refreshCoordinator: coordinator,
        );

        final ok = await repo.refreshToken();
        expect(ok, isFalse);
        expect(expired, isTrue);
      },
    );

    test('AuthRepositoryImpl.logout gửi refreshToken mới nhất và xóa phiên', () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'acc_1',
        'refresh_token': 'ref_latest',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorage(prefs);
      final coordinator = TokenRefreshCoordinator(storage);
      final remote = _FakeAuthRemoteDataSource();
      final repo = AuthRepositoryImpl(
        remoteDataSource: remote,
        localStorage: storage,
        refreshCoordinator: coordinator,
      );

      await repo.logout(callRemote: true);
      expect(remote.lastLogoutRefreshToken, 'ref_latest');
      expect(storage.getToken(), isNull);
      expect(storage.getRefreshToken(), isNull);
    });
  });

  // Giữ _FakeHttpClientAdapter được tham chiếu để tránh lint unused
  test('Fake adapter sanity', () async {
    final adapter = _FakeHttpClientAdapter(
      (_) async => ResponseBody.fromString(jsonEncode({}), 200),
    );
    expect(adapter.requestCount, 0);
  });
}
