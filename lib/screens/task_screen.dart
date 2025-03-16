import 'package:flutter/material.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

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
                onCategorySelected: (String category) {},
              ),
            ),
            Container(
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTaskScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(40, 6, 40, 6),
                    ),
                    child: Text(
                      'Add Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

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

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = pickedTime;
        } else {
          _selectedEndTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
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
          body: Container(
            decoration: BoxDecoration(color: Colors.black),
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
                      fillColor: Colors.black, // Nền xám tối
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 18),
                  Text(
                    'Due Date',
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start time',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => _selectTime(context, true),
                            icon: Icon(
                              Icons.access_time,
                              color: Colors.deepPurpleAccent,
                              size: 20,
                            ),
                            label: Text(
                              _selectedStartTime == null
                                  ? 'Select start time'
                                  : '${_selectedStartTime!.hour}:${_selectedStartTime!.minute}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey, width: 2),
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End time',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => _selectTime(context, false),
                            icon: Icon(
                              Icons.access_time,
                              color: Colors.deepPurpleAccent,
                              size: 20,
                            ),
                            label: Text(
                              _selectedEndTime == null
                                  ? 'Select end time'
                                  : '${_selectedEndTime!.hour}:${_selectedEndTime!.minute}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey, width: 2),
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  WeekdaySelector(onSelectionChanged: (selectedDays) {}),
                  SizedBox(height: 18),
                  PrioritySelector(onPrioritySelected: (priority) {}),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: CategoryList(
                      categories: [
                        {'label': 'Personal', 'color': Colors.red},
                        {'label': 'Work', 'color': Colors.purple},
                        {'label': 'Health', 'color': Colors.green},
                        {'label': 'Study', 'color': Colors.blue},
                        {'label': 'Finance', 'color': Colors.orange},
                        {'label': 'Shopping', 'color': Colors.pink},
                      ],
                      onCategorySelected: (String category) {},
                    ),
                  ),
                  SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
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
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
