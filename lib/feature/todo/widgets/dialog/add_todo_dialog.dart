import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_standard/feature/todo/bloc/todo_bloc.dart';
import 'package:mobile_app_standard/feature/todo/model/todo_model.dart';
import 'package:mobile_app_standard/i18n/app_strings.dart';

class EditTodoDialog extends StatefulWidget {
  final TodoModel todo;

  const EditTodoDialog({
    super.key,
    required this.todo,
  });

  @override
  State<EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<EditTodoDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  DateTime? _dueDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.todo.title);
    _contentController = TextEditingController(text: widget.todo.content);
    _dueDate = widget.todo.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _chooseDueDate() async {
    final s = S.of(context);
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: s.pickDueDate,
      cancelText: s.cancel,
      confirmText: s.confirm,
    );

    if (selected != null && mounted) {
      setState(() {
        _dueDate = selected;
      });
    }
  }

  void _save() {
    final s = S.of(context);
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.length < 6 || title.length > 32) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.titleLengthError)),
      );
      return;
    }

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.contentRequired)),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    context.read<TodoBloc>().add(
          EditTodo(
            id: widget.todo.id,
            title: title,
            content: content,
            dueDate: _dueDate,
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final dateText = _dueDate == null
        ? s.noDateYet
        : DateFormat('dd/MM/yyyy').format(_dueDate!);

    return AlertDialog(
      title: Text(s.editTodo),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              maxLength: 32,
              decoration: InputDecoration(
                labelText: s.editName,
                hintText: s.editNameHint,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: s.editContent,
                hintText: s.editContentHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _chooseDueDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(s.dueDateColon(dateText)),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _dueDate == null
                    ? null
                    : () {
                        setState(() {
                          _dueDate = null;
                        });
                      },
                icon: const Icon(Icons.event_busy),
                label: Text(s.clearDueDate),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(s.cancel),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.save),
          label: Text(s.save),
        ),
      ],
    );
  }
}