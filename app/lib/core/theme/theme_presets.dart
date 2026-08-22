import 'package:flutter/material.dart';

enum ThemePresetId {
  classic,
  midnight,
  white,
  casio,
  ocean,
  forest,
  purple,
  sunset,
  minimal,
  custom,
}

class CalculatorThemeConfig {
  final ThemePresetId id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color numberButtonColor;
  final Color operatorButtonColor;
  final Color functionButtonColor;
  final Color equalsButtonColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;
  final Color equalsTextColor;
  final bool isDark;

  const CalculatorThemeConfig({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.numberButtonColor,
    required this.operatorButtonColor,
    required this.functionButtonColor,
    required this.equalsButtonColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
    required this.equalsTextColor,
    required this.isDark,
  });

  Map<String, dynamic> toJson() => {
        'id': id.name,
        'name': name,
        'primaryColor': primaryColor.toARGB32(),
        'secondaryColor': secondaryColor.toARGB32(),
        'accentColor': accentColor.toARGB32(),
        'backgroundColor': backgroundColor.toARGB32(),
        'surfaceColor': surfaceColor.toARGB32(),
        'numberButtonColor': numberButtonColor.toARGB32(),
        'operatorButtonColor': operatorButtonColor.toARGB32(),
        'functionButtonColor': functionButtonColor.toARGB32(),
        'equalsButtonColor': equalsButtonColor.toARGB32(),
        'textPrimaryColor': textPrimaryColor.toARGB32(),
        'textSecondaryColor': textSecondaryColor.toARGB32(),
        'equalsTextColor': equalsTextColor.toARGB32(),
        'isDark': isDark,
      };

  factory CalculatorThemeConfig.fromJson(Map<String, dynamic> json) {
    return CalculatorThemeConfig(
      id: ThemePresetId.values.firstWhere(
        (e) => e.name == json['id'],
        orElse: () => ThemePresetId.classic,
      ),
      name: json['name'] as String? ?? 'Custom',
      primaryColor: Color(json['primaryColor'] as int),
      secondaryColor: Color(json['secondaryColor'] as int),
      accentColor: Color(json['accentColor'] as int),
      backgroundColor: Color(json['backgroundColor'] as int),
      surfaceColor: Color(json['surfaceColor'] as int),
      numberButtonColor: Color(json['numberButtonColor'] as int),
      operatorButtonColor: Color(json['operatorButtonColor'] as int),
      functionButtonColor: Color(json['functionButtonColor'] as int),
      equalsButtonColor: Color(json['equalsButtonColor'] as int),
      textPrimaryColor: Color(json['textPrimaryColor'] as int),
      textSecondaryColor: Color(json['textSecondaryColor'] as int),
      equalsTextColor: Color(json['equalsTextColor'] as int),
      isDark: json['isDark'] as bool? ?? true,
    );
  }

  CalculatorThemeConfig copyWith({
    ThemePresetId? id,
    String? name,
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? numberButtonColor,
    Color? operatorButtonColor,
    Color? functionButtonColor,
    Color? equalsButtonColor,
    Color? textPrimaryColor,
    Color? textSecondaryColor,
    Color? equalsTextColor,
    bool? isDark,
  }) {
    return CalculatorThemeConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      numberButtonColor: numberButtonColor ?? this.numberButtonColor,
      operatorButtonColor: operatorButtonColor ?? this.operatorButtonColor,
      functionButtonColor: functionButtonColor ?? this.functionButtonColor,
      equalsButtonColor: equalsButtonColor ?? this.equalsButtonColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
      equalsTextColor: equalsTextColor ?? this.equalsTextColor,
      isDark: isDark ?? this.isDark,
    );
  }
}

