import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';

class DetailTaskScreen extends StatefulWidget {
  final Task task;
  final List<CategoryChip> categories;
  const DetailTaskScreen({
    super.key,
    required this.task,
    required this.categories,
  });
  @override
  State<DetailTaskScreen> createState() => _DetailTaskScreenState();
}

class _DetailTaskScreenState extends State<DetailTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;
  late DateTime taskDate;
  late TimeOfDay? notificationTime;
  String? selectedPriority;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(
      text: widget.task.description,
    );
    categoryController = TextEditingController(text: widget.task.category);
    taskDate = widget.task.taskDate;
    notificationTime = widget.task.notificationTime;
    selectedPriority = widget.task.priority;
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
          title: Center(
            child: Text(
              'Detail Task',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: Padding(
          padding: EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Title', titleController),
                SizedBox(height: 12),

                _buildDropdownField(
                  'Priority',
                  ['Low', 'Medium', 'High'],
                  selectedPriority,
                  (value) {
                    setState(() {
                      selectedPriority = value;
                    });
                  },
                ),
                SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: CategoryList(
                    categories: widget.categories,
                    isMultiSelect: false,
                    showAddButton: false,
                    onCategoryUpdated: (category) {},
                    onCategorySelected: (selectedCategories) {
                      if (selectedCategories.isNotEmpty) {
                        categoryController.text = selectedCategories.first;
                      }
                    },
                  ),
                ),
                _buildTextField('Category', categoryController, isEdit: true),
                SizedBox(height: 24),

                _buildDatePicker(context),
                SizedBox(height: 12),

                _buildTimePicker(context),
                SizedBox(height: 12),

                Text(
                  'Description',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  decoration: _inputDecoration('Enter task description'),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildOutlinedButton(
                      icon: Icons.update,
                      label: 'Update',
                      color: Colors.deepPurpleAccent,
                      onPressed: () {},
                    ),
                    _buildOutlinedButton(
                      icon: Icons.delete,
                      label: 'Delete',
                      color: Colors.red,
                      onPressed: () {},
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          readOnly: isEdit,
          controller: controller,
          decoration: _inputDecoration('Enter $label'),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(
        text:
            "${widget.task.taskDate.day}/${widget.task.taskDate.month}/${widget.task.taskDate.year}",
      ),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Task Date',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: widget.task.taskDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null && pickedDate != widget.task.taskDate) {
          setState(() {
            widget.task.taskDate = pickedDate;
          });
        }
      },
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(
        text:
            widget.task.notificationTime != null
                ? "${widget.task.notificationTime!.hour}:${widget.task.notificationTime!.minute}"
                : "No time set",
      ),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Notification Time',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.access_time),
      ),
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: widget.task.notificationTime ?? TimeOfDay.now(),
        );

        if (pickedTime != null) {
          setState(() {
            widget.task.notificationTime = pickedTime;
          });
        }
      },
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          decoration: _inputDecoration('Select $label'),
          dropdownColor: Colors.black,
          items:
              items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey, width: 2),
      ),
      filled: true,
      fillColor: Colors.black,
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
