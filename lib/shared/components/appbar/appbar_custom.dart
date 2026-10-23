import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/feature/todo/bloc/todo_bloc.dart';
import 'package:mobile_app_standard/i18n/app_strings.dart';
import 'package:mobile_app_standard/shared/tokens/app_theme.dart';

class AppBarCustom extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  final String currentRouteName;
  final List<Widget>? actions;

  const AppBarCustom({super.key, required this.currentRouteName, this.actions});

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: context.textMain,
      fontWeight: FontWeight.bold,
    );

    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        backgroundColor: context.cardColor2.withValues(alpha: 0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x22000000), width: 0),
        ),
        middle: Text('Fakduai', style: titleStyle),
        trailing: Material(
          type: MaterialType.transparency,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...?actions,
              _NotificationButton(currentRouteName: currentRouteName),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.cardColor2,
        foregroundColor: context.textMain,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Fakduai', style: titleStyle),
        actions: [
          ...?actions,
          _NotificationButton(currentRouteName: currentRouteName),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;
}

class _NotificationButton extends StatelessWidget {
  final String currentRouteName;

  const _NotificationButton({required this.currentRouteName});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        var count = 0;

        if (state is TodoLoaded) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          count = state.todos.where((todo) {
            final dueDate = todo.dueDate;

            return todo.status != 2 &&
                dueDate != null &&
                !dueDate.isBefore(today);
          }).length;
        }

        return IconButton(
          tooltip: s.upcoming,
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text(
                  s.upcoming,
                  style: TextStyle(color: dialogContext.textMain),
                ),
                content: Text(
                  s.notifBody(count),
                  style: TextStyle(color: dialogContext.textSub),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(s.close),
                  ),
                ],
              ),
            );
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none, color: context.textMain),
              if (count > 0)
                Positioned(
                  right: -7,
                  top: -5,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}