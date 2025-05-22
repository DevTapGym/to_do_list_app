import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/screens/task/detail_task_screen.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';

class TodoCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onRefresh; // Thêm callback để làm mới
  final List<CategoryChip> categories;

  const TodoCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onRefresh,
    required this.categories,
  });

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "HIGH":
        return Colors.red;
      case "MEDIUM":
        return Colors.orange;
      case "LOW":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return GestureDetector(
      onTap: onTap, // Thay đổi trạng thái hoàn thành
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.itemBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
              color:
                  task.completed
                      ? Colors.green.shade600
                      : _getPriorityColor(task.priority),
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
                  task.completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.completed ? Colors.green : colors.textColor,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: colors.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                task.completed
                                    ? Colors.green
                                    : colors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            categories
                                .firstWhere(
                                  (c) => c.id == task.categoryId,
                                  orElse:
                                      () => CategoryChip(
                                        id: 0,
                                        label: 'Unknown',
                                        color: colors.primaryColor,
                                        isSelected: false,
                                      ),
                                )
                                .label,
                            style: TextStyle(
                              color: colors.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: colors.textColor,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.taskDate.day}/${task.taskDate.month}/${task.taskDate.year}',
                              style: TextStyle(
                                color: colors.textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                        if (task.notificationTime != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                color: colors.textColor,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${task.notificationTime!.hour}:${task.notificationTime!.minute}',
                                style: TextStyle(
                                  color: colors.textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => DetailTaskScreen(
                          taskId: task.id!,
                          categories: categories,
                        ),
                  ),
                );
                onRefresh(); // Gọi callback để làm mới tasks
              },
              child: Icon(Icons.arrow_forward_ios, color: colors.textColor),
            ),
          ],
        ),
      ),
    );
  }
}
