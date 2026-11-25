import 'package:dio/dio.dart';
import '../error/exceptions.dart';

abstract class BaseRemoteDataSource {
  final Dio dio;

  const BaseRemoteDataSource(this.dio);

  // Hàm POST dùng chung (hỗ trợ CancelToken và queryParameters)
  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.post(
      endpoint,
      data: data ?? const {},
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    if (response.data != null &&
        response.data is Map &&
        response.data['success'] == false) {
      throw ServerException(
        message: response.data['message']?.toString() ?? 'Lỗi từ Server',
      );
    }

    return response.data;
  }

  // Hàm GET dùng chung (hỗ trợ CancelToken và queryParameters)
  Future<dynamic> get(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    if (response.data != null &&
        response.data is Map &&
        response.data['success'] == false) {
      throw ServerException(
        message: response.data['message']?.toString() ?? 'Lỗi từ Server',
      );
    }

    return response.data;
  }

  // Hàm DELETE dùng chung
  Future<dynamic> delete(
    String endpoint, {
    dynamic data,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.delete(
      endpoint,
      data: data,
      cancelToken: cancelToken,
    );

    if (response.data != null &&
        response.data is Map &&
        response.data['success'] == false) {
      throw ServerException(
        message: response.data['message']?.toString() ?? 'Lỗi từ Server',
      );
    }

    return response.data;
  }

  // Hàm PUT dùng chung
  Future<dynamic> put(
    String endpoint, {
    dynamic data,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.put(
      endpoint,
      data: data,
      cancelToken: cancelToken,
    );

    if (response.data != null &&
        response.data is Map &&
        response.data['success'] == false) {
      throw ServerException(
        message: response.data['message']?.toString() ?? 'Lỗi từ Server',
      );
    }

    return response.data;
  }
}
