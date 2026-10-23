import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_event.dart';
import 'package:mobile_app_standard/shared/bloc/language/language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageState(Locale('en'))) {
    on<InitializeLanguageEvent>(_initializeLanguage);
    on<ChangeLanguageEvent>(_changeLanguage);
    on<ToggleDropdownEvent>(_toggleDropdown);
  }

  Future<void> _initializeLanguage(
      InitializeLanguageEvent event, Emitter<LanguageState> emit) async {
    try {
      Intl.defaultLocale = 'en';
      emit(state.copyWith(locale: Locale('en')));
    } catch (e) {
      print('Error during language initialization: $e');
    }
  }

  Future<void> _changeLanguage(
      ChangeLanguageEvent event, Emitter<LanguageState> emit) async {
    try {
      Intl.defaultLocale = event.locale.languageCode;
      emit(state.copyWith(locale: event.locale));
    } catch (e) {
      print('Error changing language: $e');
    }
  }

  void _toggleDropdown(ToggleDropdownEvent event, Emitter<LanguageState> emit) {
    emit(state.copyWith(isDropdownOpen: event.isOpen));
  }
}
