import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:mobile_app_standard/domain/models/todo_table.dart';

part 'app_datebase.g.dart';

@DriftDatabase(tables: [TodoItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          print('Previous DB version: ${details.versionBefore}');
          print('Target schema version: $schemaVersion');
        },
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async { 
          if (from < 2) {
            await m.addColumn(todoItems, todoItems.priority);
          }

          // เพิ่มสถานะและวันครบกำหนด
          if (from < 3) {
            await m.addColumn(todoItems, todoItems.status);
            await m.addColumn(todoItems, todoItems.dueDate);
          }

          // ถังขยะ
          if (from < 4) {
            await m.addColumn(todoItems, todoItems.completedAt);
            await m.addColumn(todoItems, todoItems.deletedAt);
            
            await customStatement('UPDATE todo_items SET priority = 1');
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'db');
  }
}