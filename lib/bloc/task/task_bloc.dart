import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_list_app/bloc/task/task_event.dart';
import 'package:to_do_list_app/bloc/task/task_state.dart';
import 'package:to_do_list_app/services/category_service.dart';
import 'package:to_do_list_app/services/task_service.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskService taskService;
  final CategoryService categoryService;

  TaskBloc({required this.taskService, required this.categoryService})
    : super(TaskInitial()) {
    on<LoadTasksAndCategories>(_onLoadTasksAndCategories);
  }

  Future<void> _onLoadTasksAndCategories(
    LoadTasksAndCategories event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final tasks = await taskService.getTasks(
        userId: event.userId,
        dueDate: event.dueDate!,
      );
      final categories = await categoryService.getCategories(event.userId);
      emit(TaskLoaded(tasks: tasks, categories: categories));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
