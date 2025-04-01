import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';

class AddTaskScreen extends StatefulWidget {
  final Function(Task) onTaskAdded;
  final List<CategoryChip> categories;

  const AddTaskScreen({
    super.key,
    required this.onTaskAdded,
    required this.categories,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<int> selectedDays = [];
  List<String> selectedCategories = [];
  late String selectedPriority;

  void handleSelectionChanged(List<int> days) {
    setState(() {
      selectedDays = days;
    });
  }

  void handleselectedCategories(List<String> categories) {
    setState(() {
      selectedCategories = categories;
    });
  }

  void handlePrioritySelected(String priority) {
    setState(() {
      selectedPriority = priority;
    });
  }

  // Hàm chọn ngày
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
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  void _createTask() {
    if (_titleController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    Task newTask = Task(
      title: _titleController.text,
      description: _descriptionController.text,
      taskDate: _selectedDate!,
      category:
          selectedCategories.isNotEmpty ? selectedCategories[0] : 'Personal',
      priority: selectedPriority,
      repeatDays: selectedDays,
      completed: false,
      notificationTime: _selectedTime,
    );

    Navigator.pop(context, newTask);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 34),
          ),
          title: Text(
            'Add task',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: Colors.black,
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
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter task title',
                    hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'Task Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: 'Enter task description',
                    hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
                    hintFadeDuration: Duration(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.deepPurpleAccent,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.black,
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 18),
                Text(
                  'Task date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey, width: 2),
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.deepPurpleAccent,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _selectedDate == null
                              ? 'Select date'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _selectTime(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey, width: 2),
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.deepPurpleAccent,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _selectedTime == null
                              ? 'Select time for notification'
                              : '${_selectedTime!.hour}:${_selectedTime!.minute}',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'Select repeat days',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                WeekdaySelector(onSelectionChanged: handleSelectionChanged),
                SizedBox(height: 18),
                PrioritySelector(onPrioritySelected: handlePrioritySelected),
                SizedBox(height: 18),
                CategoryList(
                  categories: widget.categories,
                  isMultiSelect: false,
                  showAddButton: false,
                  onCategorySelected: handleselectedCategories,
                  onCategoryUpdated: (covariant) {},
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _createTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 34,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
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
