import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class SummaryService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:8080",
      validateStatus: (status) {
        return true;
      },
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('No access token found');
    }
    return {'Authorization': 'Bearer $token'};
  }

  Future<int> _fetchCount(String endpoint, int userId, DateTime date) async {
    final headers = await _getAuthHeaders();
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await dio.get(
      '/api/v1/task$endpoint',
      queryParameters: {'userId': userId, 'date': formattedDate},
      options: Options(headers: headers),
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return response.data['data'];
    } else {
      throw Exception('Failed to fetch count: ${response.statusCode}');
    }
  }

  Future<int> countTasksInDay(int userId, DateTime date) {
    return _fetchCount('/count/day/total', userId, date);
  }

  Future<int> countCompletedTasksInDay(int userId, DateTime date) {
    return _fetchCount('/count/day/completed', userId, date);
  }

  Future<int> countUncompletedTasksInDay(int userId, DateTime date) {
    return _fetchCount('/count/day/uncompleted', userId, date);
  }

  Future<int> countTasksInWeek(int userId, DateTime date) {
    return _fetchCount('/count/week', userId, date);
  }

  Future<int> countCompletedTasksInWeek(int userId, DateTime date) {
    return _fetchCount('/count/week/completed', userId, date);
  }

  Future<Map<String, dynamic>> getStreak(int userId) async {
    final headers = await _getAuthHeaders();

    final response = await dio.get(
      '/api/v1/streak/$userId',
      options: Options(headers: headers),
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return {
        'currentStreak': response.data['data']['currentStreak'],
        'longestStreak': response.data['data']['longestStreak'],
        'lastCompletedDate': response.data['data']['lastCompletedDate'],
      };
    } else {
      throw Exception('Failed to fetch streak: ${response.statusCode}');
    }
  }
}
