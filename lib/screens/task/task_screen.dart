import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/bloc/auth/auth_bloc.dart';
import 'package:to_do_list_app/bloc/auth/auth_state.dart';
import 'package:to_do_list_app/models/category.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';
import 'package:to_do_list_app/services/notification_service.dart';
import 'package:to_do_list_app/services/summary_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';
import 'package:to_do_list_app/screens/task/add_task_screen.dart';
import 'package:to_do_list_app/widgets/to_do_card.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list_app/services/task_service.dart';

class TaskScreen extends StatefulWidget {
  final Function(Task) onTaskAdded;
  final List<Task> tasks;
  final List<Category> categories;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const TaskScreen({
    super.key,
    required this.onTaskAdded,
    required this.tasks,
    required this.categories,
    required this.scaffoldKey,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Task> _filteredTasks = [];
  DateTime _selectedDate = DateTime.now();
  final TaskService taskService = TaskService();
  bool _isLoading = false;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _filteredTasks = List.from(widget.tasks);
    _categories = List.from(widget.categories);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTasksByDate();
    });
  }

  @override
  void didUpdateWidget(TaskScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tasks != oldWidget.tasks ||
        widget.categories != oldWidget.categories) {
      setState(() {
        _filteredTasks = List.from(widget.tasks);
        _categories = List.from(widget.categories);
      });
      _fetchTasksByDate();
    }
  }

  Future<void> _fetchTasksByDate() async {
    setState(() {
      _isLoading = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.authResponse != null) {
      try {
        final tasks = await taskService.getTasks(
          userId: authState.authResponse!.user.id,
          dueDate: _selectedDate,
        );
        setState(() {
          _filteredTasks = tasks;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load tasks: $e')));
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
    }
  }

  void _searchTask(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTasks =
            widget.tasks.where((task) {
              return task.taskDate.year == _selectedDate.year &&
                  task.taskDate.month == _selectedDate.month &&
                  task.taskDate.day == _selectedDate.day;
            }).toList();
      } else {
        _filteredTasks =
            _filteredTasks.where((task) {
              return task.title.toLowerCase().contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      await _fetchTasksByDate();
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _showConfirmationDialog(Task task) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Task Completion'),
            content: Text(
              'Marking this task as completed is irreversible. Are you sure you want to proceed?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _updateTaskStatus(task);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  Future<void> _updateTaskStatus(Task task) async {
    setState(() {
      _isLoading = true;
    });
    try {
      bool result = await taskService.updateTask(
        task.copyWith(completed: !task.completed),
      );
      if (result) {
        await _fetchTasksByDate();

        // Logic kiểm tra và cập nhật streak
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated && authState.authResponse != null) {
          final userId = authState.authResponse!.user.id;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final SummaryService summaryService = SummaryService();

          // Đếm số task hoàn thành trong ngày hiện tại
          final completedTasksToday = await summaryService
              .countCompletedTasksInDay(userId, today);

          // Kiểm tra nếu đã hoàn thành ít nhất 3 task
          if (completedTasksToday >= 3) {
            try {
              // Lấy thông tin streak hiện tại
              final streakData = await summaryService.getStreak(userId);
              print('Before update: $streakData');
              int currentStreak = streakData['currentStreak'] ?? 0;
              int longestStreak = streakData['longestStreak'] ?? 0;
              String? lastCompletedDateStr = streakData['lastCompletedDate'];
              DateTime? lastCompletedDate =
                  lastCompletedDateStr != null
                      ? DateTime.parse(lastCompletedDateStr)
                      : null;

              // Kiểm tra nếu streak đã được cập nhật trong ngày
              if (lastCompletedDate != null &&
                  lastCompletedDate.year == today.year &&
                  lastCompletedDate.month == today.month &&
                  lastCompletedDate.day == today.day) {
                print('Streak already updated today');
                return;
              }

              // Chuẩn hóa ngày để so sánh
              final yesterday = today.subtract(const Duration(days: 1));

              if (lastCompletedDate != null &&
                  lastCompletedDate.year == yesterday.year &&
                  lastCompletedDate.month == yesterday.month &&
                  lastCompletedDate.day == yesterday.day) {
                // Nếu lastCompletedDate là ngày hôm qua, tăng currentStreak
                currentStreak += 1;
              } else {
                // Nếu không phải ngày hôm qua, đặt currentStreak thành 1
                currentStreak = 1;
              }

              // Cập nhật longestStreak nếu currentStreak lớn hơn
              if (currentStreak > longestStreak) {
                longestStreak = currentStreak;
              }

              // Cập nhật streak qua API
              final updatedStreak = await summaryService.updateStreak({
                'id': streakData['id'] ?? 0,
                'userId': userId,
                'currentStreak': currentStreak,
                'longestStreak': longestStreak,
                'lastCompletedDate': DateFormat('yyyy-MM-dd').format(today),
              });
              print('After update: $updatedStreak');

              final notificationService = NotificationService();
              await notificationService.init();
              await notificationService.requestPermissions();
              await notificationService.showNotification(
                'Streak Updated',
                'Your streak has been updated to $currentStreak days!',
              );
            } catch (e) {
              print('Lỗi khi cập nhật streak: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update streak: $e')),
              );
            }
          }
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update task: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return Container(
      decoration: BoxDecoration(color: colors.bgColor),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _isSearching
                      ? Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: _searchTask,
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
                          const SizedBox(height: 6),
                          Text(
                            'Your Task',
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
                        margin: const EdgeInsets.only(left: 12),
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
                              if (_isSearching) {
                                _searchController.clear();
                                _fetchTasksByDate();
                              }
                              _isSearching = !_isSearching;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
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
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: CategoryList(
                  categories:
                      _categories
                          .map(
                            (c) => CategoryChip(
                              id: c.id,
                              label: c.name,
                              color: Colors.deepPurpleAccent.shade700,
                              isSelected: false,
                            ),
                          )
                          .toList(),
                  scaffoldKey: widget.scaffoldKey,
                  isMultiSelect: true,
                  onCategoryUpdated: (updatedCategories) {
                    setState(() {
                      _categories =
                          updatedCategories
                              .map(
                                (chip) =>
                                    Category(id: chip.id, name: chip.label),
                              )
                              .toList();
                      _fetchTasksByDate();
                    });
                  },
                  onCategorySelected: (List<int> selectedCategoryIds) {
                    setState(() {
                      if (selectedCategoryIds.isEmpty) {
                        _fetchTasksByDate();
                      } else {
                        _filteredTasks =
                            widget.tasks.where((task) {
                              return task.taskDate.year == _selectedDate.year &&
                                  task.taskDate.month == _selectedDate.month &&
                                  task.taskDate.day == _selectedDate.day &&
                                  selectedCategoryIds.contains(task.categoryId);
                            }).toList();
                      }
                    });
                  },
                ),
              ),
              DatePickerWidget(
                onDateSelected: (date) async {
                  setState(() {
                    _selectedDate = date;
                  });
                  await _fetchTasksByDate();
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_filteredTasks.length} Tasks For ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (_filteredTasks.isEmpty && !_isLoading)
                EmptyState(
                  onAddTask: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AddTaskScreen(
                              categories: _categories,
                              onTaskAdded: (task) {
                                widget.onTaskAdded(task);
                                _fetchTasksByDate();
                              },
                            ),
                      ),
                    );
                  },
                )
              else
                ..._filteredTasks.map(
                  (task) => TodoCard(
                    task: task,
                    categories:
                        _categories
                            .map(
                              (c) => CategoryChip(
                                id: c.id,
                                label: c.name,
                                color: Colors.deepPurpleAccent.shade700,
                                isSelected: task.categoryId == c.id,
                              ),
                            )
                            .toList(),
                    onTap: () async {
                      if (!_isToday(task.taskDate)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Only tasks for today can be marked as completed.',
                            ),
                          ),
                        );
                        return;
                      }
                      if (!task.completed) {
                        await _showConfirmationDialog(task);
                      }
                    },
                    onRefresh: _fetchTasksByDate,
                  ),
                ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class EmptyState extends StatelessWidget {
  final VoidCallback onAddTask;
  const EmptyState({super.key, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    bool isDark = themeProvider.isDarkMode;
    final colors = AppThemeConfig.getColors(context);

    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Icon(Icons.task, color: colors.subtitleColor, size: 100),
          const SizedBox(height: 8),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first task to get started',
            style: TextStyle(fontSize: 16, color: colors.subtitleColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onAddTask,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark
                      ? Colors.deepPurpleAccent
                      : Colors.deepPurpleAccent.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.fromLTRB(40, 6, 40, 6),
            ),
            child: const Text(
              'Add Task',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class DatePickerWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const DatePickerWidget({super.key, required this.onDateSelected});

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    List<DateTime> dates = List.generate(
      4,
      (index) => DateTime.now().add(Duration(days: index)),
    );
    final colors = AppThemeConfig.getColors(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          dates.map((date) {
            bool isSelected =
                selectedDate.day == date.day &&
                selectedDate.month == date.month &&
                selectedDate.year == date.year;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = date;
                });
                widget.onDateSelected(date);
              },
              child: Container(
                width: 80,
                height: 100,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primaryColor : colors.itemBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(date),
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
