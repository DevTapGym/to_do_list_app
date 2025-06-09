import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
              'add_task'.tr(),
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
                      'task_title'.tr(),
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
                        hintText: 'enter_task_title'.tr(),
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: colors.subtitleColor,
                        ),
                        labelStyle: TextStyle(color: colors.textColor),
                        filled: true,
                        fillColor: colors.itemBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colors.textColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colors.textColor,
                            width: 2,
                          ),
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
                      'task_description'.tr(),
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
                        hintText: 'enter_task_description'.tr(),
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: colors.subtitleColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colors.textColor,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: colors.textColor,
                            width: 2,
                          ),
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
                      'due_date'.tr(),
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
                                  ? 'select_date'.tr()
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
                      'assign_to'.tr(),
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
                          borderSide: BorderSide(
                            color: colors.textColor,
                            width: 2,
                          ),
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
                          onPressed: () async {
                            if (_selectedDate == null ||
                                _selectedMember == null ||
                                _titleController.text.isEmpty ||
                                _selectedPriority == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'please_fill_in_all_information'.tr(),
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
                            'create_task'.tr(),
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
