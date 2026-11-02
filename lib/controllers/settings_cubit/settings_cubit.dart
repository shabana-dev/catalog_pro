import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCubit extends Cubit<Locale> {
  final SharedPreferences _prefs;
  static const String _langKey = 'language_code';

  SettingsCubit(this._prefs) : super(Locale(_prefs.getString(_langKey) ?? 'en')) {
    // Ensure the initial state is synced with preferences
  }

  void toggleLanguage() {
    final newLocale = state.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    _prefs.setString(_langKey, newLocale.languageCode);
    emit(newLocale);
  }

  bool get isArabic => state.languageCode == 'ar';
}
