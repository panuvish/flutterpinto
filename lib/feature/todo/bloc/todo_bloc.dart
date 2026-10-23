import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/domain/datasource/app_datebase.dart';
import 'package:mobile_app_standard/domain/repositories/todo_repo.dart';
import 'package:mobile_app_standard/feature/todo/model/todo_model.dart';
import 'package:mobile_app_standard/locator.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  static const trashRetention = Duration(days: 30);

  final TodoRepositoryInterface todoRepo =
      locator<TodoRepositoryInterface>();

  TodoBloc() : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);

    on<AddTodo>((e, emit) => _mutate(emit, 'add todo', () {
          return todoRepo.addTodoItem(e.title.trim(), e.content.trim());
        }));

    // ลบถาวร (ใช้จากหน้าถังขยะ)
    on<DeleteTodo>((e, emit) => _mutate(emit, 'delete todo', () {
          return todoRepo.deleteTodoItem(e.id);
        }));

    on<SoftDeleteTodo>((e, emit) => _mutate(emit, 'move todo to trash', () {
          return todoRepo.softDeleteTodoItem(e.id);
        }));

    on<RestoreTodo>((e, emit) => _mutate(emit, 'restore todo', () {
          return todoRepo.restoreTodoItem(e.id);
        }));

    on<EmptyTrash>((e, emit) => _mutate(emit, 'empty trash', () async {
          final current = state;
          if (current is! TodoLoaded) return;
          for (final t in current.trash) {
            await todoRepo.deleteTodoItem(t.id);
          }
        }));

    on<UpdatePriorityTodo>((e, emit) => _mutate(emit, 'update priority', () {
          return todoRepo.updatePriorityTodoItem(e.id, e.priority);
        }));

    on<UpdateTodoStatus>((e, emit) => _mutate(emit, 'update status', () {
          return todoRepo.updateTodoStatus(e.id, e.status);
        }));

    on<UpdateTodoDueDate>((e, emit) => _mutate(emit, 'update due date', () {
          return todoRepo.updateTodoDueDate(e.id, e.dueDate);
        }));

    on<EditTodo>((e, emit) => _mutate(emit, 'edit todo', () {
          return todoRepo.updateTodoItem(
            e.id,
            e.title,
            e.content,
            dueDate: e.dueDate,
          );
        }));

    add(LoadTodos());
  }

  Future<void> _onLoadTodos(
    LoadTodos event,
    Emitter<TodoState> emit,
  ) async {
    emit(TodoLoading());
    try {
      await _emitLoaded(emit);
    } catch (e, stackTrace) {
      _logError('load todos', e, stackTrace);
      emit(TodoError('Failed to load todos: $e'));
    }
  }

  Future<void> _mutate(
    Emitter<TodoState> emit,
    String label,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      await _emitLoaded(emit);
    } catch (e, stackTrace) {
      _logError(label, e, stackTrace);
      emit(TodoError('Failed to $label: $e'));
    }
  }

  Future<void> _emitLoaded(Emitter<TodoState> emit) async {
    final rows = await todoRepo.getAllTodoItems();
    final cutoff = DateTime.now().subtract(trashRetention);

    final alive = <TodoModel>[];
    final trash = <TodoModel>[];

    for (final row in rows) {
      final todo = TodoModel.fromDrift(row);
      final deletedAt = todo.deletedAt;

      if (deletedAt == null) {
        alive.add(todo);
      } else if (deletedAt.isBefore(cutoff)) {
        await todoRepo.deleteTodoItem(todo.id);
      } else {
        trash.add(todo);
      }
    }

    trash.sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));

    emit(TodoLoaded(alive, trash: trash));
  }

  void _logError(String label, Object e, StackTrace st) {
    if (kDebugMode) {
      print('Failed to $label: $e');
      print(st);
    }
  }
}