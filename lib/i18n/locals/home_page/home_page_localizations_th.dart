// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'home_page_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class HomePageLocalizationsTh extends HomePageLocalizations {
  HomePageLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String text_welcome(Object appName) {
    return 'ยินดีต้อนรับสู่ $appName';
  }

  @override
  String get btn_check_ip => 'ตรวจสอบ IP';

  @override
  String text_ip(Object ip) {
    return 'ไอพี: $ip';
  }
}
