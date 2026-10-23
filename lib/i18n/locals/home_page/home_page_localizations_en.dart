// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'home_page_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class HomePageLocalizationsEn extends HomePageLocalizations {
  HomePageLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String text_welcome(Object appName) {
    return 'Welcome to $appName';
  }

  @override
  String get btn_check_ip => 'Check IP';

  @override
  String text_ip(Object ip) {
    return 'IP: $ip';
  }
}
