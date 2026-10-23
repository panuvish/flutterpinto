// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'todo_page_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class TodoPageLocalizationsEn extends TodoPageLocalizations {
  TodoPageLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title_todo => 'Todo List';

  @override
  String get text_no_todo => 'No todos available.';

  @override
  String get title_add_todo => 'Add Todo';

  @override
  String get text_added => 'Added';

  @override
  String get text_added_success => 'Todo added successfully.';

  @override
  String get label_title => 'Title';

  @override
  String get label_content => 'Content';
}
