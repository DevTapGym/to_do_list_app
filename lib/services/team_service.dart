import 'package:to_do_list_app/repositories/team/team_member_repository.dart';
import 'package:to_do_list_app/repositories/team/team_repository.dart';
import 'package:to_do_list_app/repositories/team/team_task_repository.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';

class TeamService {
  final TeamRepository teamRepository;
  final TeamMemberRepository teamMemberRepository;
  final TeamTaskRepository teamTaskRepository;
  TeamService({
    required this.teamRepository,
    required this.teamMemberRepository,
    required this.teamTaskRepository,
  });
  Future<void> ChangeMemberRole(int teamId, int userId, Role role) async {
    TeamMember member = await teamMemberRepository.getMemberByTeamAndUserId(
      teamId,
      userId,
    );
    member.role = role;
    await teamMemberRepository.updateMember(member);
  }

  Future<TeamMember> getMemberByTeamAndUserId(int teamId, int userId) async {
    final member = await teamMemberRepository.getMemberByTeamAndUserId(
      teamId,
      userId,
    );
    return member;
  }

  Future<void> DeleteTeamTask(int taskId) async {
    await teamTaskRepository.deletePersonalTask(taskId);
  }

  Future<bool> UpdateTeamTask(TeamTask teamTask) async {
    return await teamTaskRepository.updatePersonalTask(teamTask);
  }

  Future<void> DisbandTeam(int teamId) async {
    await teamRepository.deleteTeamAndTask(teamId);
  }

  Future<void> ChangeTeamName(int teamId, String newName) async {
    ReqTeamDTO team = ReqTeamDTO(id: teamId, name: newName);
    await teamRepository.updateTeam(team);
  }

  Future<bool> ToggleTeamTaskComplete(TeamTask teamTask) async {
    teamTask.isCompleted = !teamTask.isCompleted;
    await teamTaskRepository.updatePersonalTask(teamTask);
    return true;
  }

  Future<void> AddTeamMember(int teamId, int userId) async {
    await teamMemberRepository.createTeamMember(
      TeamMember(id: null, role: Role.MEMBER, userId: userId, teamId: teamId),
    );
  }

  Future<void> CreateTeamTask(
    String title,
    String description,
    DateTime deadline,
    String priority,
    int teamId,
    int userId,
  ) async {
    TeamMember member = await teamMemberRepository.getMemberByTeamAndUserId(
      teamId,
      userId,
    );
    TeamTask teamTask = TeamTask(
      id: null,
      title: title,
      description: description,
      deadline: deadline,
      priority: Priority.values.firstWhere(
        (e) => e.name == priority.toUpperCase(),
      ),
      isCompleted: false,
      teamMemberId: member.id!,
    );
    await teamTaskRepository.createPersonalTask(teamTask);

    return;
  }

  Future<void> AddTeamMemberWithQR(TeamMember teamMember) async {
    await teamMemberRepository.createTeamMember(teamMember);
  }

  Future<void> DeleteMember(int teamId, int userId) async {
    await teamMemberRepository.deleteMemberAndTask(teamId, userId);
  }

  Future<Team> getTeamById(int teamId) async {
    final team = await teamRepository.getTeamById(teamId);
    return team;
  }

  Future<List<Team>> getTeamsByUserId(int userId) async {
    final teams = await teamRepository.getTeamsByUserId(userId);
    return teams;
  }

  Future<List<User>> getMembersByTeamId(int teamId) async {
    final members = await teamMemberRepository.getMembersByTeamId(teamId);
    return members;
  }

  Future<List<TeamTask>> getTeamTasksByTeamId(int teamId) async {
    final tasks = await teamTaskRepository.getTeamTasksByTeamId(teamId);
    return tasks;
  }
  Future<List<TeamTask>> getTeamTasksByUserId(int userId) async {
    final tasks = await teamTaskRepository.getTeamTasksByUserId(userId);
    return tasks;
  }
  Future<User> getUserbyEmail(String email)async{
    User user=await teamRepository.getUserbyEmail(email);
    return user;
  }
  Future<void> createTeamWithMembers(Team team, int userId) async {
    ReqTeamDTO reqTeamDTO = ReqTeamDTO(id: null, name: team.name);
    final teamId = await teamRepository.createTeam(reqTeamDTO, userId);
    if (teamId != null) {
      final teamMemberList = await teamMemberRepository.getMembersByUserId(
        userId,
      );
      final leader = teamMemberList.firstWhere((e) => e.teamId == teamId);
      leader.role = Role.LEADER;
      await teamMemberRepository.updateMember(leader);
      team.teamMembers.removeWhere((e) => e.userId == userId);
      for (var member in team.teamMembers) {
        await teamMemberRepository.createTeamMember(
          TeamMember(
            id: null,
            role: member.role,
            userId: member.userId,
            teamId: teamId,
          ),
        );
      }
    }
  }
}
