import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme_presets.dart';
import '../../../presentation/providers/calculator_provider.dart';

class CalculatorDisplay extends StatelessWidget {
  final CalculatorState state;
  final CalculatorThemeConfig theme;
  final VoidCallback onToggleAngleMode;
  final VoidCallback onToggleScientific;
  final VoidCallback onSwipeDelete;

  const CalculatorDisplay({
    super.key,
    required this.state,
    required this.theme,
    required this.onToggleAngleMode,
    required this.onToggleScientific,
    required this.onSwipeDelete,
  });

  void _copyToClipboard(BuildContext context, String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$text" to clipboard'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final angleStr = state.angleMode.name.toUpperCase();

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 100) {
          onSwipeDelete();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.surfaceColor.withAlpha(220),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Top Status Bar (Angle Mode, Mode Toggle, Clear action)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Angle Mode Badge
                GestureDetector(
                  onTap: onToggleAngleMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.primaryColor.withAlpha(80)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          angleStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.swap_horiz, size: 14, color: theme.primaryColor),
                      ],
                    ),
                  ),
                ),

                // Scientific / Basic Mode Toggle
                GestureDetector(
                  onTap: onToggleScientific,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.functionButtonColor.withAlpha(120),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.isScientific ? Icons.functions : Icons.calculate_outlined,
                          size: 14,
                          color: theme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.isScientific ? 'Scientific' : 'Basic',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Expression Input Line
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: GestureDetector(
                onLongPress: () => _copyToClipboard(context, state.expression),
                child: Text(
                  state.expression.isEmpty ? '0' : state.expression,
                  style: TextStyle(
                    fontSize: state.isEvaluated ? 26 : 38,
                    fontWeight: FontWeight.w400,
                    color: state.isEvaluated
                        ? theme.textSecondaryColor
                        : theme.textPrimaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Live / Evaluated Result or Error Line
            if (state.errorMessage != null)
              Text(
                state.errorMessage!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFEF4444),
                ),
              )
            else
              GestureDetector(
                onLongPress: () => _copyToClipboard(context, state.liveResult),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (state.liveResult.isNotEmpty && !state.isEvaluated)
                        Text(
                          '= ',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                            color: theme.accentColor.withAlpha(180),
                          ),
                        ),
                      Text(
                        state.liveResult,
                        style: TextStyle(
                          fontSize: state.isEvaluated ? 44 : 26,
                          fontWeight: state.isEvaluated ? FontWeight.bold : FontWeight.w500,
                          color: state.isEvaluated
                              ? theme.primaryColor
                              : theme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
