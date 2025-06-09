import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/screens/stats/stats_screen.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class TeamSummaryPage extends StatefulWidget {
  final Team team;
  final List<TeamTask> allTeamTasks;
  final TeamMember? teamMember;
  final bool isDark;

  const TeamSummaryPage({
    super.key,
    required this.team,
    required this.allTeamTasks,
    this.teamMember,
    required this.isDark,
  });

  @override
  State<TeamSummaryPage> createState() => _TeamSummaryPageState();
}

class _TeamSummaryPageState extends State<TeamSummaryPage> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final colors = AppThemeConfig.getColors(context);
    final isDark = widget.isDark;
    int teamCompletedTasksCount =
        widget.allTeamTasks.where((task) => task.isCompleted).length;
    int teamPendingTasksCount =
        widget.allTeamTasks
            .where((task) => !task.isCompleted && task.deadline.isAfter(now))
            .length;
    int teamPendingLateTasksCount =
        widget.allTeamTasks
            .where(
              (task) =>
                  !task.isCompleted && task.deadline.isBefore(DateTime.now()),
            )
            .length;
    final filteredMembers =
        widget.team.teamMembers.where((member) {
          final userName = member.user?.name.toLowerCase() ?? '';
          return userName.contains(_searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'team_summary'.tr(),
          style: TextStyle(color: colors.textColor),
        ),
        backgroundColor: colors.bgColor,
        iconTheme: IconThemeData(color: colors.textColor),
      ),
      body: Container(
        color: colors.bgColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(
            children: [
              Text(
                'overall_team_summary'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SummaryCard(
                        title: 'pending_and_late'.tr(),
                        value: teamPendingLateTasksCount.toString(),
                        icon: Icons.warning_amber_rounded,
                        borderColor: isDark ? Colors.red.shade900 : Colors.red,
                        iconColor:
                            isDark
                                ? Colors.redAccent.shade100
                                : Colors.redAccent,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SummaryCard(
                        title: 'pending'.tr(),
                        value: teamPendingTasksCount.toString(),
                        icon: Icons.access_time,
                        borderColor:
                            isDark ? Colors.orange.shade900 : Colors.orange,
                        iconColor: isDark ? Colors.orange : Colors.orangeAccent,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: SummaryCard(
                        title: 'completed'.tr(),
                        value: teamCompletedTasksCount.toString(),
                        icon: Icons.check_circle,
                        borderColor:
                            isDark ? Colors.green.shade600 : Colors.green,
                        iconColor: isDark ? Colors.green : Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'summary_by_member'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'search_member'.tr(),
                    hintText: 'enter_member_name'.tr(),
                    prefixIcon: Icon(Icons.search, color: colors.textColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: colors.textColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: colors.subtitleColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: colors.primaryColor),
                    ),
                    labelStyle: TextStyle(color: colors.textColor),
                    hintStyle: TextStyle(color: colors.subtitleColor),
                  ),
                  style: TextStyle(color: colors.textColor),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: colors.itemBgColor,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    columnSpacing: 24.0,
                    dataRowMinHeight: 40.0,
                    dataRowMaxHeight: 60.0,
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>((
                      Set<MaterialState> states,
                    ) {
                      return colors.itemBgColor;
                    }),
                    columns: [
                      DataColumn(
                        label: Text(
                          'name'.tr(),
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: colors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'completed_table'.tr(),
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: colors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'pending_table'.tr(),
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: colors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text(
                          'late'.tr(),
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: colors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        numeric: true,
                      ),
                    ],
                    rows:
                        filteredMembers.map((member) {
                          final memberTasks =
                              widget.allTeamTasks
                                  .where(
                                    (task) => task.teamMemberId == member.id,
                                  )
                                  .toList();
                          final now = DateTime.now();
                          final completed =
                              memberTasks.where((t) => t.isCompleted).length;
                          final pendingNotLate =
                              memberTasks
                                  .where(
                                    (t) =>
                                        !t.isCompleted &&
                                        t.deadline.isAfter(now),
                                  )
                                  .length;
                          final pendingLate =
                              memberTasks
                                  .where(
                                    (t) =>
                                        !t.isCompleted &&
                                        t.deadline.isBefore(now),
                                  )
                                  .length;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  member.user?.name ?? 'Unknown',
                                  style: TextStyle(color: colors.textColor),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    completed.toString(),
                                    style: TextStyle(color: colors.textColor),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    pendingNotLate.toString(),
                                    style: TextStyle(color: colors.textColor),
                                  ),
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: Text(
                                    pendingLate.toString(),
                                    style: TextStyle(color: colors.textColor),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
