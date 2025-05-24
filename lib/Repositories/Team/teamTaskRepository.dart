import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/services/api_service.dart';

class TeamTaskRepository{
  final ApiService apiService;
  TeamTaskRepository(this.apiService);
  String path='/api/v1/team-task';
  
  Future<List<TeamTask>> getTeamTasksByTeamId(int teamId) async {
    final response = await apiService.get('$path/by-team/$teamId');
    if (response.statusCode == 200 && response.data['status']==200) {
      List<dynamic> data = response.data['data'];
      return data.map((team) => TeamTask.fromJson(team)).toList();
    } else {
      throw Exception('Lỗi khi tải task nhóm');
    }
  }
  Future<List<TeamTask>> getTeamTasksByMemberId(int memberId) async {
    final response = await apiService.get('$path/by-member/$memberId');
    if (response.statusCode == 200 && response.data['status']==200) {
      List<dynamic> data = response.data['data'];
      return data.map((team) => TeamTask.fromJson(team)).toList();
    } else {
      throw Exception('Lỗi khi tải task của thành viên nhóm');
    }
  }
  Future<void> createPersonalTask(TeamTask reqTeamTaskDTO) async {
    final response = await apiService.post('$path', reqTeamTaskDTO.toJson());
    if (response.data['status']!= 201 && response.statusCode != 200) {
      throw Exception('Lỗi khi thêm task nhóm');
    }
  }

  Future<bool> updatePersonalTask(TeamTask reqTeamTaskDTO) async {
  try {
    final response = await apiService.put('$path', reqTeamTaskDTO.toJson());
    if (response.statusCode == 200 && response.data['status'] == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}


  Future<void> deletePersonalTask(int id) async {
    final response = await apiService.delete('$path/$id');
    if (response.statusCode != 200 || response.data['status']!=200) {
      throw Exception('Lỗi khi xóa task nhóm');
    }
  }
}