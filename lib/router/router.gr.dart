// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [CalendarPage]
class CalendarRoute extends PageRouteInfo<void> {
  const CalendarRoute({List<PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CalendarPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [TodoPage]
class TodoRoute extends PageRouteInfo<TodoRouteArgs> {
  TodoRoute({
    Key? key,
    int? initialStatus,
    int? highlightTodoId,
    List<PageRouteInfo>? children,
  }) : super(
         TodoRoute.name,
         args: TodoRouteArgs(
           key: key,
           initialStatus: initialStatus,
           highlightTodoId: highlightTodoId,
         ),
         initialChildren: children,
       );

  static const String name = 'TodoRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TodoRouteArgs>(
        orElse: () => const TodoRouteArgs(),
      );
      return TodoPage(
        key: args.key,
        initialStatus: args.initialStatus,
        highlightTodoId: args.highlightTodoId,
      );
    },
  );
}

class TodoRouteArgs {
  const TodoRouteArgs({this.key, this.initialStatus, this.highlightTodoId});

  final Key? key;

  final int? initialStatus;

  final int? highlightTodoId;

  @override
  String toString() {
    return 'TodoRouteArgs{key: $key, initialStatus: $initialStatus, highlightTodoId: $highlightTodoId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TodoRouteArgs) return false;
    return key == other.key &&
        initialStatus == other.initialStatus &&
        highlightTodoId == other.highlightTodoId;
  }

  @override
  int get hashCode =>
      key.hashCode ^ initialStatus.hashCode ^ highlightTodoId.hashCode;
}

/// generated route for
/// [TrashPage]
class TrashRoute extends PageRouteInfo<void> {
  const TrashRoute({List<PageRouteInfo>? children})
    : super(TrashRoute.name, initialChildren: children);

  static const String name = 'TrashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TrashPage();
    },
  );
}
