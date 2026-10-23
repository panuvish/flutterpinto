import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_standard/domain/http_client/ip.dart';
import 'package:mobile_app_standard/i18n/app_strings.dart';
import 'package:mobile_app_standard/locator.dart';
import 'package:mobile_app_standard/router/router.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_bloc.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_event.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_state.dart';
import 'package:mobile_app_standard/shared/bloc/theme/theme_cubit.dart';
import 'package:mobile_app_standard/shared/components/appbar/appbar_custom.dart';
import 'package:mobile_app_standard/shared/components/appbar/bottombar_custom.dart';
import 'package:mobile_app_standard/shared/tokens/app_theme.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _showIpDialog(BuildContext context) async {
    final s = S.of(context);

    if (Platform.isIOS) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('IP Address'),
          content: FutureBuilder<String?>(
            future: locator<IpClient>().getIp(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CupertinoActivityIndicator(),
                );
              }

              if (snapshot.hasError || snapshot.data == null) {
                return Text(s.ipFailed);
              }

              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SelectableText(snapshot.data!),
              );
            },
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(s.close),
            ),
          ],
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'IP Address',
            style: TextStyle(color: dialogContext.textMain),
          ),
          content: FutureBuilder<String?>(
            future: locator<IpClient>().getIp(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(color: context.blue),
                  ),
                );
              }

              if (snapshot.hasError || snapshot.data == null) {
                return Text(s.ipFailed);
              }

              return SelectableText(
                snapshot.data!,
                style: TextStyle(
                  color: context.textMain,
                  fontSize: 18,
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(s.close),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    Locale current,
  ) async {
    final bloc = context.read<LanguageBloc>();
    final s = S.of(context);
    final languages = [
      (const Locale('th'), 'ไทย'),
      (const Locale('en'), 'English'),
    ];

    if (Platform.isIOS) {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (popupContext) => CupertinoActionSheet(
          title: Text(s.chooseLanguage),
          actions: [
            for (final (locale, label) in languages)
              CupertinoActionSheetAction(
                isDefaultAction: locale.languageCode == current.languageCode,
                onPressed: () {
                  bloc.add(ChangeLanguageEvent(locale));
                  Navigator.of(popupContext).pop();
                },
                child: Text(label),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(),
            child: Text(s.close),
          ),
        ),
      );
    } else {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            s.chooseLanguage,
            style: TextStyle(color: dialogContext.textMain),
          ),
          children: [
            for (final (locale, label) in languages)
              ListTile(
                title: Text(label),
                trailing: locale.languageCode == current.languageCode
                    ? Icon(Icons.check, color: dialogContext.blue)
                    : null,
                onTap: () {
                  bloc.add(ChangeLanguageEvent(locale));
                  Navigator.of(dialogContext).pop();
                },
              ),
          ],
        ),
      );
    }
  }

  Future<void> _showThemeDialog(BuildContext context, ThemeMode current) async {
    final cubit = context.read<ThemeCubit>();
    final s = S.of(context);
    final options = [
      (ThemeMode.system, s.themeSystem, Icons.settings_suggest_outlined),
      (ThemeMode.light, s.themeLight, Icons.light_mode_outlined),
      (ThemeMode.dark, s.themeDark, Icons.dark_mode_outlined),
    ];

    if (Platform.isIOS) {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (popupContext) => CupertinoActionSheet(
          title: Text(s.chooseTheme),
          actions: [
            for (final (mode, label, _) in options)
              CupertinoActionSheetAction(
                isDefaultAction: mode == current,
                onPressed: () {
                  cubit.setMode(mode);
                  Navigator.of(popupContext).pop();
                },
                child: Text(label),
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(popupContext).pop(),
            child: Text(s.close),
          ),
        ),
      );
    } else {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (mode, label, icon) in options)
                ListTile(
                  leading: Icon(icon),
                  title: Text(label),
                  trailing: mode == current
                      ? Icon(Icons.check, color: sheetContext.blue)
                      : null,
                  onTap: () {
                    cubit.setMode(mode);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      );
    }
  }

  String _themeLabel(S s, ThemeMode mode) => switch (mode) {
        ThemeMode.light => s.themeLight,
        ThemeMode.dark => s.themeDark,
        ThemeMode.system => s.themeSystem,
      };

  @override
  Widget build(BuildContext context) {
    final routeName = context.routeData.name;
    final s = S.of(context);

    return Scaffold(
      appBar: AppBarCustom(currentRouteName: routeName),
      bottomNavigationBar: BottomBarCustom(currentRouteName: routeName),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
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
                    Icons.settings,
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
                        s.navSettings,
                        style: TextStyle(
                          color: context.textMain,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        s.settingsSub,
                        style: TextStyle(color: context.textSub, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                s.general,
                style: TextStyle(
                  color: context.textSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            _SettingsGroup(
              children: [
                BlocBuilder<LanguageBloc, LanguageState>(
                  builder: (context, state) {
                    return _SettingsTile(
                      icon: Icons.language,
                      title: s.language,
                      subtitle: state.locale.languageCode == 'en'
                          ? 'English'
                          : 'ไทย',
                      onTap: () => _showLanguageDialog(context, state.locale),
                    );
                  },
                ),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, mode) {
                    return _SettingsTile(
                      icon: Icons.brightness_6_outlined,
                      title: s.theme,
                      subtitle: _themeLabel(s, mode),
                      onTap: () => _showThemeDialog(context, mode),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                s.tools,
                style: TextStyle(
                  color: context.textSub,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            _SettingsGroup(
              children: [
                _SettingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: s.trash,
                  subtitle: s.trashSub,
                  onTap: () => context.router.push(const TrashRoute()),
                ),
                _SettingsTile(
                  icon: Icons.wifi,
                  title: s.checkIp,
                  subtitle: s.checkIpSub,
                  onTap: () => _showIpDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: context.iconChipBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: context.blue, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: context.textMain,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(
                color: context.textSub,
                fontSize: 12,
              ),
            ),
      trailing: Icon(
        Icons.chevron_right,
        color: context.textSub,
      ),
    );
  }
}