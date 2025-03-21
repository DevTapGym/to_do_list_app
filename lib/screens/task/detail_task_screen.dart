import 'package:flutter/material.dart';
import 'package:to_do_list_app/models/task.dart';

class DetailTaskScreen extends StatefulWidget {
  final Task task;
  const DetailTaskScreen({super.key, required this.task});

  @override
  State<DetailTaskScreen> createState() => _DetailTaskScreenState();
}

class _DetailTaskScreenState extends State<DetailTaskScreen> {
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
          title: Padding(
            padding: const EdgeInsets.only(left: 80),
            child: Text(
              'Detail task',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
        backgroundColor: Colors.black,
        body: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title task',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 12),
              Column(
                children: [
                  _buildInfoRow(
                    Icons.calendar_today,
                    "Task Date: ${widget.task.taskDate.day}/${widget.task.taskDate.month}/${widget.task.taskDate.year}",
                    Colors.green,
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.access_time,
                    "Notification: ${widget.task.notificationTime!.hour.toString()}h:${widget.task.notificationTime!.minute.toString()}p",
                    Colors.orange,
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.flag,
                    '${widget.task.priority} Priority',
                    Colors.purple,
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.label,
                    'Category: ${widget.task.category}',
                    Colors.blue,
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Description',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                maxLines: 4,
                initialValue: '${widget.task.description}',
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
              SizedBox(height: 24),
              Divider(color: Colors.grey, thickness: 2),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.update, color: Colors.deepPurpleAccent),
                    label: Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.deepPurpleAccent,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.delete, color: Colors.red),
                    label: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}
