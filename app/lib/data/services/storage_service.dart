import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/theme_presets.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Onboarding
  bool isOnboardingComplete() {
    return _prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(AppConstants.keyOnboardingComplete, complete);
  }

  // Theme Preset
  ThemePresetId getThemePreset() {
    final name = _prefs.getString(AppConstants.keyThemePreset);
    if (name == null) return ThemePresetId.midnight;
    return ThemePresetId.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ThemePresetId.midnight,
    );
  }

  Future<void> setThemePreset(ThemePresetId preset) async {
    await _prefs.setString(AppConstants.keyThemePreset, preset.name);
  }

  // Custom Theme
  CalculatorThemeConfig? getCustomTheme() {
    final raw = _prefs.getString(AppConstants.keyCustomTheme);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CalculatorThemeConfig.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> setCustomTheme(CalculatorThemeConfig theme) async {
    final raw = jsonEncode(theme.toJson());
    await _prefs.setString(AppConstants.keyCustomTheme, raw);
  }

  // Calculator Preferences
  String getAngleMode() {
    return _prefs.getString(AppConstants.keyAngleMode) ?? 'DEG';
  }

  Future<void> setAngleMode(String mode) async {
    await _prefs.setString(AppConstants.keyAngleMode, mode);
  }

  bool isScientificDefault() {
    return _prefs.getBool(AppConstants.keyDefaultCalcMode) ?? false;
  }

  Future<void> setScientificDefault(bool isScientific) async {
    await _prefs.setBool(AppConstants.keyDefaultCalcMode, isScientific);
  }

  bool isHapticEnabled() {
    return _prefs.getBool(AppConstants.keyHapticEnabled) ?? true;
  }

  Future<void> setHapticEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyHapticEnabled, enabled);
  }

  int getDecimalPrecision() {
    return _prefs.getInt(AppConstants.keyDecimalPrecision) ?? 10;
  }

  Future<void> setDecimalPrecision(int precision) async {
    await _prefs.setInt(AppConstants.keyDecimalPrecision, precision);
  }

  bool isSaveHistoryEnabled() {
    return _prefs.getBool(AppConstants.keySaveHistoryEnabled) ?? true;
  }

  Future<void> setSaveHistoryEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keySaveHistoryEnabled, enabled);
  }

  // AI & Solution Preferences
  bool isLearnModeEnabled() {
    return _prefs.getBool(AppConstants.keyLearnModeEnabled) ?? true;
  }

  Future<void> setLearnModeEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyLearnModeEnabled, enabled);
  }

  String getAiProvider() {
    return _prefs.getString(AppConstants.keyAiProvider) ?? 'local';
  }

  Future<void> setAiProvider(String provider) async {
    await _prefs.setString(AppConstants.keyAiProvider, provider);
  }

  String? getAiApiKey() {
    return _prefs.getString(AppConstants.keyAiApiKey);
  }

  Future<void> setAiApiKey(String? apiKey) async {
    if (apiKey == null || apiKey.isEmpty) {
      await _prefs.remove(AppConstants.keyAiApiKey);
    } else {
      await _prefs.setString(AppConstants.keyAiApiKey, apiKey);
    }
  }

  String? getGroqApiKey() {
    return _prefs.getString(AppConstants.keyGroqApiKey);
  }

  Future<void> setGroqApiKey(String? apiKey) async {
    if (apiKey == null || apiKey.trim().isEmpty) {
      await _prefs.remove(AppConstants.keyGroqApiKey);
    } else {
      await _prefs.setString(AppConstants.keyGroqApiKey, apiKey.trim());
    }
  }

  // Premium Pro Tier ($10 Lifetime)
  bool isPremium() {
    return _prefs.getBool(AppConstants.keyIsPremium) ?? false;
  }

  Future<void> setPremium(bool isPro) async {
    await _prefs.setBool(AppConstants.keyIsPremium, isPro);
  }

  // Calculation History
  List<Map<String, dynamic>> getCalculationHistory() {
    final list = _prefs.getStringList(AppConstants.keyCalculationHistory) ?? [];
    return list.map((item) {
      try {
        return jsonDecode(item) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((m) => m.isNotEmpty).toList();
  }

  Future<void> saveCalculationHistory(List<Map<String, dynamic>> history) async {
    final list = history.map((item) => jsonEncode(item)).toList();
    await _prefs.setStringList(AppConstants.keyCalculationHistory, list);
  }

  // Scanned Solution History
  List<Map<String, dynamic>> getSolutionHistory() {
    final list = _prefs.getStringList(AppConstants.keySolutionHistory) ?? [];
    return list.map((item) {
      try {
        return jsonDecode(item) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((m) => m.isNotEmpty).toList();
  }

  Future<void> saveSolutionHistory(List<Map<String, dynamic>> history) async {
    final list = history.map((item) => jsonEncode(item)).toList();
    await _prefs.setStringList(AppConstants.keySolutionHistory, list);
  }
}
