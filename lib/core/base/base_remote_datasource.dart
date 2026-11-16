// file: core/base/base_remote_datasource.dart
import 'package:dio/dio.dart';

abstract class BaseRemoteDataSource {
  final Dio dio;

  const BaseRemoteDataSource(this.dio);

  // Hàm POST dùng chung
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    final response = await dio.post(endpoint, data: data ?? const {});

    // Xử lý logic chung của API (Ví dụ: success == false)
    if (response.data != null && response.data['success'] == false) {
      throw Exception(response.data['message'] ?? 'Lỗi từ Server');
    }

    return response.data;
  }

  // Hàm get dùng chung
  Future<dynamic> get(String endpoint, {dynamic data}) async {
    final response = await dio.get(endpoint, data: data);

    // Xử lý logic chung của API (Ví dụ: success == false)
    if (response.data != null && response.data['success'] == false) {
      throw Exception(response.data['message'] ?? 'Lỗi từ Server');
    }

    return response.data;
  }

  // Hàm delete dùng chung
  Future<dynamic> delete(String endpoint, {dynamic data}) async {
    final response = await dio.delete(endpoint, data: data);

    // Xử lý logic chung của API (Ví dụ: success == false)
    if (response.data != null && response.data['success'] == false) {
      throw Exception(response.data['message'] ?? 'Lỗi từ Server');
    }

    return response.data;
  }

  // Hàm put dùng chung
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    final response = await dio.put(endpoint, data: data);

    // Xử lý logic chung của API (Ví dụ: success == false)
    if (response.data != null && response.data['success'] == false) {
      throw Exception(response.data['message'] ?? 'Lỗi từ Server');
    }

    return response.data;
  }
}
