import 'dart:ui';
import 'package:equatable/equatable.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class ChangeLanguageEvent extends LanguageEvent {
  final Locale locale;
  const ChangeLanguageEvent(this.locale);

  @override
  List<Object> get props => [locale];
}

class ToggleDropdownEvent extends LanguageEvent {
  final bool isOpen;
  const ToggleDropdownEvent(this.isOpen);

  @override
  List<Object> get props => [isOpen];
}

class InitializeLanguageEvent extends LanguageEvent {
  // No additional properties needed but could be extended in the future
  const InitializeLanguageEvent();

  @override
  List<Object> get props => [];
}