class ThemePresets {
  static const CalculatorThemeConfig white = CalculatorThemeConfig(
    id: ThemePresetId.white,
    name: 'Pure White',
    primaryColor: Color(0xFF0F172A),
    secondaryColor: Color(0xFFF1F5F9),
    accentColor: Color(0xFF3B82F6),
    backgroundColor: Color(0xFFFFFFFF),
    surfaceColor: Color(0xFFF8FAFC),
    numberButtonColor: Color(0xFFF1F5F9),
    operatorButtonColor: Color(0xFFE2E8F0),
    functionButtonColor: Color(0xFFE2E8F0),
    equalsButtonColor: Color(0xFF0F172A),
    textPrimaryColor: Color(0xFF0F172A),
    textSecondaryColor: Color(0xFF64748B),
    equalsTextColor: Color(0xFFFFFFFF),
    isDark: false,
  );

  static const CalculatorThemeConfig casio = CalculatorThemeConfig(
    id: ThemePresetId.casio,
    name: 'Casio Scientific',
    primaryColor: Color(0xFF38BDF8),
    secondaryColor: Color(0xFF262C36),
    accentColor: Color(0xFFFBBF24),
    backgroundColor: Color(0xFF1E222A),
    surfaceColor: Color(0xFF8FA486), // Authentic retro Casio greenish LCD screen
    numberButtonColor: Color(0xFFECEFF1), // Off-white Casio numbers
    operatorButtonColor: Color(0xFF333A42), // Dark matte scientific buttons
    functionButtonColor: Color(0xFF2A3038),
    equalsButtonColor: Color(0xFF2563EB),
    textPrimaryColor: Color(0xFFF8FAFC),
    textSecondaryColor: Color(0xFF94A3B8),
    equalsTextColor: Color(0xFFFFFFFF),
    isDark: true,
  );

  static const CalculatorThemeConfig midnight = CalculatorThemeConfig(
    id: ThemePresetId.midnight,
    name: 'Midnight',
    primaryColor: Color(0xFF3B82F6),
    secondaryColor: Color(0xFF1E293B),
    accentColor: Color(0xFF60A5FA),
    backgroundColor: Color(0xFF0F172A),
    surfaceColor: Color(0xFF1E293B),
    numberButtonColor: Color(0xFF1E293B),
    operatorButtonColor: Color(0xFF334155),
    functionButtonColor: Color(0xFF1E293B),
    equalsButtonColor: Color(0xFF3B82F6),
    textPrimaryColor: Color(0xFFF8FAFC),
    textSecondaryColor: Color(0xFF94A3B8),
    equalsTextColor: Color(0xFFFFFFFF),
    isDark: true,
  );

  static const CalculatorThemeConfig classic = CalculatorThemeConfig(
    id: ThemePresetId.classic,
    name: 'Classic Dark',
    primaryColor: Color(0xFFFF9500),
    secondaryColor: Color(0xFF2C2C2E),
    accentColor: Color(0xFFFF9F0A),
    backgroundColor: Color(0xFF000000),
    surfaceColor: Color(0xFF1C1C1E),
    numberButtonColor: Color(0xFF2C2C2E),
    operatorButtonColor: Color(0xFFFF9500),
    functionButtonColor: Color(0xFF505050),
    equalsButtonColor: Color(0xFFFF9500),
    textPrimaryColor: Color(0xFFFFFFFF),
    textSecondaryColor: Color(0xFFAAAAAA),
    equalsTextColor: Color(0xFFFFFFFF),
    isDark: true,
  );

  static const CalculatorThemeConfig ocean = CalculatorThemeConfig(
    id: ThemePresetId.ocean,
    name: 'Ocean Cyan',
    primaryColor: Color(0xFF06B6D4),
    secondaryColor: Color(0xFF164E63),
    accentColor: Color(0xFF22D3EE),
    backgroundColor: Color(0xFF082F49),
    surfaceColor: Color(0xFF0C4A6E),
    numberButtonColor: Color(0xFF0E7490),
    operatorButtonColor: Color(0xFF155E75),
    functionButtonColor: Color(0xFF164E63),
    equalsButtonColor: Color(0xFF06B6D4),
    textPrimaryColor: Color(0xFFECFEFF),
    textSecondaryColor: Color(0xFFA5F3FC),
    equalsTextColor: Color(0xFF082F49),
    isDark: true,
  );

