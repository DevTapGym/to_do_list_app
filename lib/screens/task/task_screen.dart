import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';
import 'package:to_do_list_app/screens/task/add_task_screen.dart';
import 'package:to_do_list_app/widgets/to_do_card.dart';

class TaskScreen extends StatefulWidget {
  final List<Task> taskList;
  final Function(Task) onTaskAdded;

  const TaskScreen({
    super.key,
    required this.taskList,
    required this.onTaskAdded,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  void _addTask(Task task) {
    setState(() {
      widget.taskList.add(task);
    });
  }

  void _navigateToAddTaskScreen() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(onTaskAdded: _addTask),
      ),
    );

    if (newTask != null) {
      _addTask(newTask);
    }
  }

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
                      'Hi there,',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your Task',
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
                    Actionbutton(icon: Icons.search),
                    SizedBox(width: 12),
                    Actionbutton(icon: Icons.filter_list),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: CategoryList(
                categories: [
                  {'label': 'Personal', 'color': Colors.red},
                  {'label': 'Work', 'color': Colors.purple},
                  {'label': 'Health', 'color': Colors.green},
                  {'label': 'Study', 'color': Colors.blue},
                  {'label': 'Finance', 'color': Colors.orange},
                  {'label': 'Shopping', 'color': Colors.pink},
                ],
                isMultiSelect: true,
                onCategorySelected: (category) {},
              ),
            ),
            widget.taskList.isEmpty
                ? EmptyState(onAddTask: _navigateToAddTaskScreen)
                : Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.taskList.length,
                    itemBuilder: (context, index) {
                      return TodoCard(
                        task: widget.taskList[index],
                        onTap: () {
                          setState(() {
                            widget.taskList[index].completed =
                                !widget.taskList[index].completed;
                          });
                        },
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final VoidCallback onAddTask;
  const EmptyState({super.key, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Icon(Icons.task, color: Colors.grey, size: 100),
          SizedBox(height: 8),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first task to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onAddTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.fromLTRB(40, 6, 40, 6),
            ),
            child: Text(
              'Add Task',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
