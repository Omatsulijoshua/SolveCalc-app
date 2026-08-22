import 'package:flutter/material.dart';
import '../../../core/theme/theme_presets.dart';
import '../../../presentation/providers/calculator_provider.dart';
import '../../../presentation/widgets/calculator_button.dart';

class CalculatorKeypad extends StatelessWidget {
  final CalculatorState state;
  final CalculatorThemeConfig theme;
  final CalculatorNotifier notifier;

  const CalculatorKeypad({
    super.key,
    required this.state,
    required this.theme,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          if (state.isScientific) ...[
            _buildScientificRow1(),
            _buildScientificRow2(),
            _buildScientificRow3(),
            const SizedBox(height: 4),
          ],
          _buildBasicRow1(),
          _buildBasicRow2(),
          _buildBasicRow3(),
          _buildBasicRow4(),
          _buildBasicRow5(),
        ],
      ),
    );
  }

  // --- Scientific Rows ---
  Widget _buildScientificRow1() {
    return Expanded(
      child: Row(
        children: [
          _fnBtn('sin', () => notifier.inputFunction('sin')),
          _fnBtn('cos', () => notifier.inputFunction('cos')),
          _fnBtn('tan', () => notifier.inputFunction('tan')),
          _fnBtn('log', () => notifier.inputFunction('log')),
          _fnBtn('ln', () => notifier.inputFunction('ln')),
        ],
      ),
    );
  }

  Widget _buildScientificRow2() {
    return Expanded(
      child: Row(
        children: [
          _fnBtn('asin', () => notifier.inputFunction('asin'), fontSize: 16),
          _fnBtn('acos', () => notifier.inputFunction('acos'), fontSize: 16),
          _fnBtn('atan', () => notifier.inputFunction('atan'), fontSize: 16),
          _fnBtn('√', () => notifier.inputFunction('sqrt')),
          _fnBtn('^', () => notifier.inputOperator('^')),
        ],
      ),
    );
  }

  Widget _buildScientificRow3() {
    return Expanded(
      child: Row(
        children: [
          _fnBtn('π', () => notifier.inputConstant('π')),
          _fnBtn('e', () => notifier.inputConstant('e')),
          _fnBtn('x²', () => notifier.inputPower('²')),
          _fnBtn('x³', () => notifier.inputPower('³')),
          _fnBtn('x!', () => notifier.inputOperator('!')),
        ],
      ),
    );
  }

  // --- Basic Rows ---
  Widget _buildBasicRow1() {
    return Expanded(
      child: Row(
        children: [
          _actionBtn(
            'AC',
            () => notifier.clear(),
            backgroundColor: theme.functionButtonColor,
            textColor: theme.isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
          ),
          _actionBtn(
            '( )',
            () => notifier.inputParenthesis(),
            backgroundColor: theme.functionButtonColor,
            textColor: theme.textPrimaryColor,
          ),
          _actionBtn(
            '%',
            () => notifier.inputPercent(),
            backgroundColor: theme.functionButtonColor,
            textColor: theme.textPrimaryColor,
          ),
          _actionBtn(
            '÷',
            () => notifier.inputOperator('/'),
            backgroundColor: theme.operatorButtonColor,
            textColor: theme.accentColor,
            fontSize: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicRow2() {
    return Expanded(
      child: Row(
        children: [
          _numBtn('7'),
          _numBtn('8'),
          _numBtn('9'),
          _actionBtn(
            '×',
            () => notifier.inputOperator('*'),
            backgroundColor: theme.operatorButtonColor,
            textColor: theme.accentColor,
            fontSize: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicRow3() {
    return Expanded(
      child: Row(
        children: [
          _numBtn('4'),
          _numBtn('5'),
          _numBtn('6'),
          _actionBtn(
            '−',
            () => notifier.inputOperator('-'),
            backgroundColor: theme.operatorButtonColor,
            textColor: theme.accentColor,
            fontSize: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicRow4() {
    return Expanded(
      child: Row(
        children: [
          _numBtn('1'),
          _numBtn('2'),
          _numBtn('3'),
          _actionBtn(
            '+',
            () => notifier.inputOperator('+'),
            backgroundColor: theme.operatorButtonColor,
            textColor: theme.accentColor,
            fontSize: 26,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicRow5() {
    return Expanded(
      child: Row(
        children: [
          _actionBtn(
            '±',
            () => notifier.toggleSign(),
            backgroundColor: theme.numberButtonColor,
            textColor: theme.textPrimaryColor,
          ),
          _numBtn('0'),
          _actionBtn(
            '.',
            () => notifier.inputDecimal(),
            backgroundColor: theme.numberButtonColor,
            textColor: theme.textPrimaryColor,
          ),
          _actionBtn(
            '=',
            () => notifier.evaluate(),
            type: ButtonType.equals,
            backgroundColor: theme.equalsButtonColor,
            textColor: theme.equalsTextColor,
            fontSize: 28,
          ),
        ],
      ),
    );
  }

  Widget _numBtn(String digit) {
    return CalculatorButton(
      text: digit,
      type: ButtonType.number,
      onTap: () => notifier.inputDigit(digit),
      backgroundColor: theme.numberButtonColor,
      textColor: theme.textPrimaryColor,
    );
  }

  Widget _fnBtn(String text, VoidCallback onTap, {double fontSize = 18}) {
    return CalculatorButton(
      text: text,
      type: ButtonType.function,
      onTap: onTap,
      backgroundColor: theme.functionButtonColor.withAlpha(150),
      textColor: theme.textSecondaryColor,
      fontSize: fontSize,
    );
  }

  Widget _actionBtn(
    String text,
    VoidCallback onTap, {
    ButtonType type = ButtonType.operator,
    required Color backgroundColor,
    required Color textColor,
    double fontSize = 22,
  }) {
    return CalculatorButton(
      text: text,
      type: type,
      onTap: onTap,
      onLongPress: text == 'AC' ? () => notifier.clear() : null,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}
