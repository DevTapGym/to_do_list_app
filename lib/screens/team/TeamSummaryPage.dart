import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/screens/stats/stats_screen.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

class TeamSummaryPage extends StatelessWidget {
  final Team team;
  final List<TeamTask> allTeamTasks;
  final bool isDark;

  const TeamSummaryPage({
    super.key,
    required this.team,
    required this.allTeamTasks,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    int teamCompletedTasksCount =
        allTeamTasks.where((task) => task.isCompleted).length;
    int teamPendingTasksCount =
        allTeamTasks.where((task) => !task.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Team Summary for ${team.name}',
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
                'Overall Team Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SummaryCard(
                    title: "Completed",
                    value: teamCompletedTasksCount.toString(),
                    icon: Icons.check_circle,
                    borderColor: isDark ? Colors.green.shade600 : Colors.green,
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
              const SizedBox(height: 20),

              Text(
                'Summary by Member',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: colors.itemBgColor,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    columnSpacing: 24.0, 
                    dataRowMinHeight: 40.0, 
                    dataRowMaxHeight: 60.0, 
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return colors.itemBgColor; 
                      },
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          'Name',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: colors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Completed',
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
                          'Pending',
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
                    rows: team.teamMembers.map((member) {
                      final memberTasks = allTeamTasks
                          .where((task) => task.teamMemberId == member.id)
                          .toList();
                      final memberCompletedTasks =
                          memberTasks.where((task) => task.isCompleted).length;
                      final memberPendingTasks =
                          memberTasks.where((task) => !task.isCompleted).length;

                      return DataRow(
                        cells: [
                          DataCell(Text(
                            '${member.user?.name ?? 'Unknown'}',
                            style: TextStyle(color: colors.textColor),
                          )),
                          DataCell(Center(
                            child: Text(
                              memberCompletedTasks.toString(),
                              style: TextStyle(color: colors.textColor),
                            ),
                          )),
                          DataCell(Center(
                            child: Text(
                              memberPendingTasks.toString(),
                              style: TextStyle(color: colors.textColor),
                            ),
                          )),
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
