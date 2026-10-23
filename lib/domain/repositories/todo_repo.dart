import 'package:drift/drift.dart';
import 'package:mobile_app_standard/domain/datasource/app_datebase.dart';

abstract class TodoRepositoryInterface {
  Future<void> addTodoItem(
    String title,
    String content, {
    DateTime? dueDate,
    int priority,
  });

  Future<List<TodoItem>> getAllTodoItems();

  // ลบถาวร
  Future<void> deleteTodoItem(int id);

  // ย้ายไปถังขยะ
  Future<void> softDeleteTodoItem(int id);

  // กู้คืนจากถังขยะ
  Future<void> restoreTodoItem(int id);

  Future<void> updatePriorityTodoItem(int id, int priority);

  Future<void> updateTodoStatus(int id, int status);

  Future<void> updateTodoDueDate(int id, DateTime? dueDate);

  Future<void> updateTodoItem(
    int id,
    String title,
    String content, {
    DateTime? dueDate,
  });
}

class TodoRepository extends TodoRepositoryInterface {
  final AppDatabase db;

  TodoRepository(this.db);

  // priority
  @override
  Future<void> addTodoItem(
    String title,
    String content, {
    DateTime? dueDate,
    int priority = 1,
  }) async {
    await db.into(db.todoItems).insert(
          TodoItemsCompanion.insert(
            title: title,
            content: content,
            priority: Value(priority.clamp(0, 2)),
            dueDate: Value(dueDate),
          ),
        );
  }

  @override
  Future<List<TodoItem>> getAllTodoItems() async {
    return (db.select(db.todoItems)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.priority,
                  mode: OrderingMode.desc,
                ),
            (t) => OrderingTerm(
                  expression: t.id,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();
  }

  @override
  Future<void> deleteTodoItem(int id) async {
    await (db.delete(db.todoItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> softDeleteTodoItem(int id) async {
    await (db.update(db.todoItems)..where((tbl) => tbl.id.equals(id))).write(
      TodoItemsCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  @override
  Future<void> restoreTodoItem(int id) async {
    await (db.update(db.todoItems)..where((tbl) => tbl.id.equals(id))).write(
      const TodoItemsCompanion(deletedAt: Value(null)),
    );
  }

  @override
  Future<void> updatePriorityTodoItem(int id, int priority) async {
    await (db.update(db.todoItems)..where((tbl) => tbl.id.equals(id))).write(
      TodoItemsCompanion(priority: Value(priority.clamp(0, 2))),
    );
  }

  @override
  Future<void> updateTodoStatus(int id, int status) async {
    if (status < 0 || status > 2) {
      throw ArgumentError('status must be 0, 1, or 2');
    }

    await (db.update(db.todoItems)..where((tbl) => tbl.id.equals(id))).write(
      TodoItemsCompanion(
        status: Value(status),
        completedAt: Value(status == 2 ? DateTime.now() : null),
      ),
    );
  }

  @override
  Future<void> updateTodoDueDate(int id, DateTime? dueDate) async {
    await (db.update(db.todoItems)..where((tbl) => tbl.id.equals(id))).write(
      TodoItemsCompanion(dueDate: Value(dueDate)),
    );
  }

  @override
  Future<void> updateTodoItem(
    int id,
    String title,
    String content, {
    DateTime? dueDate,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();

    if (trimmedTitle.length < 6 || trimmedTitle.length > 32) {
      throw ArgumentError('ชื่อ Todo ต้องมีความยาว 6–32 ตัวอักษร');
    }

    if (trimmedContent.isEmpty) {
      throw ArgumentError('กรุณากรอกรายละเอียด Todo');
    }

    await (db.update(db.todoItems)..where((tbl) => tbl.id.equals(id))).write(
      TodoItemsCompanion(
        title: Value(trimmedTitle),
        content: Value(trimmedContent),
        dueDate: Value(dueDate),
      ),
    );
  }
}