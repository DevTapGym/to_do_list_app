import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/group.dart';
import 'package:to_do_list_app/models/task.dart';

// Màn hình hiển thị danh sách nhóm
class GroupsScreen extends StatelessWidget {
  final List<Group> groups;

  const GroupsScreen({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Groups',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 12),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.search, color: Colors.white, size: 28),
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      margin: EdgeInsets.only(left: 12),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  return GroupWidget(group: groups[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget hiển thị 1 Task
class TaskWidget extends StatelessWidget {
  final Task task;

  const TaskWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: task.completed ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Icon(
            task.completed ? Icons.check_circle : Icons.circle_outlined,
            color: task.completed ? Colors.green : Colors.white,
          ),
          const SizedBox(width: 8),
          Text(task.title, style: const TextStyle(color: Colors.white)),
          const Spacer(),
          Icon(Icons.flag, color: Colors.amber),
          const SizedBox(width: 8),
          Icon(Icons.circle, color: Colors.lightGreenAccent),
          const SizedBox(width: 8),
          Text('lala', style: TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          Text('hihihaha', style: const TextStyle(color: Colors.white)),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}

// Widget hiển thị 1 Group
class GroupWidget extends StatelessWidget {
  final Group group;

  const GroupWidget({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: ExpansionTile(
        title: Text(group.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          '@${group.id}',
          style: TextStyle(color: Colors.grey[400]),
        ),
        iconColor: Colors.white,
        children: group.items.map((task) => TaskWidget(task: task)).toList(),
      ),
    );
  }
}
