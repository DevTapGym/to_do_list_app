import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/services/task_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';

class DetailTaskScreen extends StatefulWidget {
  final int taskId;
  final List<CategoryChip> categories;

  const DetailTaskScreen({
    super.key,
    required this.taskId,
    required this.categories,
  });

  @override
  State<DetailTaskScreen> createState() => _DetailTaskScreenState();
}

class _DetailTaskScreenState extends State<DetailTaskScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  late DateTime taskDate;
  late TimeOfDay? notificationTime;
  String? selectedPriority;
  int? selectedCategoryId;
  bool _isLoading = true;
  Task? task;
  final TaskService taskService = TaskService();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    try {
      final fetchedTask = await taskService.getTaskById(widget.taskId);
      if (mounted) {
        setState(() {
          task = fetchedTask;
          titleController.text = fetchedTask.title;
          descriptionController.text = fetchedTask.description ?? '';
          categoryController.text =
              widget.categories
                  .firstWhere(
                    (c) => c.id == fetchedTask.categoryId,
                    orElse:
                        () => CategoryChip(
                          id: 0,
                          label: 'Unknown',
                          color: Colors.grey,
                          isSelected: false,
                        ),
                  )
                  .label;
          taskDate = fetchedTask.taskDate;
          notificationTime = fetchedTask.notificationTime;
          selectedPriority = fetchedTask.priority;
          selectedCategoryId = fetchedTask.categoryId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load task: $e')));
      }
    }
  }

  bool _canEditTask() {
    if (task == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(taskDate.year, taskDate.month, taskDate.day);

    // Cho phép chỉnh sửa task chưa hoàn thành ở hiện tại hoặc tương lai
    return !task!.completed &&
        (taskDay.isAfter(today) || taskDay.isAtSameMomentAs(today));
  }

  bool _canDeleteTask() {
    if (task == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(taskDate.year, taskDate.month, taskDate.day);

    // Chỉ cho phép xóa task chưa hoàn thành và trong tương lai (không phải hôm nay)
    return !task!.completed && taskDay.isAfter(today);
  }

  Future<void> _updateTask() async {
    if (task == null) return;

    if (!_canEditTask()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot update completed or past tasks')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedTask = Task(
        id: task!.id,
        title: titleController.text,
        description:
            descriptionController.text.isNotEmpty
                ? descriptionController.text
                : null,
        taskDate: taskDate,
        categoryId: selectedCategoryId ?? task!.categoryId,
        priority: selectedPriority ?? task!.priority,
        completed: task!.completed,
        notificationTime: notificationTime,
      );

      final success = await taskService.updateTask(updatedTask);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task updated successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update task')),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update task: $e')));
      }
    }
  }

  Future<void> _deleteTask() async {
    if (task == null) return;

    if (!_canDeleteTask()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete completed, past, or today\'s tasks'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await taskService.deleteTask(widget.taskId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete task')),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete task: $e')));
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
            'Detail Task',
            style: TextStyle(
              color: colors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: colors.bgColor,
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          'Title',
                          titleController,
                          isEdit: !_canEditTask(),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField(
                          'Priority',
                          ['LOW', 'MEDIUM', 'HIGH'],
                          selectedPriority,
                          _canEditTask()
                              ? (value) {
                                setState(() {
                                  selectedPriority = value;
                                });
                              }
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          child: CategoryList(
                            categories: widget.categories,
                            isMultiSelect: false,
                            onCategoryUpdated: (category) {},
                            onCategorySelected:
                                _canEditTask()
                                    ? (List<int> selectedCategories) {
                                      setState(() {
                                        selectedCategoryId =
                                            selectedCategories.isNotEmpty
                                                ? selectedCategories.first
                                                : null;
                                        categoryController.text =
                                            selectedCategoryId != null
                                                ? widget.categories
                                                    .firstWhere(
                                                      (c) =>
                                                          c.id ==
                                                          selectedCategoryId,
                                                      orElse:
                                                          () => CategoryChip(
                                                            id: 0,
                                                            label: 'Unknown',
                                                            color: Colors.grey,
                                                            isSelected: false,
                                                          ),
                                                    )
                                                    .label
                                                : '';
                                      });
                                    }
                                    : (List<int> selectedCategories) {},
                          ),
                        ),
                        _buildTextField(
                          'Category',
                          categoryController,
                          isEdit: true,
                        ),
                        const SizedBox(height: 24),
                        _buildDatePicker(context),
                        const SizedBox(height: 12),
                        _buildTimePicker(context),
                        const SizedBox(height: 12),
                        Text(
                          'Description',
                          style: TextStyle(
                            color: colors.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          readOnly: !_canEditTask(),
                          decoration: _inputDecoration(
                            'Enter task description',
                          ),
                          style: TextStyle(color: colors.textColor),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildOutlinedButton(
                              icon: Icons.update,
                              label: 'Update',
                              color:
                                  _canEditTask()
                                      ? colors.primaryColor
                                      : Colors.grey,
                              onPressed: _canEditTask() ? _updateTask : () {},
                            ),
                            _buildOutlinedButton(
                              icon: Icons.delete,
                              label: 'Delete',
                              color:
                                  _canDeleteTask() ? Colors.red : Colors.grey,
                              onPressed: _canDeleteTask() ? _deleteTask : () {},
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isEdit = false,
  }) {
    final colors = AppThemeConfig.getColors(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          readOnly: isEdit || !_canEditTask(),
          controller: controller,
          decoration: _inputDecoration('Enter $label'),
          style: TextStyle(color: colors.textColor),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return TextFormField(
      controller: TextEditingController(
        text: '${taskDate.day}/${taskDate.month}/${taskDate.year}',
      ),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Task Date',
        hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
        labelStyle: TextStyle(color: colors.textColor, fontSize: 18),
        filled: true,
        fillColor: colors.itemBgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.deepPurpleAccent,
            width: 2,
          ),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: colors.primaryColor),
      ),
      onTap:
          _canEditTask()
              ? () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: taskDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null && pickedDate != taskDate) {
                  setState(() {
                    taskDate = pickedDate;
                  });
                }
              }
              : null,
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);

    return TextFormField(
      controller: TextEditingController(
        text:
            notificationTime != null
                ? '${notificationTime!.hour}:${notificationTime!.minute}'
                : 'No time set',
      ),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Notification Time',
        hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
        labelStyle: TextStyle(color: colors.textColor, fontSize: 18),
        filled: true,
        fillColor: colors.itemBgColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.deepPurpleAccent,
            width: 2,
          ),
        ),
        suffixIcon: Icon(Icons.access_time, color: colors.primaryColor),
      ),
      onTap:
          _canEditTask()
              ? () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: notificationTime ?? TimeOfDay.now(),
                );

                if (pickedTime != null) {
                  setState(() {
                    notificationTime = pickedTime;
                  });
                }
              }
              : null,
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?>? onChanged,
  ) {
    final colors = AppThemeConfig.getColors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: _inputDecoration('Select $label'),
          dropdownColor: colors.bgColor,
          items:
              items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: TextStyle(color: colors.textColor)),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final colors = AppThemeConfig.getColors(context);

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
      filled: true,
      fillColor: colors.itemBgColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
