import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/services/auth_service.dart';

class ReqTeamDTO {
  final int? id;
  final String name;
  ReqTeamDTO({required this.id, required this.name});
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class TeamRepository {
  final AuthService authService;
  TeamRepository(this.authService);
  String path = '/api/v1/team';

  Future<List<Team>> getTeamsByUserId(int user_id) async {
    final response = await authService.get('$path/$user_id');
    if (response.statusCode == 200 && response.data['status'] == 200) {
      List<dynamic> data = response.data['data'];
      return data.map((team) => Team.fromJson(team)).toList();
    } else {
      throw Exception('Lỗi khi tải danh sách nhóm');
    }
  }

  Future<Team> getTeamById(int teamId) async {
    final response = await authService.get('$path/detail/$teamId');
    if (response.statusCode == 200 && response.data['status'] == 200) {
      final data = response.data['data'];
      return Team.fromJson(data);
    } else {
      throw Exception('Lỗi khi tải danh sách nhóm');
    }
  }

  Future<int?> createTeam(ReqTeamDTO reqTeamDTO, int userId) async {
    try {
      final response = await authService.post(
        '$path/$userId',
        reqTeamDTO.toJson(),
      );

      if (response.data['status'] != 201 || response.statusCode != 200) {
        throw Exception('Lỗi khi tạo nhóm');
      }
      final data = response.data['data'];
      final team = Team.fromJson(data);
      return team.id;
    } catch (e) {
      throw Exception('Lỗi khi tạo nhóm');
    }
  }

  Future<void> updateTeam(ReqTeamDTO reqTeamDTO) async {
    final response = await authService.put('$path', reqTeamDTO.toJson());
    if (response.statusCode != 200 || response.data['status'] != 200) {
      throw Exception('Lỗi khi cập nhật nhóm');
    }
  }

  Future<void> deleteTeam(int id) async {
    final response = await authService.delete('$path/$id');
    if (response.statusCode != 200 || response.data['status'] != 200) {
      throw Exception('Lỗi khi xóa nhóm');
    }
  }

  Future<void> deleteTeamAndTask(int id) async {
    final response = await authService.delete('$path/task/$id');
    if (response.statusCode != 200 || response.data['status'] != 200) {
      throw Exception('Lỗi khi xóa nhóm');
    }
  }
  Future<User> getUserbyEmail(String Email) async {
    final response = await authService.get('/api/v1/$Email');
    if (response.statusCode == 200) {
      final data = response.data['data'];
      return User.fromJson(data);
    } else {
      throw Exception('Lỗi khi tải người dùng email: $Email');
    }
  }
}