import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_standard/feature/todo/bloc/todo_bloc.dart';
import 'package:mobile_app_standard/feature/todo/model/todo_model.dart';
import 'package:mobile_app_standard/feature/todo/model/todo_priority.dart';
import 'package:mobile_app_standard/feature/todo/widgets/dialog/add_todo_dialog.dart';
import 'package:mobile_app_standard/feature/todo/widgets/dialog/edit_todo_diallog.dart';
import 'package:mobile_app_standard/i18n/app_strings.dart';
import 'package:mobile_app_standard/shared/components/appbar/appbar_custom.dart';
import 'package:mobile_app_standard/shared/components/appbar/bottombar_custom.dart';
import 'package:mobile_app_standard/shared/tokens/app_theme.dart';
import 'package:mobile_app_standard/shared/tokens/p_colors.dart';
import 'package:mobile_app_standard/shared/tokens/p_size.dart';
import 'package:mobile_app_standard/shared/tokens/p_spacing.dart';

@RoutePage()
class TodoPage extends HookWidget {
  const TodoPage({
    super.key,
    this.initialStatus,
    this.highlightTodoId,
  });

  final int? initialStatus;
  final int? highlightTodoId;

  @override
  Widget build(BuildContext context) {
    final currentRouteName = context.routeData.name;
    final s = S.of(context);

    final displayedItems = useState(8);
    final selectedStatus = useState<int?>(initialStatus);
    final selectedPriority = useState<TodoPriority?>(null);
    final highlightedId = useState<int?>(highlightTodoId);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final sortMode = useState(0); // 0 = ค่าเริ่มต้น, 1 = priority, 2 = วันครบกำหนด
    final hiddenIds = useState<Set<int>>({});

    String statusLabel(int status) {
      switch (status) {
        case 1:
          return s.statusDoing;
        case 2:
          return s.statusDone;
        default:
          return s.statusNotStarted;
      }
    }

    Color statusColor(int status) {
      switch (status) {
        case 1:
          return Colors.orange;
        case 2:
          return Colors.green;
        default:
          return Colors.blueGrey;
      }
    }

    String dueText(TodoModel item) {
      final due = item.dueDate;
      if (due == null) return s.noDueDate;
      return s.dueDateLabel(DateFormat('dd/MM/yyyy').format(due));
    }

    // งานเลยกำหนด
    bool isOverdue(TodoModel item) {
      final due = item.dueDate;
      if (item.status == 2 || due == null) return false;
      final now = DateTime.now();
      return due.isBefore(DateTime(now.year, now.month, now.day));
    }

    void deleteWithUndo(TodoModel item) {
      final bloc = context.read<TodoBloc>();
      final messenger = ScaffoldMessenger.of(context);

      hiddenIds.value = {...hiddenIds.value, item.id};
      bloc.add(SoftDeleteTodo(id: item.id));

      bloc.stream
          .firstWhere(
            (st) => st is TodoLoaded && st.todos.every((t) => t.id != item.id),
          )
          .timeout(const Duration(seconds: 3))
          .then((_) {
        if (context.mounted) {
          hiddenIds.value = {...hiddenIds.value}..remove(item.id);
        }
      }).catchError((_) {});

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(s.movedToTrashMsg(item.title)),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: s.undo,
              onPressed: () {
                if (context.mounted) {
                  hiddenIds.value = {...hiddenIds.value}..remove(item.id);
                }
                bloc.add(RestoreTodo(id: item.id));
              },
            ),
          ),
        );
    }

    // ปัดขวา: เสร็จงาน
    void toggleDone(TodoModel item) {
      final bloc = context.read<TodoBloc>();
      final messenger = ScaffoldMessenger.of(context);
      final previous = item.status;
      final next = previous == 2 ? 0 : 2;

      HapticFeedback.lightImpact();
      bloc.add(UpdateTodoStatus(id: item.id, status: next));

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              next == 2
                  ? s.completedMsg(item.title)
                  : s.reopenedMsg(item.title),
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: s.undo,
              onPressed: () =>
                  bloc.add(UpdateTodoStatus(id: item.id, status: previous)),
            ),
          ),
        );
    }

    Widget withSwipe(TodoModel item, Widget child, {double radius = 16}) {
      Widget bg(Alignment a, Color c, IconData icon) => Container(
            alignment: a,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Icon(icon, color: Colors.white),
          );

      return Dismissible(
        key: ValueKey(item.id),
        background: bg(
          Alignment.centerLeft,
          const Color(0xFF16A34A),
          item.status == 2 ? Icons.undo_rounded : Icons.check_circle_outline,
        ),
        secondaryBackground: bg(
          Alignment.centerRight,
          PColor.errorColor,
          Icons.delete_outline_rounded,
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            toggleDone(item);
            return false;
          }
          return true;
        },
        onDismissed: (_) => deleteWithUndo(item),
        child: child,
      );
    }

    // เพิ่มงาน
    void showAddTodoDialog() {
      if (Platform.isIOS) {
        showCupertinoDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (_) => BlocProvider.value(
            value: context.read<TodoBloc>(),
            child: AddTodoDialog(),
          ),
        );
      } else {
        showDialog<void>(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<TodoBloc>(),
            child: AddTodoDialog(),
          ),
        );
      }
    }

    // แก้ไขรายละเอียด
    void showEditTodoDialog(TodoModel item) {
      if (Platform.isIOS) {
        showCupertinoDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => BlocProvider.value(
            value: context.read<TodoBloc>(),
            child: EditTodoDialog(todo: item),
          ),
        );
      } else {
        showDialog<void>(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<TodoBloc>(),
            child: EditTodoDialog(todo: item),
          ),
        );
      }
    }

    // ยืนยันก่อนย้ายไปถังขยะ
    Future<void> confirmDeleteTodo(TodoModel item) async {
      final bool? shouldDelete;

      if (Platform.isIOS) {
        shouldDelete = await showCupertinoDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return CupertinoAlertDialog(
              title: Text(s.deleteTitle),
              content: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(s.deleteConfirmMsg(item.title)),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: Text(s.cancel),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text(s.deleteConfirmBtn),
                ),
              ],
            );
          },
        );
      } else {
        shouldDelete = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
                size: 36,
              ),
              title: Text(s.deleteTitle),
              content: Text(s.deleteConfirmMsg(item.title)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: Text(s.cancel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text(s.deleteConfirmBtn),
                ),
              ],
            );
          },
        );
      }

      if (!context.mounted || shouldDelete != true) {
        return;
      }

      // ย้ายไปถังขยะ
      context.read<TodoBloc>().add(SoftDeleteTodo(id: item.id));
    }

    // เลือกวันครบกำหนด
    Future<void> selectDueDate(TodoModel item) async {
      final now = DateTime.now();
      final existingDate = item.dueDate;

      final initialDate = existingDate == null
          ? now
          : DateTime(existingDate.year, existingDate.month, existingDate.day);

      final selectedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        helpText: s.pickDueDate,
        cancelText: s.cancel,
        confirmText: s.confirm,
      );

      if (!context.mounted || selectedDate == null) return;

      context.read<TodoBloc>().add(
            UpdateTodoDueDate(id: item.id, dueDate: selectedDate),
          );
    }

    void changePriority(TodoModel item, int priority) {
      context.read<TodoBloc>().add(
            UpdatePriorityTodo(id: item.id, priority: priority),
          );
    }

    // priority
    Widget buildPriorityChip(TodoModel item) {
      final p = TodoPriority.fromInt(item.priority);

      return PopupMenuButton<TodoPriority>(
        tooltip: s.priority,
        initialValue: p,
        onSelected: (v) => changePriority(item, v.value),
        itemBuilder: (_) => [
          for (final v in TodoPriority.values.reversed)
            PopupMenuItem(
              value: v,
              child: Row(
                children: [
                  Icon(Icons.circle, size: 12, color: v.color),
                  const SizedBox(width: 8),
                  Text(v.label(s)),
                ],
              ),
            ),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: p.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flag_rounded, size: 14, color: p.color),
              const SizedBox(width: 4),
              Text(
                p.label(s),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: p.color,
                ),
              ),
              Icon(Icons.arrow_drop_down, size: 16, color: p.color),
            ],
          ),
        ),
      );
    }

    // ปุ่มเพิ่มงานบน iOS
    final appBarActions = Platform.isIOS
        ? [
            IconButton(
              icon: Icon(CupertinoIcons.add, color: context.blue),
              onPressed: showAddTodoDialog,
            ),
          ]
        : null;

    // ช่องค้นหา
    Widget buildSearchBar() {
      void onSearchChanged(String value) {
        searchQuery.value = value.trim();
        displayedItems.value = 8;
        highlightedId.value = null;
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          PSpacing.lg,
          PSpacing.sm,
          PSpacing.sm,
          0,
        ),
        child: Row(
          children: [
            Expanded(
              child: Platform.isIOS
                  ? CupertinoSearchTextField(
                      controller: searchController,
                      placeholder: s.search,
                      onChanged: onSearchChanged,
                    )
                  : TextField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      decoration: InputDecoration(
                        hintText: s.search,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchQuery.value.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  searchController.clear();
                                  onSearchChanged('');
                                },
                              ),
                        filled: true,
                        fillColor: context.cardColor2,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
            ),
            PopupMenuButton<int>(
              tooltip: s.sort,
              initialValue: sortMode.value,
              icon: Icon(
                Icons.sort_rounded,
                color: sortMode.value == 0 ? context.textSub : context.blue,
              ),
              onSelected: (value) {
                sortMode.value = value;
                highlightedId.value = null;
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 0, child: Text(s.sortDefault)),
                PopupMenuItem(value: 1, child: Text(s.sortPriority)),
                PopupMenuItem(value: 2, child: Text(s.sortDue)),
              ],
            ),
          ],
        ),
      );
    }

    // ตัวกรองสถานะ
    Widget buildStatusFilterBar() {
      final filters = <({String label, int? value})>[
        (label: s.all, value: null),
        (label: s.statusNotStarted, value: 0),
        (label: s.statusDoing, value: 1),
        (label: s.statusDone, value: 2),
        (label: s.statusOverdue, value: 3),
      ];
      final priorityFilters = <TodoPriority?>[
        null,
        ...TodoPriority.values.reversed,
      ];

      return Column(
        children: [
          buildSearchBar(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PSpacing.lg,
              vertical: PSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final filter in filters) ...[
                    ChoiceChip(
                      label: Text(filter.label),
                      selected: selectedStatus.value == filter.value,
                      onSelected: (_) {
                        selectedStatus.value = filter.value;
                        displayedItems.value = 8;
                        highlightedId.value = null;
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PSpacing.lg,
              0,
              PSpacing.lg,
              PSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final p in priorityFilters) ...[
                    ChoiceChip(
                      avatar: p == null
                          ? null
                          : Icon(Icons.flag_rounded, size: 16, color: p.color),
                      label: Text(p == null ? s.allPriorities : p.label(s)),
                      selected: selectedPriority.value == p,
                      onSelected: (_) {
                        selectedPriority.value = p;
                        displayedItems.value = 8;
                        highlightedId.value = null;
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    }

    // iOS item
    Widget buildCupertinoTile(TodoModel item) {
      return withSwipe(
        item,
        radius: 0,
        CupertinoListTile(
          backgroundColor: item.id == highlightedId.value
              ? context.blue.withValues(alpha: 0.10)
              : null,
          leading: Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: TodoPriority.fromInt(item.priority).color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          title: Text(item.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.content),
              const SizedBox(height: 8),
              Text(
                s.statusLabel(statusLabel(item.status)),
                style: TextStyle(
                  color: statusColor(item.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(dueText(item)),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: buildPriorityChip(item),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                onPressed: () => selectDueDate(item),
                child: Text(s.pickDueDate),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                onPressed: () {
                  final nextStatus = (item.status + 1) % 3;

                  context.read<TodoBloc>().add(
                        UpdateTodoStatus(id: item.id, status: nextStatus),
                      );
                },
                child: Text(s.changeStatus),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // แก้ไขงาน
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => showEditTodoDialog(item),
                child: Icon(CupertinoIcons.pencil, color: context.blue),
              ),

              // ลบงานพร้อมยืนยัน
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => confirmDeleteTodo(item),
                child: Icon(
                  CupertinoIcons.delete,
                  color: PColor.errorColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Android
    Widget buildMaterialItem(TodoModel item) {
      final isHighlighted = item.id == highlightedId.value;
      final priorityColor = TodoPriority.fromInt(item.priority).color;

      return withSwipe(
        item,
        Container(
          decoration: BoxDecoration(
            color: context.cardColor2,
            borderRadius: BorderRadius.circular(16),
            border: isHighlighted
                ? Border.all(color: context.blue, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: context.shadowColor2,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(PSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 48,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: PSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: PText.textBase,
                                fontWeight: FontWeight.bold,
                                color: context.textMain,
                              ),
                            ),
                            const SizedBox(height: PSpacing.xs),
                            Text(
                              item.content,
                              style: TextStyle(
                                fontSize: PText.textSm,
                                color: context.textSub,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // สถานะงาน
                  Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 18,
                        color: context.textSub,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        s.statusColon,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textMain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<int>(
                          value: item.status >= 0 && item.status <= 2
                              ? item.status
                              : 0,
                          isExpanded: true,
                          isDense: true,
                          underline: const SizedBox.shrink(),
                          style: TextStyle(
                            fontSize: 13,
                            color: statusColor(item.status),
                            fontWeight: FontWeight.w600,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text(s.statusNotStarted),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text(s.statusDoing),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text(s.statusDone),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            context.read<TodoBloc>().add(
                                  UpdateTodoStatus(
                                    id: item.id,
                                    status: value,
                                  ),
                                );
                          },
                        ),
                      ),
                    ],
                  ),

                  // วันครบกำหนด
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => selectDueDate(item),
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                      ),
                      label: Text(
                        item.dueDate == null ? s.setDueDate : dueText(item),
                      ),
                    ),
                  ),

                  // Priority
                  Row(
                    children: [
                      buildPriorityChip(item),
                      const Spacer(),

                      // แก้ไขงาน
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        iconSize: 20,
                        color: context.blue,
                        tooltip: s.editTodo,
                        onPressed: () => showEditTodoDialog(item),
                      ),

                      // ย้ายไปถังขยะพร้อมยืนยัน
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        iconSize: 20,
                        color: PColor.errorColor,
                        tooltip: s.delete,
                        onPressed: () => confirmDeleteTodo(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final bodyContent = Container(
      color: context.bg,
      child: Column(
        children: [
          if (!Platform.isIOS)
            Padding(
              padding: const EdgeInsets.all(PSpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(PSpacing.xs),
                    decoration: BoxDecoration(
                      color: context.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.list_alt_rounded,
                      color: context.blue,
                    ),
                  ),
                  const SizedBox(width: PSpacing.md),
                  Text(
                    s.todoTitle,
                    style: TextStyle(
                      fontSize: PText.text2xl,
                      fontWeight: FontWeight.bold,
                      color: context.textMain,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (todoContext, state) {
                if (state is TodoLoading || state is TodoInitial) {
                  return Center(
                    child: Platform.isIOS
                        ? const CupertinoActivityIndicator()
                        : const CircularProgressIndicator(),
                  );
                }

                if (state is TodoError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(PSpacing.lg),
                      child: Text(
                        s.errorMsg(state.message),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.textMain),
                      ),
                    ),
                  );
                }

                final List<TodoModel> items = [];

                if (state is TodoLoaded) {
                  items.addAll(state.todos);
                }

                final query = searchQuery.value.toLowerCase();

                final filteredItems = items.where((item) {
                  if (hiddenIds.value.contains(item.id)) return false;

                  final status = selectedStatus.value;
                  if (status == 3) {
                    if (!isOverdue(item)) return false;
                  } else if (status != null && item.status != status) {
                    return false;
                  }

                  final pf = selectedPriority.value;
                  if (pf != null &&
                      TodoPriority.fromInt(item.priority) != pf) {
                    return false;
                  }

                  if (query.isEmpty) return true;
                  return item.title.toLowerCase().contains(query) ||
                      item.content.toLowerCase().contains(query);
                }).toList();

                if (sortMode.value == 1) {
                  filteredItems.sort(
                    (a, b) => TodoPriority.fromInt(b.priority).value.compareTo(
                          TodoPriority.fromInt(a.priority).value,
                        ),
                  );
                } else if (sortMode.value == 2) {
                  filteredItems.sort((a, b) {
                    final dateA = a.dueDate;
                    final dateB = b.dueDate;
                    if (dateA == null && dateB == null) return 0;
                    if (dateA == null) return 1;
                    if (dateB == null) return -1;
                    return dateA.compareTo(dateB);
                  });
                }

                if (highlightedId.value != null) {
                  final index = filteredItems.indexWhere(
                    (item) => item.id == highlightedId.value,
                  );
                  if (index > 0) {
                    filteredItems.insert(0, filteredItems.removeAt(index));
                  }
                }

                final limitedItems =
                    filteredItems.take(displayedItems.value).toList();

                final emptyText = Center(
                  child: Text(
                    items.isEmpty ? s.noTodo : s.noMatch,
                    style: TextStyle(
                      fontSize: PText.textBase,
                      color: context.textSub,
                    ),
                  ),
                );

                // iOS UI
                if (Platform.isIOS) {
                  return Column(
                    children: [
                      buildStatusFilterBar(),
                      Expanded(
                        child: filteredItems.isEmpty
                            ? emptyText
                            : ListView(
                                children: [
                                  CupertinoListSection.insetGrouped(
                                    backgroundColor: Colors.transparent,
                                    header: Text(s.todoTitle),
                                    children: [
                                      ...limitedItems.map(buildCupertinoTile),
                                    ],
                                  ),
                                  if (filteredItems.length >
                                      displayedItems.value)
                                    const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Center(
                                        child: CupertinoActivityIndicator(),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    ],
                  );
                }

                // Android UI
                return Column(
                  children: [
                    buildStatusFilterBar(),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? emptyText
                          : NotificationListener<ScrollNotification>(
                              onNotification: (scrollInfo) {
                                if (scrollInfo.metrics.pixels >=
                                        scrollInfo.metrics.maxScrollExtent -
                                            200 &&
                                    filteredItems.length >
                                        displayedItems.value) {
                                  displayedItems.value += 3;
                                }

                                return false;
                              },
                              child: ListView.separated(
                                itemCount: limitedItems.length,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PSpacing.lg,
                                  vertical: PSpacing.lg,
                                ),
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: PSpacing.md),
                                itemBuilder: (_, index) =>
                                    buildMaterialItem(limitedItems[index]),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );

    // iOS Scaffold
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: AppBarCustom(
          currentRouteName: currentRouteName,
          actions: appBarActions,
        ) as ObstructingPreferredSizeWidget,
        child: SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                Expanded(child: bodyContent),
                BottomBarCustom(currentRouteName: currentRouteName),
              ],
            ),
          ),
        ),
      );
    }

    // Android Scaffold
    return Scaffold(
      appBar: AppBarCustom(currentRouteName: currentRouteName),
      bottomNavigationBar: BottomBarCustom(currentRouteName: currentRouteName),
      body: bodyContent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kBrandBlue,
        foregroundColor: Colors.white,
        onPressed: showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}