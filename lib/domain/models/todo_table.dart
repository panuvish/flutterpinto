import 'package:drift/drift.dart';

class TodoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();
  DateTimeColumn get createdAt => dateTime().nullable()();

  // 0 = ต่ำ, 1 = กลาง, 2 = สูง
  IntColumn get priority => integer().withDefault(const Constant(0))();

  // 0 = ยังไม่เริ่ม, 1 = กำลังทำ, 2 = เสร็จแล้ว
  IntColumn get status => integer().withDefault(const Constant(0))();

  // วันครบกำหนด
  DateTimeColumn get dueDate => dateTime().nullable()();

  // วันที่กดเสร็จจริง
  DateTimeColumn get completedAt => dateTime().nullable()();

  // วันที่ย้ายไปถังขยะ
  DateTimeColumn get deletedAt => dateTime().nullable()();
}