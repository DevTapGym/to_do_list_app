import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/services/injections.dart';
import 'package:to_do_list_app/services/team_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';

class TeamTaskDetail extends StatefulWidget {
  final TeamTask task;
  final bool canEdit;
  final bool isLeader;
  const TeamTaskDetail({
    super.key,
    required this.task,
    required this.canEdit,
    required this.isLeader,
  });
  @override
  State<TeamTaskDetail> createState() => _TeamTaskDetailState();
}

class _TeamTaskDetailState extends State<TeamTaskDetail> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime taskDate;
  late Priority selectedPriority;
  bool get canEditTitle => widget.isLeader;
  bool get canEditDeadline => widget.isLeader;
  bool get canEditPriority => widget.isLeader;
  bool get canEditDescription => widget.canEdit;
  TeamService teamService = getIt.get<TeamService>();
  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(
      text: widget.task.description,
    );
    taskDate = widget.task.deadline;
    selectedPriority = widget.task.priority;
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
              Navigator.of(context).pop('refresh');
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
        body: Padding(
          padding: EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  'Title',
                  titleController,
                  canEdit: canEditTitle,
                ),
                SizedBox(height: 12),
                CheckboxListTile(
                  title: Text(
                    'Completed',
                    style: TextStyle(color: colors.textColor),
                  ),
                  value: widget.task.isCompleted,
                  onChanged:
                      widget.canEdit
                          ? (value) {
                            setState(() {
                              widget.task.isCompleted = value ?? false;
                            });
                          }
                          : null,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: colors.primaryColor,
                ),
                SizedBox(height: 12),
                _buildEnumDropdownField<Priority>(
                  label: 'Priority',
                  items: Priority.values,
                  selectedValue: selectedPriority,
                  getLabel: (val) => val.name,
                  onChanged:
                      canEditPriority
                          ? (value) {
                            if (value != null) {
                              setState(() {
                                selectedPriority = value;
                              });
                            }
                          }
                          : (_) {},
                ),

                SizedBox(height: 24),

                _buildDatePicker(context),

                SizedBox(height: 12),

                Text(
                  'Description',
                  style: TextStyle(
                    color: colors.textColor,
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
                  readOnly: !canEditDescription,
                  style: TextStyle(color: colors.textColor),
                ),
                SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (widget.canEdit)
                      _buildOutlinedButton(
                        icon: Icons.update,
                        label: 'Update',
                        color: colors.primaryColor,
                        onPressed: () async {
                          widget.task.title = titleController.text;
                          widget.task.description = descriptionController.text;
                          widget.task.priority = selectedPriority;
                          widget.task.deadline = taskDate;

                          final isSuccess = await teamService.UpdateTeamTask(
                            widget.task,
                          );
                          if (isSuccess) {
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Updated successfully')),
                              );
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Update failed. Please try again.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    if (widget.isLeader)
                      _buildOutlinedButton(
                        icon: Icons.delete,
                        label: 'Delete',
                        color: Colors.red,
                        onPressed: () {
                          _showConfirmationDialog(context);
                        },
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
    bool canEdit = false,
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
        SizedBox(height: 8),
        TextFormField(
          readOnly: !canEdit,
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
        text:
            "${taskDate.day}/${taskDate.month}/${taskDate.year}",
      ),
      readOnly: true,
      enabled: canEditDeadline,
      decoration: InputDecoration(
        labelText: 'Task Date',
        hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
        labelStyle: TextStyle(color: colors.textColor, fontSize: 18),
        filled: true,
        fillColor: colors.itemBgColor,
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
          borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: colors.primaryColor),
      ),
      onTap:
          canEditDeadline
              ? () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: widget.task.deadline,
                  firstDate: widget.task.deadline,
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null && pickedDate != widget.task.deadline) {
                  setState(() {
                    taskDate = pickedDate;
                  });
                }
              }
              : null,
    );
  }

  Widget _buildEnumDropdownField<T>({
    required String label,
    required List<T> items,
    required T selectedValue,
    required String Function(T) getLabel,
    required ValueChanged<T?> onChanged,
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
        SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: selectedValue,
          decoration: _inputDecoration('Select $label'),
          dropdownColor: colors.itemBgColor,
          items:
              items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    getLabel(item),
                    style: TextStyle(color: colors.textColor),
                  ),
                );
              }).toList(),
          onChanged: canEditPriority ? onChanged : null,
          
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final colors = AppThemeConfig.getColors(context);

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
      filled: true,
      fillColor: colors.itemBgColor,
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
        borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2),
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
  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: Text('Are you sure you want to delete this Task?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () async {
                await teamService.DeleteTeamTask(widget.task.id!);
                Navigator.of(context).pop();
                Navigator.of(context).pop('refresh');
              },
            ),
          ],
        );
      },
    );
  }
}