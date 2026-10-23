import 'package:auto_route/auto_route.dart';
import 'package:mobile_app_standard/feature/todo/pages/todo_page.dart';
import 'package:mobile_app_standard/feature/todo/pages/trash_page.dart';
import 'package:mobile_app_standard/feature/home/pages/home_page.dart';
import 'package:mobile_app_standard/feature/calendar/pages/calendar_page.dart';
import 'package:mobile_app_standard/feature/setting/pages/setting_page.dart';
import 'package:flutter/material.dart';
part 'router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        CustomRoute(
          page: HomeRoute.page,
          initial: true,
          transitionsBuilder: TransitionsBuilders.noTransition,
        ),
        CustomRoute(
          page: TodoRoute.page,
          transitionsBuilder: TransitionsBuilders.noTransition,
        ),
        CustomRoute(
          page: CalendarRoute.page,
          transitionsBuilder: TransitionsBuilders.noTransition,
        ),
        CustomRoute(
          page: SettingsRoute.page,
          transitionsBuilder: TransitionsBuilders.noTransition,
        ),
        AutoRoute(page: TrashRoute.page),
      ];
}