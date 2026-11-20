import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/recording/recorder_controller.dart';

const _themeModeSettingKey = 'appearance_theme_mode';

final themeModeProvider = AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final settings = await ref.watch(settingsRepositoryProvider.future);
    return _parse(await settings.getString(_themeModeSettingKey));
  }

  Future<void> setMode(ThemeMode mode) async {
    final previous = state.asData?.value ?? ThemeMode.system;
    state = AsyncData(mode);
    try {
      final settings = await ref.read(settingsRepositoryProvider.future);
      await settings.setString(_themeModeSettingKey, _serialize(mode));
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  ThemeMode _parse(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  String _serialize(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}
