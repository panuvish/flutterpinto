// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'todo_page_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class TodoPageLocalizationsTh extends TodoPageLocalizations {
  TodoPageLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get title_todo => 'รายการที่ต้องทํา';

  @override
  String get text_no_todo => 'ไม่มีรายการที่ต้องทํา';

  @override
  String get title_add_todo => 'เพิ่มรายการที่ต้องทํา';

  @override
  String get text_added => 'เพิ่มแล้ว';

  @override
  String get text_added_success => 'เพิ่มรายการที่ต้องทําเรียบร้อยแล้ว';

  @override
  String get label_title => 'หัวข้อ';

  @override
  String get label_content => 'เนื้อหา';
}
