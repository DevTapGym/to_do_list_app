import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/providers/theme_provider.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';
import 'package:to_do_list_app/screens/task/add_task_screen.dart';
import 'package:to_do_list_app/widgets/to_do_card.dart';
import 'package:intl/intl.dart';

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
  DateTime _selectedDate = DateTime.now();

  // Lọc theo ngày
  void _filterByDate() {
    setState(() {
      _filteredTasks =
          widget.taskList.where((task) {
            return task.taskDate.year == _selectedDate.year &&
                task.taskDate.month == _selectedDate.month &&
                task.taskDate.day == _selectedDate.day;
          }).toList();
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
    final colors = AppThemeConfig.getColors(context);

    if (!_isSearching) {
      _filteredTasks = List.from(widget.taskList);
    }
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
                        onChanged: (query) {
                          _searchTask(query);
                        },
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
                categories: widget.categories,
                isMultiSelect: true,
                onCategoryUpdated: (category) {},
                onCategorySelected: (category) {},
              ),
            ),
            DatePickerWidget(
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
                _filterByDate();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.taskList.length} Tasks For ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    bool isDark = themeProvider.isDarkMode;
    final colors = AppThemeConfig.getColors(context);

    return Container(
      margin: EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Icon(Icons.task, color: colors.subtitleColor, size: 100),
          SizedBox(height: 8),
          Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colors.textColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first task to get started',
            style: TextStyle(fontSize: 16, color: colors.subtitleColor),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onAddTask,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDark
                      ? Colors.deepPurpleAccent
                      : Colors.deepPurpleAccent.shade700,
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
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                margin: EdgeInsets.symmetric(horizontal: 6),
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
