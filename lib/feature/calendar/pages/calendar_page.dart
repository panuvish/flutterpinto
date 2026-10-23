import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_standard/feature/todo/bloc/todo_bloc.dart';
import 'package:mobile_app_standard/feature/todo/model/todo_model.dart';
import 'package:mobile_app_standard/i18n/app_strings.dart';
import 'package:mobile_app_standard/router/router.dart';
import 'package:mobile_app_standard/shared/components/appbar/appbar_custom.dart';
import 'package:mobile_app_standard/shared/components/appbar/bottombar_custom.dart';
import 'package:mobile_app_standard/shared/tokens/app_theme.dart';

@RoutePage()
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const int maxDots = 3;

  DateTime displayedMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void changeMonth(int offset) {
    setState(() {
      displayedMonth = DateTime(
        displayedMonth.year,
        displayedMonth.month + offset,
        1,
      );
    });
  }

  void goToToday() {
    final now = DateTime.now();
    setState(() {
      displayedMonth = DateTime(now.year, now.month, 1);
      selectedDate = now;
    });
  }

  // ไปหน้า Todo
  void openTodo(BuildContext context, TodoModel todo) {
    context.router.push(TodoRoute(highlightTodoId: todo.id));
  }

  @override
  Widget build(BuildContext context) {
    final routeName = context.routeData.name;
    final s = S.of(context);

    return Scaffold(
      appBar: AppBarCustom(currentRouteName: routeName),
      bottomNavigationBar: BottomBarCustom(
        currentRouteName: routeName,
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state is TodoLoading || state is TodoInitial) {
            return Center(
              child: CircularProgressIndicator(color: context.blue),
            );
          }

          if (state is TodoError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (state is! TodoLoaded) {
            return const SizedBox.shrink();
          }

          final todos = state.todos;

          final selectedTodos = todos.where((todo) {
            final dueDate = todo.dueDate;
            return dueDate != null && isSameDay(dueDate, selectedDate);
          }).toList()
            ..sort((a, b) {
              final dateA = a.dueDate!;
              final dateB = b.dueDate!;
              return dateA.compareTo(dateB);
            });

          final firstWeekday =
              DateTime(displayedMonth.year, displayedMonth.month, 1).weekday;
          final daysInMonth = DateUtils.getDaysInMonth(
            displayedMonth.year,
            displayedMonth.month,
          );

          final leadingEmptyDays = firstWeekday % 7;
          final totalCells = ((leadingEmptyDays + daysInMonth + 6) ~/ 7) * 7;

          final now = DateTime.now();
          final isViewingToday =
              isSameDay(selectedDate, now) &&
              displayedMonth.year == now.year &&
              displayedMonth.month == now.month;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: kBrandBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.navCalendar,
                          style: TextStyle(
                            color: context.textMain,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          s.calendarSub,
                          style: TextStyle(
                            color: context.textSub,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  TextButton.icon(
                    onPressed: isViewingToday ? null : goToToday,
                    icon: const Icon(Icons.today, size: 18),
                    label: Text(s.today),
                    style: TextButton.styleFrom(
                      foregroundColor: context.blue,
                      backgroundColor: isViewingToday
                          ? Colors.transparent
                          : context.iconChipBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Monthly calendar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.cardColor2,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: context.shadowColor2,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => changeMonth(-1),
                          icon: const Icon(Icons.chevron_left),
                          color: context.blue,
                        ),
                        Expanded(
                          child: Text(
                            DateFormat(
                              'MMMM yyyy',
                              s.code,
                            ).format(displayedMonth),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: context.textMain,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => changeMonth(1),
                          icon: const Icon(Icons.chevron_right),
                          color: context.blue,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: s.weekdays
                          .map(
                            (day) => Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    color: context.textSub,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 10),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalCells,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 2,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final day = index - leadingEmptyDays + 1;

                        if (day < 1 || day > daysInMonth) {
                          return const SizedBox.shrink();
                        }

                        final date = DateTime(
                          displayedMonth.year,
                          displayedMonth.month,
                          day,
                        );

                        final dayTodos = todos.where((todo) {
                          final dueDate = todo.dueDate;
                          return dueDate != null && isSameDay(dueDate, date);
                        }).toList();

                        final extraCount = dayTodos.length - maxDots;

                        final isSelected = isSameDay(date, selectedDate);
                        final isToday = isSameDay(date, DateTime.now());

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? kBrandBlue
                                  : isToday
                                      ? context.iconChipBg
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$day',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : context.textMain,
                                    fontSize: 13,
                                    fontWeight: isSelected || isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (dayTodos.isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ...dayTodos.take(maxDots).map((todo) {
                                        final color = todo.status == 2
                                            ? const Color(0xFF16A34A)
                                            : todo.status == 1
                                                ? const Color(0xFFFF9800)
                                                : const Color(0xFFE53935);

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 1,
                                          ),
                                          child: Container(
                                            width: 4,
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.white
                                                  : color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        );
                                      }),
                                      // แสดงจำนวนงานที่เกิน
                                      if (extraCount > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 2,
                                          ),
                                          child: Text(
                                            '+$extraCount',
                                            style: TextStyle(
                                              fontSize: 9,
                                              height: 1,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : context.textSub,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _Legend(
                          color: const Color(0xFFE53935),
                          label: s.statusNotStarted,
                        ),
                        _Legend(
                          color: const Color(0xFFFF9800),
                          label: s.statusDoing,
                        ),
                        _Legend(
                          color: const Color(0xFF16A34A),
                          label: s.statusDone,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                s.tasksOn(DateFormat('dd/MM/yyyy').format(selectedDate)),
                style: TextStyle(
                  color: context.textMain,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (selectedTodos.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: context.cardColor2,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: context.shadowColor2,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available,
                        color: context.textSub,
                        size: 34,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.noTasksSelected,
                        style: TextStyle(color: context.textSub),
                      ),
                    ],
                  ),
                )
              else
                ...selectedTodos.map(
                  (todo) => _CalendarTodoCard(
                    todo: todo,
                    onTap: () => openTodo(context, todo),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: context.textSub,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _CalendarTodoCard extends StatelessWidget {
  final TodoModel todo;
  final VoidCallback onTap;

  const _CalendarTodoCard({
    required this.todo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final dark = context.isDark;

    final statusText = todo.status == 2
        ? s.statusDone
        : todo.status == 1
            ? s.statusDoing
            : s.statusNotStarted;

    final statusColor = todo.status == 2
        ? (dark ? const Color(0xFF4ADE80) : const Color(0xFF137647))
        : todo.status == 1
            ? (dark ? const Color(0xFFFFB74D) : const Color(0xFF9A4B00))
            : (dark ? const Color(0xFFFF6B8A) : const Color(0xFFB42348));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: TextStyle(
                          color: context.textMain,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        todo.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.textSub,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}