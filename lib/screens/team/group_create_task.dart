import 'package:flutter/material.dart';
import 'package:to_do_list_app/main.dart';
import 'package:to_do_list_app/models/auth_response.dart';
import 'package:to_do_list_app/models/team.dart';
import 'package:to_do_list_app/services/injections.dart';
import 'package:to_do_list_app/services/team_service.dart';
import 'package:to_do_list_app/utils/theme_config.dart';
import 'package:to_do_list_app/widgets/icon_button_wg.dart';

class GroupCreateTask extends StatefulWidget {
  final Team team;
  const GroupCreateTask({super.key, required this.team});

  @override
  State<GroupCreateTask> createState() => _GroupCreateTaskState();
}

class _GroupCreateTaskState extends State<GroupCreateTask> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedMember;
  String? _selectedPriority;

  TeamService _teamService = getIt.get<TeamService>();
  List<User> _teamMembers = [];
  

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeConfig.getColors(context);
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: colors.bgColor,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: colors.textColor, size: 34),
            ),
            title: Text(
              'Add task',
              style: TextStyle(
                color: colors.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(color: colors.bgColor),
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
                    SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: TextStyle(color: colors.textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter task title',
                        hintStyle: TextStyle(fontSize: 16, color: colors.subtitleColor),
                        labelStyle: TextStyle(color: colors.textColor),
                        filled: true,
                        fillColor: colors.itemBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.textColor  , width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.textColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colors.primaryColor,
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
                        color: colors.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        fillColor: colors.itemBgColor,
                        filled: true,
                        hintText: 'Enter task description',
                        hintStyle: TextStyle(fontSize: 16, color: colors.subtitleColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.textColor, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.textColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colors.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      style: TextStyle(color: colors.textColor),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Due Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _selectDate(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.textColor, width: 2),
                          backgroundColor: colors.itemBgColor,
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
                              color: colors.primaryColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
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
                    SizedBox(height: 18),
                    Text(
                      'Assign To',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedMember,
                      dropdownColor: colors.itemBgColor,
                      items:
                          _teamMembers.map((member) {
                            return DropdownMenuItem<int>(
                              value: member.id,
                              child: Text(
                                member.name,
                                style: TextStyle(color: colors.textColor),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMember = value;
                        });
                      },
                      style: TextStyle(color: colors.textColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: colors.itemBgColor,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: colors.textColor, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colors.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    PrioritySelector(
                      onPrioritySelected: (priority) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      },
                    ),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async{
                            if (_selectedDate == null ||
                                _selectedMember == null ||
                                _titleController.text.isEmpty ||
                                _selectedPriority == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Please fill in all information!",
                                  ),
                                ),
                              );
                              return;
                            }
                            await _teamService.CreateTeamTask(
                              _titleController.text,
                              _descriptionController.text,
                              _selectedDate!,
                              _selectedPriority!,
                              widget.team.id,
                              _selectedMember!,
                            );
                            Navigator.of(context).pop('refresh');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primaryColor,
                            foregroundColor: colors.textColor,
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
                              color: colors.textColor,
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
      ),
      debugShowCheckedModeBanner: false,
    );
  }
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime(2040),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
  void _loadTeamMembers() async {
    final members = await _teamService.getMembersByTeamId(widget.team.id);
    setState(() {
      _teamMembers = members;
      if (members.isNotEmpty) _selectedMember = members.first.id;
    });
  }
}
