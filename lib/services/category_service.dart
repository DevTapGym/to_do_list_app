import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/category.dart';

class CategoryService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8080",
      validateStatus: (status) {
        return true;
      },
    ),
  );

  Future<List<Category>> getCategories(int userId) async {
    try {
      // Lấy token từ FlutterSecureStorage
      final storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'access_token');

      if (token == null) {
        throw Exception('No access token found');
      }

      // Thêm token vào header
      final response = await dio.get(
        '/api/v1/category/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Kiểm tra status code
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch categories: Status ${response.statusCode}',
        );
      }

      // Kiểm tra dữ liệu trả về
      if (response.data == null || response.data['data'] == null) {
        return []; // Trả về danh sách rỗng nếu không có dữ liệu
      }

      final data = response.data['data'] as List;
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
