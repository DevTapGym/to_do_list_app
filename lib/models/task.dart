import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Task {
  int? id;
  String title;
  String? description;
  DateTime taskDate;
  int categoryId;
  String? categoryName;
  String priority;
  bool completed;
  int? userId;
  DateTime? createdAt;
  TimeOfDay? notificationTime;
  List<int>? repeatDays = []; // 0 = thứ 2, 1 = thứ 3, ..., 6 = chủ nhật

  // Constructor
  Task({
    this.id,
    required this.title,
    required this.description,
    required this.taskDate,
    required this.priority,
    required this.categoryId,
    this.categoryName,
    this.createdAt,
    this.completed = false,
    this.notificationTime,
    this.repeatDays,
    this.userId,
  });

  // Convert Task to JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      taskDate: DateTime.parse(json['dueDate']),
      notificationTime:
          json['notificationTime'] != null
              ? TimeOfDay(
                hour: int.parse(json['notificationTime'].split(':')[0]),
                minute: int.parse(json['notificationTime'].split(':')[1]),
              )
              : null,
      categoryId: json['categoryId'],
      priority: json['priority'],
      completed: json['completed'],
      createdAt:
          json['created'] != null
              ? DateTime.tryParse(json['created']['createdAt'])
              : null,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': DateFormat('yyyy-MM-dd').format(taskDate),
      'categoryId': categoryId,
      'completed': completed,
      'notificationTime':
          notificationTime != null
              ? '${notificationTime!.hour.toString().padLeft(2, '0')}:${notificationTime!.minute.toString().padLeft(2, '0')}'
              : null,
      'priority': priority,
    };
  }

  Task copyWith({required bool completed}) {
    return Task(
      id: id,
      title: title,
      description: description,
      taskDate: taskDate,
      categoryId: categoryId,
      priority: priority,
      completed: completed,
      createdAt: createdAt,
      userId: userId,
      notificationTime: notificationTime,
      repeatDays: repeatDays,
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, taskDate: $taskDate, categoryId: $categoryId, priority: $priority, completed: $completed}';
  }
}
