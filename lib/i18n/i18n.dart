import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_app_standard/i18n/locals/appbar/appbar_localizations.dart';
import 'package:mobile_app_standard/i18n/locals/general/general_localizations.dart';
import 'package:mobile_app_standard/i18n/locals/home_page/home_page_localizations.dart';
import 'package:mobile_app_standard/i18n/locals/todo_page/todo_page_localizations.dart';

class I18n {
  static final all = [const Locale('en'), const Locale('th')];
}

class AppLocalizations {
  final BuildContext context;

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
    GlobalCupertinoLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    AppbarLocalizations.delegate,
    GeneralLocalizations.delegate,
    HomePageLocalizations.delegate,
    TodoPageLocalizations.delegate,
  ];

  AppLocalizations(this.context);
  // Get AppbarLocalizations
  AppbarLocalizations get appbar => AppbarLocalizations.of(context)!;

  // Get GeneralLocalizations
  GeneralLocalizations get general => GeneralLocalizations.of(context)!;

  // Get HomePageLocalizations
  HomePageLocalizations get homePage => HomePageLocalizations.of(context)!;

  // Get TodoPageLocalizations
  TodoPageLocalizations get todoPage => TodoPageLocalizations.of(context)!;
}
