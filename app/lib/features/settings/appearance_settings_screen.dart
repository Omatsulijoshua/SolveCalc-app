import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/theme_presets.dart';

class AppearanceSettingsScreen extends ConsumerWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);

    return Scaffold(
      backgroundColor: currentTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Appearance & Themes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Live Theme Preview Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: currentTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: currentTheme.primaryColor, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE THEME PREVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.primaryColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      currentTheme.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'sin(30) + √25',
                  style: TextStyle(
                    fontSize: 20,
                    color: currentTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '= 5.5',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: currentTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _previewBtn('AC', currentTheme.functionButtonColor, currentTheme.textPrimaryColor),
                    const SizedBox(width: 8),
                    _previewBtn('7', currentTheme.numberButtonColor, currentTheme.textPrimaryColor),
                    const SizedBox(width: 8),
                    _previewBtn('+', currentTheme.operatorButtonColor, currentTheme.accentColor),
                    const SizedBox(width: 8),
                    _previewBtn('=', currentTheme.equalsButtonColor, currentTheme.equalsTextColor),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'THEME PRESETS',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),

          // Preset Selection Grid
          for (final preset in ThemePresets.allPresets)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: currentTheme.surfaceColor,
                clipBehavior: Clip.antiAlias,
                shape: currentTheme.id == preset.id
                    ? RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: currentTheme.primaryColor, width: 2),
                      )
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                child: ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: preset.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24, width: 2),
                    ),
                  ),
                  title: Text(
                    preset.name,
                    style: TextStyle(
                      fontWeight: currentTheme.id == preset.id ? FontWeight.bold : FontWeight.w500,
                      color: currentTheme.textPrimaryColor,
                    ),
                  ),
                  subtitle: Text(
                    preset.isDark ? 'Dark Palette' : 'Light Palette',
                    style: TextStyle(fontSize: 12, color: currentTheme.textSecondaryColor),
                  ),
                  trailing: currentTheme.id == preset.id
                      ? Icon(Icons.check_circle, color: currentTheme.primaryColor)
                      : null,
                  onTap: () => themeController.selectPreset(preset.id),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _previewBtn(String text, Color bg, Color textCol) {
    return Expanded(
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textCol,
            ),
          ),
        ),
      ),
    );
  }
}
