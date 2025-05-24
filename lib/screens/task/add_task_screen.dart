import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list_app/bloc/auth/auth_bloc.dart';
import 'package:to_do_list_app/bloc/auth/auth_state.dart';
import 'package:to_do_list_app/models/category.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/services/task_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';

class AddTaskScreen extends StatefulWidget {
  final List<Category> categories;
  final Function(Task) onTaskAdded;

  const AddTaskScreen({
    super.key,
    required this.categories,
    required this.onTaskAdded,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int? selectedCategoryId;
  String selectedPriority = 'Medium';
  List<int> selectedCategoryIds = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void handleSelectedCategories(List<int> ids) {
    setState(() {
      selectedCategoryIds = ids;
      if (ids.isNotEmpty) {
        selectedCategoryId = ids.first;
      } else {
        selectedCategoryId = null;
      }
    });
  }

  void handlePrioritySelected(String priority) {
    setState(() {
      selectedPriority = priority;
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
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  void _createTask() async {
    if (_titleController.text.isEmpty ||
        _selectedDate == null ||
        selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.authResponse == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
      return;
    }

    final task = Task(
      title: _titleController.text,
      description:
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
      taskDate: _selectedDate!,
      categoryId: selectedCategoryIds.first,
      priority: selectedPriority,
      notificationTime: _selectedTime,
      completed: false,
    );

    final success = await TaskService().addTask(task);

    if (success) {
      if (mounted) {
        widget.onTaskAdded(task);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to create task')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.itemBgColor,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: colors.textColor, size: 24),
          ),
          title: Text(
            'Add task',
            style: TextStyle(
              color: colors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: colors.bgColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Title',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: colors.textColor),
                  decoration: InputDecoration(
                    hintText: 'Enter task title',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: colors.itemBgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.deepPurpleAccent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Task Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Enter task description',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    hintFadeDuration: const Duration(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.deepPurpleAccent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: colors.itemBgColor,
                  ),
                  style: TextStyle(color: colors.textColor),
                ),
                const SizedBox(height: 18),
                Text(
                  'Task date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.itemBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey, width: 2),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: colors.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDate == null
                              ? 'Select date'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.itemBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: OutlinedButton(
                    onPressed: () => _selectTime(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey, width: 2),
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: colors.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedTime == null
                              ? 'Select time for notification'
                              : '${_selectedTime!.hour}:${_selectedTime!.minute}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Select repeat days',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 18),
                PrioritySelector(onPrioritySelected: handlePrioritySelected),
                const SizedBox(height: 18),
                CategoryList(
                  categories:
                      widget.categories
                          .map(
                            (c) => CategoryChip(
                              id: c.id,
                              label: c.name,
                              color: Colors.deepPurpleAccent.shade700,
                              isSelected: selectedCategoryIds.contains(c.id),
                            ),
                          )
                          .toList(),
                  isMultiSelect: false,
                  onCategorySelected: handleSelectedCategories,
                  onCategoryUpdated: (covariant) {},
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _createTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryColor,
                        foregroundColor: colors.textColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 34,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Create Task",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
