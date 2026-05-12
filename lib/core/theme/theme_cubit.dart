import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide theme mode (light / dark / follow system).
///
/// Persisted in SharedPreferences under `theme_mode` so the user's choice
/// survives an app restart. Mounted near the top of the widget tree (in
/// main.dart) so MaterialApp's `themeMode` reactively updates as soon as
/// the cubit emits.
class ThemeCubit extends Cubit<ThemeMode> {
  static const _prefsKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_load(_prefs));

  static ThemeMode _load(SharedPreferences prefs) {
    final raw = prefs.getString(_prefsKey);
    return switch (raw) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  static String _toString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _prefs.setString(_prefsKey, _toString(mode));
  }
}
