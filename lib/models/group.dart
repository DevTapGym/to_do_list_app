import 'package:to_do_list_app/models/task.dart';

class Group {
  final String name;
  final String id;
  final List<Task> items;

  Group({required this.name, required this.id, required this.items});
}
