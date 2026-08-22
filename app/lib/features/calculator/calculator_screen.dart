import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_controller.dart';
import '../../presentation/providers/calculator_provider.dart';
import 'widgets/calculator_display.dart';
import 'widgets/calculator_keypad.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calcState = ref.watch(calculatorProvider);
    final calcNotifier = ref.read(calculatorProvider.notifier);
    final theme = ref.watch(themeControllerProvider);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Display Area
            Expanded(
              flex: calcState.isScientific ? 3 : 4,
              child: CalculatorDisplay(
                state: calcState,
                theme: theme,
                onToggleAngleMode: calcNotifier.toggleAngleMode,
                onToggleScientific: calcNotifier.toggleScientific,
                onSwipeDelete: calcNotifier.backspace,
              ),
            ),

            // Keypad Area
            Expanded(
              flex: calcState.isScientific ? 7 : 6,
              child: CalculatorKeypad(
                state: calcState,
                theme: theme,
                notifier: calcNotifier,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
