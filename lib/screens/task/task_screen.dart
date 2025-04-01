import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';
import 'package:to_do_list_app/screens/task/add_task_screen.dart';
import 'package:to_do_list_app/widgets/to_do_card.dart';

class TaskScreen extends StatefulWidget {
  final List<Task> taskList;
  final Function(Task) onTaskAdded;
  final List<CategoryChip> categories;

  const TaskScreen({
    super.key,
    required this.taskList,
    required this.categories,
    required this.onTaskAdded,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Task> _filteredTasks = [];
  DateTime? _selectedDate;

  // Lọc theo ngày
  void _filterByDate() {
    setState(() {
      if (_selectedDate == null) {
        _filteredTasks = List.from(widget.taskList);
      } else {
        _filteredTasks =
            widget.taskList.where((task) {
              return task.taskDate.year == _selectedDate!.year &&
                  task.taskDate.month == _selectedDate!.month &&
                  task.taskDate.day == _selectedDate!.day;
            }).toList();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2040),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _filterByDate();
    }
  }

  //Tìm theo từ khóa
  void _searchTask(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTasks = List.from(widget.taskList);
      } else {
        _filteredTasks =
            widget.taskList
                .where(
                  (task) =>
                      task.title.toLowerCase().contains(query.toLowerCase()) ||
                      task.description!.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  void _addTask(Task task) {
    setState(() {
      widget.taskList.add(task);
      _filteredTasks = List.from(widget.taskList);
    });
  }

  void _navigateToAddTaskScreen() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddTaskScreen(
              onTaskAdded: _addTask,
              categories: widget.categories,
            ),
      ),
    );

    if (newTask != null) {
      _addTask(newTask);
    }
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2040),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSearching && _selectedDate == null) {
      _filteredTasks = List.from(widget.taskList);
    } else if (_selectedDate != null) {
      _filterByDate();
    }
    return Container(
      decoration: BoxDecoration(color: Colors.black),
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
                        onChanged: (query) {
                          _searchTask(query);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search task...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white54,
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
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                    : Column(
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
                        onPressed: () {
                          setState(() {
                            if (_isSearching) {
                              _searchController.clear();
                              _filteredTasks = List.from(widget.taskList);
                            }
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
                        color: Colors.white10,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => _selectDate(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: CategoryList(
                categories: widget.categories,
                isMultiSelect: true,
                onCategoryUpdated: (category) {},
                onCategorySelected: (category) {},
              ),
            ),
            widget.taskList.isEmpty
                ? EmptyState(onAddTask: _navigateToAddTaskScreen)
                : Expanded(
                  child: ListView.builder(
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      return TodoCard(
                        task: _filteredTasks[index],
                        categories: widget.categories,
                        onTap: () {
                          setState(() {
                            _filteredTasks[index].completed =
                                !_filteredTasks[index].completed;
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