  static const CalculatorThemeConfig forest = CalculatorThemeConfig(
    id: ThemePresetId.forest,
    name: 'Emerald Forest',
    primaryColor: Color(0xFF10B981),
    secondaryColor: Color(0xFF064E3B),
    accentColor: Color(0xFF34D399),
    backgroundColor: Color(0xFF022C22),
    surfaceColor: Color(0xFF064E3B),
    numberButtonColor: Color(0xFF047857),
    operatorButtonColor: Color(0xFF065F46),
    functionButtonColor: Color(0xFF064E3B),
    equalsButtonColor: Color(0xFF10B981),
    textPrimaryColor: Color(0xFFECFDF5),
    textSecondaryColor: Color(0xFFA7F3D0),
    equalsTextColor: Color(0xFF022C22),
    isDark: true,
  );

  static const CalculatorThemeConfig purple = CalculatorThemeConfig(
    id: ThemePresetId.purple,
    name: 'Cyber Purple',
    primaryColor: Color(0xFF8B5CF6),
    secondaryColor: Color(0xFF2E1065),
    accentColor: Color(0xFFA78BFA),
    backgroundColor: Color(0xFF1E1035),
    surfaceColor: Color(0xFF3B1873),
    numberButtonColor: Color(0xFF4C1D95),
    operatorButtonColor: Color(0xFF5B21B6),
    functionButtonColor: Color(0xFF3B1873),
    equalsButtonColor: Color(0xFF8B5CF6),
    textPrimaryColor: Color(0xFFF5F3FF),
    textSecondaryColor: Color(0xFFDDD6FE),
    equalsTextColor: Color(0xFFFFFFFF),
    isDark: true,
  );

  static const CalculatorThemeConfig sunset = CalculatorThemeConfig(
    id: ThemePresetId.sunset,
    name: 'Sunset Orange',
    primaryColor: Color(0xFFF97316),
    secondaryColor: Color(0xFF7C2D12),
    accentColor: Color(0xFFFB923C),
    backgroundColor: Color(0xFF431407),
    surfaceColor: Color(0xFF7C2D12),
    numberButtonColor: Color(0xFF9A3412),
    operatorButtonColor: Color(0xFFC2410C),
    functionButtonColor: Color(0xFF7C2D12),
    equalsButtonColor: Color(0xFFF97316),
    textPrimaryColor: Color(0xFFFFF7ED),
    textSecondaryColor: Color(0xFFFED7AA),
    equalsTextColor: Color(0xFFFFFFFF),
    isDark: true,
  );

  static const CalculatorThemeConfig minimal = CalculatorThemeConfig(
    id: ThemePresetId.minimal,
    name: 'Minimal Light',
    primaryColor: Color(0xFF2563EB),
    secondaryColor: Color(0xFFE2E8F0),
    accentColor: Color(0xFF3B82F6),
    backgroundColor: Color(0xFFF8FAFC),
    surfaceColor: Color(0xFFFFFFFF),
    numberButtonColor: Color(0xFFF1F5F9),
    operatorButtonColor: Color(0xFFE2E8F0),
    functionButtonColor: Color(0xFFE2E8F0),
    equalsButtonColor: Color(0xFF2563EB),
    textPrimaryColor: Color(0xFF0F172A),
    textSecondaryColor: Color(0xFF64748B),
    equalsTextColor: Color(0xFFFFFFFF),
    isDark: false,
  );

  static List<CalculatorThemeConfig> get allPresets => [
        white,
        casio,
        midnight,
        classic,
        ocean,
        forest,
        purple,
        sunset,
        minimal,
      ];

  static CalculatorThemeConfig getById(ThemePresetId id) {
    switch (id) {
      case ThemePresetId.white:
        return white;
      case ThemePresetId.casio:
        return casio;
      case ThemePresetId.midnight:
        return midnight;
      case ThemePresetId.classic:
        return classic;
      case ThemePresetId.ocean:
        return ocean;
      case ThemePresetId.forest:
        return forest;
      case ThemePresetId.purple:
        return purple;
      case ThemePresetId.sunset:
        return sunset;
      case ThemePresetId.minimal:
        return minimal;
      case ThemePresetId.custom:
        return midnight;
    }
  }
}
