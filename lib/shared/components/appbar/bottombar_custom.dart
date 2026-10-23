import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_app_standard/i18n/app_strings.dart';
import 'package:mobile_app_standard/router/router.dart';
import 'package:mobile_app_standard/shared/tokens/app_theme.dart';

class BottomBarCustom extends HookWidget {
  final String currentRouteName;

  const BottomBarCustom({
    super.key,
    required this.currentRouteName,
  });

  int _getIndexFromRoute(String routeName) {
    if (routeName == HomeRoute.name) return 0;
    if (routeName == TodoRoute.name) return 1;
    if (routeName == CalendarRoute.name) return 2;
    if (routeName == SettingsRoute.name) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(
      _getIndexFromRoute(currentRouteName),
    );

    useEffect(() {
      selectedIndex.value = _getIndexFromRoute(currentRouteName);
      return null;
    }, [currentRouteName]);

    void onItemTapped(int index) {
      if (index == selectedIndex.value) return;

      switch (index) {
        case 0:
          context.router.push(const HomeRoute());
          break;
        case 1:
          context.router.push(TodoRoute());
          break;
        case 2:
          context.router.push(const CalendarRoute());
          break;
        case 3:
          context.router.push(const SettingsRoute());
          break;
      }

      selectedIndex.value = index;
    }

    final s = S.of(context);

    if (Platform.isIOS) {
      return CupertinoTabBar(
        currentIndex: selectedIndex.value,
        onTap: onItemTapped,
        backgroundColor: context.cardColor2.withValues(alpha: 0.9),
        activeColor: context.blue,
        inactiveColor: context.textSub,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.home),
            label: s.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.list_bullet),
            label: s.navTodo,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.calendar),
            label: s.navCalendar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.settings),
            label: s.navSettings,
          ),
        ],
      );
    }

    return BottomNavigationBar(
      currentIndex: selectedIndex.value,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: context.cardColor2,
      selectedItemColor: context.blue,
      unselectedItemColor: context.textSub,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: s.navHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.list_alt_outlined),
          activeIcon: const Icon(Icons.list_alt),
          label: s.navTodo,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_month_outlined),
          activeIcon: const Icon(Icons.calendar_month),
          label: s.navCalendar,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: s.navSettings,
        ),
      ],
    );
  }
}