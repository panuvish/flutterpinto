import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
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
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openTodo(BuildContext context, int? status) {
    context.router.push(
      TodoRoute(initialStatus: status),
    );
  }

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<TodoBloc>();
    bloc.add(LoadTodos());
    await bloc.stream
        .firstWhere((s) => s is TodoLoaded || s is TodoError)
        .timeout(const Duration(seconds: 5), onTimeout: () => bloc.state);
  }

  @override
  Widget build(BuildContext context) {
    final currentRouteName = context.routeData.name;
    final s = S.of(context);

    return Scaffold(
      appBar: AppBarCustom(currentRouteName: currentRouteName),
      bottomNavigationBar: BottomBarCustom(
        currentRouteName: currentRouteName,
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.loadFailed,
                      style: TextStyle(color: context.textMain),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.textSub),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        context.read<TodoBloc>().add(LoadTodos());
                      },
                      child: Text(s.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is! TodoLoaded) {
            return const SizedBox.shrink();
          }

          final dark = context.isDark;
          final todos = state.todos;
          final total = todos.length;
          final inProgress = todos.where((todo) => todo.status == 1).length;
          final completed = todos.where((todo) => todo.status == 2).length;
          final notStarted = todos.where((todo) => todo.status == 0).length;

          final progress = total == 0 ? 0.0 : completed / total;

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final overdue = todos.where((todo) {
            final dueDate = todo.dueDate;
            return todo.status != 2 &&
                dueDate != null &&
                dueDate.isBefore(today);
          }).length;

          final upcomingTodos = todos.where((todo) {
            final dueDate = todo.dueDate;
            return todo.status != 2 &&
                dueDate != null &&
                !dueDate.isBefore(today);
          }).toList()
            ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

          return SafeArea(
            top: false,
            child: RefreshIndicator(
              color: context.blue,
              onRefresh: () => _refresh(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: [
                  // Dashboard header
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: kBrandBlue,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: kBrandBlue.withValues(alpha: 0.20),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.dashboard_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.dashboard,
                              style: TextStyle(
                                color: context.textMain,
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              s.dashboardSub,
                              style: TextStyle(
                                color: context.textSub,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // งานทั้งหมด
                  _TotalCard(
                    count: total,
                    onTap: () => _openTodo(context, null),
                  ),

                  const SizedBox(height: 12),

                  // การ์ดสรุป
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardSize = (constraints.maxWidth - 12) / 2;

                      Widget square(Widget child) => SizedBox(
                            width: cardSize,
                            height: cardSize,
                            child: child,
                          );

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          square(
                            _SummaryCard(
                              title: s.statusInProgressLong,
                              count: inProgress,
                              icon: Icons.schedule,
                              background: dark
                                  ? const Color(0xFF0B3A47)
                                  : const Color.fromARGB(255, 217, 249, 255),
                              foreground: dark
                                  ? const Color(0xFF7FE3FF)
                                  : const Color.fromARGB(255, 0, 118, 154),
                              onTap: () => _openTodo(context, 1),
                            ),
                          ),
                          square(
                            _SummaryCard(
                              title: s.statusDone,
                              count: completed,
                              icon: Icons.check_circle_outline,
                              background: dark
                                  ? const Color(0xFF0F3D28)
                                  : const Color(0xFFDDF7E8),
                              foreground: dark
                                  ? const Color(0xFF6EE7A8)
                                  : const Color(0xFF137647),
                              onTap: () => _openTodo(context, 2),
                            ),
                          ),
                          square(
                            _SummaryCard(
                              title: s.statusNotStarted,
                              count: notStarted,
                              icon: Icons.error_outline,
                              background: dark
                                  ? const Color(0xFF4A3410)
                                  : const Color(0xFFFFF3D9),
                              foreground: dark
                                  ? const Color(0xFFFFC56B)
                                  : const Color(0xFF9A4B00),
                              onTap: () => _openTodo(context, 0),
                            ),
                          ),
                          square(
                            _SummaryCard(
                              title: s.statusOverdue,
                              count: overdue,
                              icon: Icons.warning_amber_rounded,
                              background: dark
                                  ? const Color(0xFF4A1A1A)
                                  : const Color.fromARGB(255, 255, 225, 225),
                              foreground: dark
                                  ? const Color(0xFFFF8A8A)
                                  : const Color.fromARGB(255, 255, 0, 0),
                              onTap: () => _openTodo(context, 3),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Progress card
                  Container(
                    padding: const EdgeInsets.all(17),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.progressTitle,
                                style: TextStyle(
                                  color: context.textMain,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: TextStyle(
                                color: context.blue,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 9,
                            backgroundColor: dark
                                ? const Color(0xFF333333)
                                : const Color(0xFFE8EDF2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF16A34A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          total == 0
                              ? s.noTasks
                              : s.doneOf(completed, total),
                          style: TextStyle(
                            color: context.textSub,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Statistics
                  Text(
                    s.statistics,
                    style: TextStyle(
                      color: context.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ChartCard(
                    title: s.chartStatusTitle,
                    child: _StatusPieChart(
                      notStarted: notStarted,
                      inProgress: inProgress,
                      completed: completed,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ChartCard(
                    title: s.chartWeeklyTitle,
                    child: _WeeklyDoneChart(todos: todos),
                  ),

                  const SizedBox(height: 22),

                  // Upcoming tasks header
                  Text(
                    s.upcoming,
                    style: TextStyle(
                      color: context.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (upcomingTodos.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                          Icon(
                            Icons.event_available,
                            color: context.textSub,
                            size: 32,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            s.noUpcoming,
                            style: TextStyle(
                              color: context.textSub,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...upcomingTodos.take(5).map(
                          (todo) => _UpcomingTodoCard(todo: todo),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String title;
  final int count;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: foreground, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(
                  color: foreground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingTodoCard extends StatelessWidget {
  const _UpcomingTodoCard({required this.todo});

  final TodoModel todo;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final dueDate = todo.dueDate;
    final formattedDate =
        dueDate == null ? '-' : DateFormat('dd/MM/yyyy').format(dueDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: context.cardColor2,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.iconChipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              todo.status == 1 ? Icons.timelapse : Icons.description_outlined,
              color: context.blue,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  s.dueOn(formattedDate),
                  style: TextStyle(
                    color: context.textSub,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final dark = context.isDark;
    final fg = dark ? const Color(0xFFECEFF1) : const Color(0xFF464646);

    return Material(
      color: dark ? const Color(0xFF2A2A2A) : const Color(0xFFDEDEDE),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 35),
          child: Row(
            children: [
              Icon(Icons.checklist, color: fg, size: 40),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  s.totalTasks,
                  style: TextStyle(
                    color: fg,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$count',
                style: TextStyle(
                  color: fg,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Charts
class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.textMain,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatusPieChart extends StatelessWidget {
  const _StatusPieChart({
    required this.notStarted,
    required this.inProgress,
    required this.completed,
  });

  final int notStarted;
  final int inProgress;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final total = notStarted + inProgress + completed;

    final items = [
      (
        label: s.statusNotStarted,
        count: notStarted,
        color: const Color(0xFFE53935),
      ),
      (
        label: s.statusDoing,
        count: inProgress,
        color: const Color(0xFFFF9800),
      ),
      (
        label: s.statusDone,
        count: completed,
        color: const Color(0xFF16A34A),
      ),
    ];

    if (total == 0) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(s.noChartData, style: TextStyle(color: context.textSub)),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 38,
                  sections: [
                    for (final i in items)
                      if (i.count > 0)
                        PieChartSectionData(
                          value: i.count.toDouble(),
                          color: i.color,
                          radius: 22,
                          showTitle: false,
                        ),
                  ],
                ),
              ),
              Text(
                '$total',
                style: TextStyle(
                  color: context.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              for (final i in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: i.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          i.label,
                          style:
                              TextStyle(color: context.textSub, fontSize: 13),
                        ),
                      ),
                      Text(
                        '${i.count} (${(i.count * 100 / total).round()}%)',
                        style: TextStyle(
                          color: context.textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyDoneChart extends StatelessWidget {
  const _WeeklyDoneChart({required this.todos});

  final List<TodoModel> todos;

  static const int _weeks = 6;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final now = DateTime.now();
    final thisMonday =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));

    final starts = List.generate(
      _weeks,
      (i) => DateTime(
        thisMonday.year,
        thisMonday.month,
        thisMonday.day - 7 * (_weeks - 1 - i),
      ),
    );
    final first = DateTime.utc(
      starts.first.year,
      starts.first.month,
      starts.first.day,
    );

    final counts = List.filled(_weeks, 0);
    for (final todo in todos) {
      final d = todo.completedAt;
      if (todo.status != 2 || d == null) continue;

      final days =
          DateTime.utc(d.year, d.month, d.day).difference(first).inDays;
      if (days < 0) continue;
      final idx = days ~/ 7;
      if (idx < _weeks) counts[idx]++;
    }

    final maxCount = counts.reduce(math.max);
    if (maxCount == 0) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(s.noChartData, style: TextStyle(color: context.textSub)),
        ),
      );
    }
    final maxY = (maxCount < 3 ? 3 : maxCount + 1).toDouble();

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= _weeks) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      DateFormat('dd/MM').format(starts[i]),
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            i == _weeks - 1 ? context.blue : context.textSub,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
              tooltipPadding: EdgeInsets.zero,
              tooltipMargin: 2,
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                '${rod.toY.round()}',
                TextStyle(
                  color: context.textMain,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < _weeks; i++)
              BarChartGroupData(
                x: i,
                showingTooltipIndicators: counts[i] > 0 ? [0] : [],
                barRods: [
                  BarChartRodData(
                    toY: counts[i].toDouble(),
                    width: 18,
                    color: i == _weeks - 1
                        ? context.blue
                        : context.blue.withValues(alpha: 0.45),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}