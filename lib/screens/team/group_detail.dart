import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/bloc/Team/teamTask_bloc.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';
import 'package:to_do_list_app/screens/stats/stats_screen.dart';
import 'package:to_do_list_app/screens/team/ChooseNewLeader.dart';
import 'package:to_do_list_app/screens/team/TeamSummaryPage.dart';
import 'package:to_do_list_app/screens/team/group_QR_Share.dart';
import 'package:to_do_list_app/screens/team/group_create_task.dart';
import 'package:to_do_list_app/screens/team/group_listMember.dart';
import 'package:to_do_list_app/services/injections.dart';
import 'package:to_do_list_app/services/team_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/Dialog_Confirmation.dart';
import 'package:to_do_list_app/widgets/Dialog_OneTextField.dart';
import 'package:to_do_list_app/widgets/to_do_card_Team.dart';

// ignore: must_be_immutable
class GroupDetail extends StatefulWidget {
  int? LeaderId;
  bool isLeader = false;

  final Team team;
  GroupDetail({super.key, required this.team, this.LeaderId});

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  TeamTaskBloc teamTaskBloc = getIt<TeamTaskBloc>();
  TeamService teamService = getIt.get<TeamService>();
  User user = getIt.get<User>();
  late TeamMember? teamMember;

  @override
  void initState() {
    super.initState();
    if (widget.LeaderId == -1) {
      var Leader = widget.team.teamMembers.where(
        (member) => member.role == Role.LEADER,
      );
      if (Leader.isNotEmpty) {
        widget.LeaderId = Leader.first.userId;
      }
    }
    widget.isLeader = widget.LeaderId == user.id;
    teamMember = widget.team.teamMembers.firstWhere(
      (member) => member.userId == user.id,
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    bool isDark = themeProvider.isDarkMode;
    final colors = AppThemeConfig.getColors(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.team.name,
          style: TextStyle(color: colors.textColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop('refresh'),
        ),
        backgroundColor: colors.bgColor,
        iconTheme: IconThemeData(color: colors.textColor),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:colors.bgColor
                ),
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => GroupListMember(
                              team: widget.team,
                              LeaderId: widget.LeaderId!,
                            ),
                      ),
                    );
                    if (result == 'refresh') {
                      await _fetchTeamDetails();
                      onChanged();
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.group, color: colors.textColor),
                      const SizedBox(width: 6),
                      Text(
                        widget.team.teamMembers.length.toString(),
                        style: TextStyle(
                          color: colors.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Nút Setting
              widget.isLeader
                  ? PopupMenuButton<String>(
                    icon: Icon(Icons.settings, color: colors.textColor),
                    color: colors.bgColor,
                    onSelected: (value) {
                      if (value == 'Rename') {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return OneTextFieldDialog(
                              title: 'Rename Team',
                              hintText: 'Enter new name',
                              buttonText: 'Change',
                              cancelText: 'Cancel',
                              onFunction: onRename,
                              colors: colors,
                            );
                          },
                        );
                      } else if (value == 'Disband') {
                        _showConfirmationDisbandDialog(widget.team);
                      } else if (value == 'Share') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRPage(team: widget.team),
                          ),
                        );
                      } else if (value == 'Leave') {
                        _showConfirmationLeaveDialog(widget.team, colors);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'Share',
                            child: Text('Share'),
                          ),
                          const PopupMenuItem(
                            value: 'Rename',
                            child: Text('Rename'),
                          ),
                          const PopupMenuItem(
                            value: 'Disband',
                            child: Text('Disband'),
                          ),
                          const PopupMenuItem(
                            value: 'Leave',
                            child: Text('Leave Team'),
                          ),
                        ],
                  )
                  : PopupMenuButton<String>(
                    icon: Icon(Icons.settings, color: colors.textColor),
                    color: colors.bgColor,
                    onSelected: (value) {
                      if (value == 'Leave') {
                        _showConfirmationLeaveDialog(widget.team, colors);
                      } else if (value == 'Share') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRPage(team: widget.team),
                          ),
                        );
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'Share',
                            child: Text('Share'),
                          ),
                          const PopupMenuItem(
                            value: 'Leave',
                            child: Text('Leave Team'),
                          ),
                        ],
                  ),
            ],
          ),
        ],
      ),
      body: Container(
        color: colors.bgColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: BlocBuilder<TeamTaskBloc, TeamTaskState>(
            bloc: teamTaskBloc,
            builder: (context, state) {
              int teamCompletedTasksCount = 0;
              int teamPendingTasksCount = 0;
              List<TeamTask> allTeamTasks = [];

              int myCompletedTasksCount = 0;
              int myPendingTasksCount = 0;

              if (state is TeamTaskLoaded) {
                allTeamTasks = state.tasks;
                teamCompletedTasksCount =
                    allTeamTasks.where((task) => task.isCompleted).length;
                teamPendingTasksCount =
                    allTeamTasks.where((task) => !task.isCompleted).length;

                // Tính toán thống kê cá nhân nếu teamMember tồn tại
                if (teamMember != null) {
                  final myTasks =
                      allTeamTasks
                          .where((task) => task.teamMemberId == teamMember!.id)
                          .toList();
                  myCompletedTasksCount =
                      myTasks.where((task) => task.isCompleted).length;
                  myPendingTasksCount =
                      myTasks.where((task) => !task.isCompleted).length;
                }
              }

              return Column(
                children: [
                  // Thống kê cả nhóm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Team Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (state is TeamTaskLoaded) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => TeamSummaryPage(
                                      team: widget.team,
                                      allTeamTasks: allTeamTasks,
                                      isDark: isDark,
                                    ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'See more',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.subtitleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SummaryCard(
                        title: "Completed",
                        value: teamCompletedTasksCount.toString(),
                        icon: Icons.check_circle,
                        borderColor:
                            isDark ? Colors.green.shade600 : Colors.green,
                        iconColor: isDark ? Colors.green : Colors.greenAccent,
                      ),
                      SummaryCard(
                        title: "Pending",
                        value: teamPendingTasksCount.toString(),
                        icon: Icons.access_time,
                        borderColor:
                            isDark ? Colors.orange.shade900 : Colors.orange,
                        iconColor: isDark ? Colors.orange : Colors.orangeAccent,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Thống kê theo thành viên
                  if (teamMember != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.textColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SummaryCard(
                          title: "My Completed",
                          value: myCompletedTasksCount.toString(),
                          icon: Icons.check_circle,
                          borderColor:
                              isDark ? Colors.green.shade600 : Colors.green,
                          iconColor: isDark ? Colors.green : Colors.greenAccent,
                        ),
                        SummaryCard(
                          title: "My Pending",
                          value: myPendingTasksCount.toString(),
                          icon: Icons.access_time,
                          borderColor:
                              isDark ? Colors.orange.shade900 : Colors.orange,
                          iconColor:
                              isDark ? Colors.orange : Colors.orangeAccent,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                  ],

                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state is TeamTaskLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is TeamTaskLoaded) {
                          final tasks = state.tasks;

                          final myDisplayedTasks =
                              teamMember != null
                                  ? tasks
                                      .where(
                                        (t) => t.teamMemberId == teamMember!.id,
                                      )
                                      .toList()
                                  : <TeamTask>[];

                          final otherDisplayedTasks =
                              teamMember != null
                                  ? tasks
                                      .where(
                                        (t) => t.teamMemberId != teamMember!.id,
                                      )
                                      .toList()
                                  : tasks.toList();

                          sortTasks(myDisplayedTasks);
                          sortTasks(otherDisplayedTasks);
                          return ListView(
                            children: [
                              if (myDisplayedTasks.isNotEmpty) ...[
                                Text(
                                  'Your tasks',
                                  style: TextStyle(
                                    color: colors.textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...myDisplayedTasks.map(
                                  (g) => TodoCardTeam(
                                    task: g,
                                    onChanged: onChanged,
                                    canEdit:
                                        widget.isLeader ||
                                        (teamMember != null &&
                                            g.teamMemberId == teamMember!.id),
                                    isLeader: widget.isLeader,
                                    assignedMember: getAssignedMemberById(
                                      g.teamMemberId,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              if (otherDisplayedTasks.isNotEmpty) ...[
                                Text(
                                  'Other members\' tasks',
                                  style: TextStyle(
                                    color: colors.textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...otherDisplayedTasks.map(
                                  (g) => TodoCardTeam(
                                    task: g,
                                    onChanged: onChanged,
                                    canEdit: // Chỉ leader mới sửa được task của người khác
                                        widget.isLeader ||
                                        (teamMember != null &&
                                            g.teamMemberId == teamMember!.id),
                                    isLeader: widget.isLeader,
                                    assignedMember: getAssignedMemberById(
                                      g.teamMemberId,
                                    ),
                                  ),
                                ),
                              ],

                              if (state.tasks.isEmpty)
                                Center(
                                  child: Text(
                                    'No tasks available for this team.',
                                    style: TextStyle(color: colors.textColor),
                                  ),
                                ),
                            ],
                          );
                        } else if (state is TeamTaskError) {
                          return Center(
                            child: Text(
                              'Error: ${state.message}',
                              style: TextStyle(color: colors.textColor),
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              'No data available or unknown state.',
                              style: TextStyle(color: colors.textColor),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton:
          widget.isLeader
              ? FloatingActionButton(
                backgroundColor: colors.primaryColor,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupCreateTask(team: widget.team),
                    ),
                  );
                  if (result == 'refresh') {
                    onChanged();
                  }
                },
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  User getAssignedMemberById(int id) {
    return widget.team.teamMembers.firstWhere((m) => m.id == id).user!;
  }

  void onChanged() {
    teamTaskBloc.add(LoadTeamTasksByTeamId(widget.team.id));
  }

  void sortTasks(List list) {
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return a.priority.index.compareTo(b.priority.index);
      }
      return a.deadline.compareTo(b.deadline);
    });
  }

  void onDisband(int teamId) async {
    await teamService.DisbandTeam(teamId);
    Navigator.of(context).pop('refresh');
  }

  void _showConfirmationDisbandDialog(Team team) {
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          title: 'Confirmation',
          content: 'Are you sure you want to disband team "${team.name}"?',
          confirmText: 'Confirm',
          cancelText: 'Cancel',
          onConfirm: () => onDisband(team.id),
        );
      },
    );
  }

  Future<void> onLeave({
    required int teamId,
    required int userId,
    int? newLeaderId,
  }) async {
    if (newLeaderId != null) {
      await teamService.ChangeMemberRole(teamId, newLeaderId, Role.LEADER);
      await teamService.DeleteMember(teamId, userId);
    } else {
      await teamService.DeleteMember(teamId, userId);
    }

    Navigator.of(context).pop('refresh');
  }

  void onRename(String newname) async {
    await teamService.ChangeTeamName(widget.team.id, newname);
    setState(() {
      widget.team.name = newname;
      Navigator.of(context).pop();
    });
  }

  void _showConfirmationLeaveDialog(Team team, AppColors colors) async {
    if (widget.isLeader) {
      final otherMembers =
          team.teamMembers.where((member) => member.userId != user.id).toList();

      if (otherMembers.isEmpty) {
        onDisband(team.id);
      } else {
        final int? newLeaderUserId = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChooseNewLeaderScreen(
                  team: team,
                  currentUser: user,
                  colors: colors,
                ),
          ),
        );
        if (newLeaderUserId != null) {
          onLeave(
            teamId: team.id,
            userId: user.id,
            newLeaderId: newLeaderUserId,
          );
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return ConfirmationDialog(
            title: 'Confirmation',
            content: 'Are you sure you want to leave team "${team.name}"?',
            confirmText: 'Confirm',
            cancelText: 'Cancel',
            onConfirm: () async {
              await onLeave(teamId: team.id, userId: user.id);
            },
          );
        },
      );
    }
  }

  Future<void> _fetchTeamDetails() async {
    final updatedTeam = await teamService.getTeamById(widget.team.id);
    if (updatedTeam != null) {
      setState(() {
        widget.team.teamMembers = updatedTeam.teamMembers;
        widget.team.name = updatedTeam.name;
        var leader = updatedTeam.teamMembers.firstWhere(
          (member) => member.role == Role.LEADER,
        );
        widget.LeaderId = leader.userId;
        widget.isLeader = widget.LeaderId == user.id;
        teamMember = widget.team.teamMembers.firstWhere(
      (member) => member.userId == user.id,
    );
      });
    }
  }
}
