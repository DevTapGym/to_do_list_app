import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/screens/team/group_task_detail.dart';
import 'package:to_do_list_app/services/injections.dart';
import 'package:to_do_list_app/services/team_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/Dialog_Confirmation.dart';

class TodoCardTeam extends StatelessWidget {
  final TeamTask task;
  final bool canEdit;
  final bool isLeader;
  final VoidCallback? onChanged;
  final TeamService teamService = getIt.get<TeamService>();
  final User? assignedMember;
  final bool isWide;
  TodoCardTeam({
    super.key,
    required this.task,
    required this.canEdit,
    required this.isLeader,
    required this.isWide,
    this.onChanged,
    this.assignedMember,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return GestureDetector(
      onTap: () {
        _showConfirmationDialog(context, task.title);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.itemBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
              color:
                  task.isCompleted
                      ? Colors.green.shade600
                      : _getPriorityColor(task.priority.toString()),
              width: 6,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.isCompleted ? Colors.green : colors.textColor,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width:
                          160, // hoặc dùng Flexible bên dưới nếu muốn tự động co giãn
                      child: Text(
                        task.title,
                        style: TextStyle(
                          color: colors.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (assignedMember != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: colors.subtitleColor,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            assignedMember!.name,
                            style: TextStyle(
                              color: colors.subtitleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        const SizedBox(width: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: colors.subtitleColor,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                              style: TextStyle(
                                color: colors.subtitleColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TeamTaskDetail(
                          task: task,
                          canEdit: canEdit,
                          isLeader: isLeader,
                        ),
                  ),
                );
                if (result == 'refresh') {
                  onChanged?.call();
                }
              },
              child: Icon(Icons.arrow_forward_ios, color: colors.textColor),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "Priority.HIGH":
        return Colors.red;
      case "Priority.MEDIUM":
        return Colors.orange;
      case "Priority.LOW":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void onTap(TeamTask w) async {
    final success = await teamService.ToggleTeamTaskComplete(w);
    if (success) {
      onChanged?.call();
    }
  }

  void _showConfirmationDialog(BuildContext context, String taskName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (!canEdit) {
          return AlertDialog(
            title: Text('notification'.tr()),
            content: Text('no_permission_to_perform_action'.tr()),
            actions: [
              TextButton(
                child: Text('close'.tr()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        } else {
          return ConfirmationDialog(
            title: 'confirmation'.tr(),
            content: 'are_you_sure_perform_action_with_task'.tr(
              args: [taskName],
            ),
            confirmText: 'confirm'.tr(),
            cancelText: 'cancel'.tr(),
            onConfirm: () => onTap(task),
          );
        }
      },
    );
  }
}
