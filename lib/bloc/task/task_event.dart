import 'package:to_do_list_app/models/task.dart';

abstract class TaskEvent {}

class LoadTasksAndCategories extends TaskEvent {
  final int userId;
  final DateTime? dueDate;

  LoadTasksAndCategories({required this.userId, this.dueDate});
}

class AddTask extends TaskEvent {
  final Task task;
  AddTask(this.task);
}

class UpdateTask extends TaskEvent {
  final Task task;
  UpdateTask(this.task);
}

class SearchTasks extends TaskEvent {
  final String keyword;
  SearchTasks(this.keyword);
}
