import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/storage_service.dart';
import 'theme_presets.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be initialized in main()');
});

final themeControllerProvider =
    StateNotifierProvider<ThemeController, CalculatorThemeConfig>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeController(storage);
});

class ThemeController extends StateNotifier<CalculatorThemeConfig> {
  final StorageService _storage;

  ThemeController(this._storage) : super(_loadInitialTheme(_storage));

  static CalculatorThemeConfig _loadInitialTheme(StorageService storage) {
    final presetId = storage.getThemePreset();
    if (presetId == ThemePresetId.custom) {
      final custom = storage.getCustomTheme();
      if (custom != null) return custom;
    }
    return ThemePresets.getById(presetId);
  }

  void selectPreset(ThemePresetId presetId) {
    final theme = ThemePresets.getById(presetId);
    state = theme;
    _storage.setThemePreset(presetId);
  }

  void updateCustomTheme(CalculatorThemeConfig customTheme) {
    state = customTheme;
    _storage.setThemePreset(ThemePresetId.custom);
    _storage.setCustomTheme(customTheme);
  }

  ThemeData get materialThemeData {
    final isDark = state.isDark;
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: state.primaryColor,
      onPrimary: state.equalsTextColor,
      secondary: state.secondaryColor,
      onSecondary: state.textPrimaryColor,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      surface: state.surfaceColor,
      onSurface: state.textPrimaryColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: state.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: state.backgroundColor,
        foregroundColor: state.textPrimaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: state.surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: state.surfaceColor,
        selectedItemColor: state.primaryColor,
        unselectedItemColor: state.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
