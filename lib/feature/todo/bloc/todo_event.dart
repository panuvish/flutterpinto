part of 'todo_bloc.dart';

@immutable
sealed class TodoEvent {}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String title;
  final String content;

  AddTodo({
    required this.title,
    required this.content,
  });
}

// ลบถาวร
class DeleteTodo extends TodoEvent {
  final int id;

  DeleteTodo({required this.id});
}

// ย้ายไปถังขยะ
class SoftDeleteTodo extends TodoEvent {
  final int id;

  SoftDeleteTodo({required this.id});
}

// กู้คืน
class RestoreTodo extends TodoEvent {
  final int id;

  RestoreTodo({required this.id});
}

// ลบงานทั้งหมดในถังขยะ
class EmptyTrash extends TodoEvent {
  EmptyTrash();
}

class UpdatePriorityTodo extends TodoEvent {
  final int id;
  final int priority;

  UpdatePriorityTodo({required this.id, required this.priority});
}

class UpdateTodoStatus extends TodoEvent {
  final int id;
  final int status;

  UpdateTodoStatus({
    required this.id,
    required this.status,
  });
}

class UpdateTodoDueDate extends TodoEvent {
  final int id;
  final DateTime? dueDate;

  UpdateTodoDueDate({
    required this.id,
    required this.dueDate,
  });
}

class EditTodo extends TodoEvent {
  final int id;
  final String title;
  final String content;
  final DateTime? dueDate;

  EditTodo({
    required this.id,
    required this.title,
    required this.content,
    required this.dueDate,
  });
}