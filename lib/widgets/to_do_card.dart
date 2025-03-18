import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/screens/task/detail_task_screen.dart';

class TodoCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TodoCard({super.key, required this.task, required this.onTap});

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      case "Low":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 30, 30, 30),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
              color:
                  task.completed
                      ? Colors.green
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
                  color: task.completed ? Colors.green : Colors.white,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: Colors.white,
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
                            color: Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.category,
                            style: TextStyle(
                              color: Colors.white,
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
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${task.taskDate.day}/${task.taskDate.month}/${task.taskDate.year}',
                              style: TextStyle(
                                color: Colors.white,
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
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${task.notificationTime!.hour}:${task.notificationTime!.minute}',
                                style: TextStyle(
                                  color: Colors.white,
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailTaskScreen()),
                );
              },
              child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
