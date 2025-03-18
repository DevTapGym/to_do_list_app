import 'package:flutter/material.dart';

class Task {
  String title;
  String? description;
  DateTime taskDate;
  String category;
  String priority;
  bool completed;
  TimeOfDay? notificationTime;
  List<int>? repeatDays = []; // 0 = thứ 2, 1 = thứ 3, ..., 6 = chủ nhật

  // Constructor
  Task({
    required this.title,
    required this.description,
    required this.taskDate,
    required this.category,
    required this.priority,
    this.completed = false,
    this.notificationTime,
    this.repeatDays,
  });

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': taskDate.toIso8601String(),
      'category': category,
      'priority': priority,
      'completed': completed,
    };
  }

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      taskDate: DateTime.parse(json['dueDate']),
      category: json['category'],
      priority: json['priority'],
      completed: json['completed'],
    );
  }

  @override
  String toString() {
    return 'Task(title: $title, description: $description, dueDate: $taskDate, category: $category, priority: $priority, completed: $completed)';
  }
}
