import 'package:to_do_list_app/models/category.dart';
import 'package:to_do_list_app/models/task.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final List<Category> categories;

  TaskLoaded({required this.tasks, required this.categories});
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}
