import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/group.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/utils/theme_config.dart';

// Màn hình hiển thị danh sách nhóm
class GroupsScreen extends StatefulWidget {
  final List<Group> groups;

  const GroupsScreen({super.key, required this.groups});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  DateTime? selectedDate;

  void _filterByDate() {}

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2040),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
      _filterByDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return Container(
      decoration: BoxDecoration(color: colors.bgColor),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _isSearching
                    ? Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: (query) {},
                        decoration: InputDecoration(
                          hintText: 'Search task...',
                          hintStyle: TextStyle(color: colors.subtitleColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colors.subtitleColor,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.deepPurpleAccent,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(color: colors.textColor),
                      ),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi there,',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.textColor,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Your group',
                          style: TextStyle(
                            fontSize: 26,
                            color: colors.textColor,
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
                        color: colors.itemBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: colors.textColor,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_isSearching) {}
                            _isSearching = !_isSearching;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: colors.itemBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: colors.textColor,
                          size: 28,
                        ),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.groups.length,
                itemBuilder: (context, index) {
                  return GroupWidget(group: widget.groups[index]);
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
