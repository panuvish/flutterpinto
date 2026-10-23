import 'package:mobile_app_standard/domain/datasource/app_datebase.dart';

class TodoModel {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int priority;

  // 0 = ยังไม่เริ่ม, 1 = กำลังทำ, 2 = เสร็จแล้ว
  final int status;
  final DateTime? dueDate;

  // วันที่กดเสร็จจริง
  final DateTime? completedAt;

  // วันที่ย้ายไปถังขยะ
  final DateTime? deletedAt;

  TodoModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.priority,
    this.status = 0,
    this.dueDate,
    this.completedAt,
    this.deletedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    DateTime? date(String key) =>
        json[key] == null ? null : DateTime.parse(json[key] as String);

    return TodoModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      priority: json['priority'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      dueDate: date('dueDate'),
      completedAt: date('completedAt'),
      deletedAt: date('deletedAt'),
    );
  }

  factory TodoModel.fromDrift(TodoItem data) {
    return TodoModel(
      id: data.id,
      title: data.title,
      content: data.content,
      createdAt: data.createdAt ?? DateTime.now(),
      priority: data.priority,
      status: data.status,
      dueDate: data.dueDate,
      completedAt: data.completedAt,
      deletedAt: data.deletedAt,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'priority': priority,
      'status': status,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}