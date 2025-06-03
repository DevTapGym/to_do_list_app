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

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Helper method to get the authorization header
  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No access token found');
    }
    return {'Authorization': 'Bearer $token'};
  }

  // Get categories by user ID
  Future<List<Category>> getCategories(int userId) async {
    try {
      final response = await dio.get(
        '/api/v1/category/$userId',
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch categories: Status ${response.statusCode}',
        );
      }

      if (response.data == null || response.data['data'] == null) {
        return [];
      }

      final data = response.data['data'] as List;
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // Create a new category
  Future<Category> createCategory({
    required String name,
    required int userId,
  }) async {
    try {
      final response = await dio.post(
        '/api/v1/category',
        data: {'name': name, 'userId': userId},
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to create category: Status ${response.statusCode}',
        );
      }

      if (response.data == null || response.data['data'] == null) {
        throw Exception('No data returned from server');
      }

      return Category.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  Future<Category> updateCategory({
    required int id,
    required String name,
    required int userId,
  }) async {
    try {
      final response = await dio.put(
        '/api/v1/category',
        data: {'id': id, 'name': name, 'userId': userId},
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update category: Status ${response.statusCode}',
        );
      }

      if (response.data == null || response.data['data'] == null) {
        throw Exception('No data returned from server');
      }

      return Category.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }
}
