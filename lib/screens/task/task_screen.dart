import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _showCompletedTasks = false;

  final SummaryService summaryService = SummaryService();
  final NotificationService notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _filteredTasks = List.from(widget.tasks);
    _categories = List.from(widget.categories);
    _loadShowCompletedTasks();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTasksByDate();
      _listenForAuthState(); // Không cần set lại has_shown_notifications = false
    });
  }

  Future<void> _listenForAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownNotifications =
        prefs.getBool('has_shown_notifications') ?? false;
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (hasShownNotifications || !notificationsEnabled) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.authResponse != null) {
      final userId = authState.authResponse!.user.id;
      final today = DateTime.now();

      // Thông báo sau 30 giây: Số công việc cần làm hôm nay
      Timer(const Duration(seconds: 30), () async {
        // Kiểm tra lại cờ trước khi gửi thông báo
        final prefs = await SharedPreferences.getInstance();
        final hasShown = prefs.getBool('has_shown_notifications') ?? false;
        if (hasShown) return;
        try {
          final uncompletedTasks = await summaryService
              .countUncompletedTasksInDay(userId, today);
          await notificationService.showNotification(
            'tasks_for_today'.tr(),
            'you_have_tasks_to_do'.tr(args: ['$uncompletedTasks']),
            id: 1,
          );
          // Cập nhật trạng thái sau khi gửi thông báo
          await prefs.setBool('has_shown_notifications', true);
        } catch (e) {
          print('Error showing tasks notification: $e');
        }
      });

      // Thông báo sau 60 giây: Số công việc hoàn thành trong tuần
      Timer(const Duration(seconds: 60), () async {
        // Kiểm tra lại cờ trước khi gửi thông báo
        final prefs = await SharedPreferences.getInstance();
        final hasShown = prefs.getBool('has_shown_notifications') ?? false;
        if (hasShown) return;
        try {
          final completedTasks = await summaryService.countCompletedTasksInWeek(
            userId,
            today,
          );
          await notificationService.showNotification(
            'keep_it_up'.tr(),
            'you_completed_tasks_in_week'.tr(args: ['$completedTasks']),
            id: 2,
          );
          // Cập nhật trạng thái sau khi gửi thông báo
          await prefs.setBool('has_shown_notifications', true);
        } catch (e) {
          print('Error showing weekly tasks notification: $e');
        }
      });
    }
  }

  Future<void> _loadShowCompletedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showCompletedTasks = prefs.getBool('show_completed_tasks') ?? false;
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
          _filteredTasks =
              _showCompletedTasks
                  ? tasks
                  : tasks.where((task) => !task.completed).toList();
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('failed_to_load_tasks'.tr(args: ['$e']))),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('user_not_authenticated'.tr())));
    }
  }

  void _searchTask(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTasks =
            widget.tasks.where((task) {
              final matchesDate =
                  task.taskDate.year == _selectedDate.year &&
                  task.taskDate.month == _selectedDate.month &&
                  task.taskDate.day == _selectedDate.day;
              final matchesCompletion = _showCompletedTasks || !task.completed;
              return matchesDate && matchesCompletion;
            }).toList();
      } else {
        _filteredTasks =
            _filteredTasks.where((task) {
              final matchesTitle = task.title.toLowerCase().contains(
                query.toLowerCase(),
              );
              final matchesCompletion = _showCompletedTasks || !task.completed;
              return matchesTitle && matchesCompletion;
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
    bool repeatTomorrow = false; // Biến lưu trạng thái checkbox

    return showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (BuildContext context, StateSetter setState) => AlertDialog(
                  title: Text('confirm_task_completion'.tr()),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('mark_task_irreversible'.tr()),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: repeatTomorrow,
                            onChanged: (value) {
                              setState(() {
                                repeatTomorrow = value ?? false;
                              });
                            },
                          ),
                          Text(
                            'repeat_tomorrow'.tr(),
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('cancel'.tr()),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _updateTaskStatus(
                          task,
                          repeatTomorrow: repeatTomorrow,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('confirm'.tr()),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _updateTaskStatus(
    Task task, {
    required bool repeatTomorrow,
  }) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Cập nhật trạng thái task
      bool result = await taskService.updateTask(
        task.copyWith(completed: !task.completed),
      );
      if (result) {
        // Nếu checkbox được chọn, thêm task mới cho ngày mai
        if (repeatTomorrow) {
          final newTask = Task(
            title: task.title,
            description: task.description,
            taskDate: task.taskDate.add(const Duration(days: 1)),
            priority: task.priority,
            categoryId: task.categoryId,
            categoryName: task.categoryName,
            completed: false,
            notificationTime: task.notificationTime,
            userId: task.userId,
          );
          await taskService.addTask(newTask); // Gọi API để thêm task mới
        }
        await _fetchTasksByDate();
        // Logic streak giữ nguyên
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated && authState.authResponse != null) {
          final userId = authState.authResponse!.user.id;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final SummaryService summaryService = SummaryService();

          final completedTasksToday = await summaryService
              .countCompletedTasksInDay(userId, today);

          if (completedTasksToday >= 3) {
            try {
              final streakData = await summaryService.getStreak(userId);
              int currentStreak = streakData['currentStreak'] ?? 0;
              int longestStreak = streakData['longestStreak'] ?? 0;
              String? lastCompletedDateStr = streakData['lastCompletedDate'];
              DateTime? lastCompletedDate =
                  lastCompletedDateStr != null
                      ? DateTime.parse(lastCompletedDateStr)
                      : null;

              if (lastCompletedDate != null &&
                  lastCompletedDate.year == today.year &&
                  lastCompletedDate.month == today.month &&
                  lastCompletedDate.day == today.day) {
                return;
              }

              final yesterday = today.subtract(const Duration(days: 1));

              if (lastCompletedDate != null &&
                  lastCompletedDate.year == yesterday.year &&
                  lastCompletedDate.month == yesterday.month &&
                  lastCompletedDate.day == yesterday.day) {
                currentStreak += 1;
              } else {
                currentStreak = 1;
              }

              if (currentStreak > longestStreak) {
                longestStreak = currentStreak;
              }

              await summaryService.updateStreak({
                'id': streakData['id'] ?? 0,
                'userId': userId,
                'currentStreak': currentStreak,
                'longestStreak': longestStreak,
                'lastCompletedDate': DateFormat('yyyy-MM-dd').format(today),
              });

              final notificationService = NotificationService();
              await notificationService.init();
              await notificationService.requestPermissions();
              await notificationService.showNotification(
                'streak_updated'.tr(),
                'streak_updated_message'.tr(args: ['$currentStreak']),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('failed_to_update_streak'.tr(args: ['$e'])),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('failed_to_update_task'.tr())));
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                            hintText: 'search_task'.tr(),
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
                            'hi_there'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: colors.textColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'your_task'.tr(),
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
                              final matchesDate =
                                  task.taskDate.year == _selectedDate.year &&
                                  task.taskDate.month == _selectedDate.month &&
                                  task.taskDate.day == _selectedDate.day;
                              final matchesCategory = selectedCategoryIds
                                  .contains(task.categoryId);
                              final matchesCompletion =
                                  _showCompletedTasks || !task.completed;
                              return matchesDate &&
                                  matchesCategory &&
                                  matchesCompletion;
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
                    'tasks_for'.tr(
                      args: [
                        '${_filteredTasks.length}',
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                      ],
                    ),
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
                                color: Colors.deepPurpleAccent,
                                isSelected: task.categoryId == c.id,
                              ),
                            )
                            .toList(),
                    onTap: () async {
                      if (!_isToday(task.taskDate)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('only_today_tasks'.tr())),
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
            'no_tasks_yet'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'add_first_task'.tr(),
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
            child: Text(
              'add_task'.tr(),
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    bool isDark = themeProvider.isDarkMode;
    final colors = AppThemeConfig.getColors(context);

    List<DateTime> dates = List.generate(
      4,
      (index) => DateTime.now().add(Duration(days: index)),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          dates.map((date) {
            bool isSelected =
                selectedDate.day == date.day &&
                selectedDate.month == date.month &&
                selectedDate.year == date.year;

            Color textColor;
            if (isSelected) {
              textColor = Colors.white;
            } else {
              textColor = isDark ? colors.textColor : Colors.black;
            }

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
                  border:
                      isSelected
                          ? Border.all(
                            color:
                                isDark
                                    ? Colors.deepPurpleAccent.shade100
                                    : Colors.deepPurpleAccent,
                            width: 2,
                          )
                          : null,
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                          : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(date),
                      style: TextStyle(
                        color: textColor.withOpacity(0.85),
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
