import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_standard/feature/todo/bloc/todo_bloc.dart';
import 'package:mobile_app_standard/feature/todo/model/todo_model.dart';
import 'package:mobile_app_standard/i18n/app_strings.dart';
import 'package:mobile_app_standard/shared/tokens/app_theme.dart';

const int kTrashRetentionDays = 30;

@RoutePage()
class TrashPage extends StatelessWidget {
  const TrashPage({super.key});

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String okLabel,
  }) async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(d).pop(true),
            child: Text(okLabel),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        final trash = state is TodoLoaded ? state.trash : const <TodoModel>[];

        return Scaffold(
          appBar: AppBar(
            title: Text(s.trash),
            actions: [
              if (trash.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    final ok = await _confirm(
                      context,
                      title: s.emptyTrash,
                      message: s.emptyTrashConfirm(trash.length),
                      okLabel: s.emptyTrash,
                    );
                    if (ok && context.mounted) {
                      context.read<TodoBloc>().add(EmptyTrash());
                    }
                  },
                  child: Text(s.emptyTrash),
                ),
            ],
          ),
          body: trash.isEmpty
              ? Center(
                  child: Text(
                    s.trashEmpty,
                    style: TextStyle(color: context.textSub),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: trash.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Text(
                        s.trashHint(kTrashRetentionDays),
                        style: TextStyle(color: context.textSub, fontSize: 12),
                      );
                    }
                    final item = trash[index - 1];
                    final deletedAt = item.deletedAt ?? DateTime.now();
                    final left = (kTrashRetentionDays -
                            DateTime.now().difference(deletedAt).inDays)
                        .clamp(0, kTrashRetentionDays);

                    return Container(
                      decoration: BoxDecoration(
                        color: context.cardColor2,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: context.shadowColor2,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          item.title,
                          style: TextStyle(
                            color: context.textMain,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${DateFormat('dd/MM/yyyy').format(deletedAt)} · ${s.daysLeft(left)}',
                          style:
                              TextStyle(color: context.textSub, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: s.restore,
                              color: context.blue,
                              icon: const Icon(
                                Icons.restore_from_trash_outlined,
                              ),
                              onPressed: () => context
                                  .read<TodoBloc>()
                                  .add(RestoreTodo(id: item.id)),
                            ),
                            IconButton(
                              tooltip: s.deleteForever,
                              color: Colors.red,
                              icon: const Icon(Icons.delete_forever_outlined),
                              onPressed: () async {
                                final ok = await _confirm(
                                  context,
                                  title: s.deleteForever,
                                  message: s.deleteForeverConfirm,
                                  okLabel: s.deleteForever,
                                );
                                if (ok && context.mounted) {
                                  context
                                      .read<TodoBloc>()
                                      .add(DeleteTodo(id: item.id));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}