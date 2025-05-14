import 'package:flutter/material.dart';

class Task {
  String title;
  String? description;
  DateTime taskDate;
  int categoryId;
  String? categoryName;
  String priority;
  bool completed;
  DateTime? createdAt;
  TimeOfDay? notificationTime;
  List<int>? repeatDays = []; // 0 = thứ 2, 1 = thứ 3, ..., 6 = chủ nhật

  // Constructor
  Task({
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
  });

  // Convert Task to JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      description: json['description'],
      taskDate: DateTime.parse(json['dueDate']),
      categoryId: json['categoryId'],
      priority: json['priority'],
      completed: json['completed'],
      createdAt:
          json['created'] != null
              ? DateTime.tryParse(json['created']['createdAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': taskDate.toIso8601String(),
      'categoryId': categoryId,
      'priority': priority,
      'completed': completed,
    };
  }
}
