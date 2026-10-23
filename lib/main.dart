import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_app_standard/config/config.dart';
import 'package:mobile_app_standard/feature/home/bloc/websocket/websocket_bloc.dart';
import 'package:mobile_app_standard/feature/todo/bloc/todo_bloc.dart';
import 'package:mobile_app_standard/i18n/i18n.dart';
import 'package:mobile_app_standard/locator.dart';
import 'package:mobile_app_standard/router/router.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_bloc.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_state.dart';
import 'package:mobile_app_standard/shared/bloc/theme/theme_cubit.dart';
import 'package:mobile_app_standard/shared/tokens/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await loadEnv();
  await initLocator();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TodoBloc>(create: (context) => locator<TodoBloc>()),
        BlocProvider<WebsocketBloc>(
          create: (context) => locator<WebsocketBloc>(),
        ),
        BlocProvider<LanguageBloc>(
          create: (context) => locator<LanguageBloc>(),
        ),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        // add more providers
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, languageState) {
            if (!kIsWeb && Platform.isIOS) {
              return CupertinoApp.router(
                title: 'Flutter Demo',
                supportedLocales: I18n.all,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                locale: languageState.locale,
                theme: CupertinoThemeData(
                  primaryColor: kBrandBlue,
                  // null = ตามระบบ
                  brightness: switch (themeMode) {
                    ThemeMode.light => Brightness.light,
                    ThemeMode.dark => Brightness.dark,
                    ThemeMode.system => null,
                  },
                ),
                // ให้ widget แบบ Material ในทุกหน้าได้ Theme ที่ตรงกับโหมด
                builder: (context, child) {
                  final brightness = switch (themeMode) {
                    ThemeMode.light => Brightness.light,
                    ThemeMode.dark => Brightness.dark,
                    ThemeMode.system =>
                      MediaQuery.platformBrightnessOf(context),
                  };
                  return Theme(
                    data: brightness == Brightness.dark
                        ? darkTheme
                        : lightTheme,
                    child: child!,
                  );
                },
                routerConfig: _appRouter.config(),
              );
            }

            return MaterialApp.router(
              title: 'Flutter Demo',
              supportedLocales: I18n.all,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              locale: languageState.locale,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeMode,
              routerConfig: _appRouter.config(),
            );
          },
        );
      },
    );
  }
}