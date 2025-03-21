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
  final List<String> _selectedCategories = [];
  bool? _completedFilter;
  String _sortOrder = 'newest';

  // void _applyFilters() {
  //   setState(() {
  //     _filteredTasks = widget.taskList.where((task) {
  //       if (_selectedCategories.isNotEmpty &&
  //           !_selectedCategories.contains(task.category)) {
  //         return false;
  //       }
  //       if (_completedFilter != null && task.completed != _completedFilter) {
  //         return false;
  //       }
  //       return true;
  //     }).toList();

  //     if (_sortOrder == 'newest') {
  //       _filteredTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  //     } else {
  //       _filteredTasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  //     }
  //   });
  // }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Text(
                    'Filter jobs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // Chọn danh mục
                  Wrap(
                    spacing: 8,
                    children:
                        ['Personal', 'Work', 'Health', 'Study']
                            .map(
                              (category) => ChoiceChip(
                                label: Text(category),
                                selected: _selectedCategories.contains(
                                  category,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedCategories.add(category);
                                    } else {
                                      _selectedCategories.remove(category);
                                    }
                                  });
                                },
                              ),
                            )
                            .toList(),
                  ),

                  SizedBox(height: 10),

                  // Chọn trạng thái
                  CheckboxListTile(
                    title: Text('Completed Task'),
                    value: _completedFilter == true,
                    onChanged: (value) {
                      setState(() {
                        _completedFilter = value == true ? true : null;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text('Incomplete Task'),
                    value: _completedFilter == false,
                    onChanged: (value) {
                      setState(() {
                        _completedFilter = value == true ? false : null;
                      });
                    },
                  ),

                  SizedBox(height: 10),

                  // Chọn cách sắp xếp
                  RadioListTile(
                    title: Text('Sort by priority'),
                    value: 'priority',
                    groupValue: _sortOrder,
                    onChanged: (value) {
                      setState(() {
                        _sortOrder = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('Sort by notification time'),
                    value: 'notification',
                    groupValue: _sortOrder,
                    onChanged: (value) {
                      setState(() {
                        _sortOrder = value.toString();
                      });
                    },
                  ),

                  SizedBox(height: 10),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        //_applyFilters();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Apply',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    if (!_isSearching) {
      _filteredTasks = List.from(widget.taskList);
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
                          Icons.filter_list,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _showFilterBottomSheet,
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
