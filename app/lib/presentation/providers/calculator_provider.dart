import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utilities/haptics_helper.dart';
import '../../data/models/calculation_item.dart';
import '../../data/repositories/calculation_history_repository.dart';
import '../../data/services/storage_service.dart';
import '../../domain/calculator/calculator_engine.dart';
import '../../domain/calculator/evaluator.dart';
import '../../core/theme/theme_controller.dart';

class CalculatorState {
  final String expression;
  final String liveResult;
  final String? errorMessage;
  final AngleMode angleMode;
  final bool isScientific;
  final bool isEvaluated;

  const CalculatorState({
    required this.expression,
    required this.liveResult,
    this.errorMessage,
    required this.angleMode,
    required this.isScientific,
    this.isEvaluated = false,
  });

  CalculatorState copyWith({
    String? expression,
    String? liveResult,
    String? errorMessage,
    bool clearError = false,
    AngleMode? angleMode,
    bool? isScientific,
    bool? isEvaluated,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      liveResult: liveResult ?? this.liveResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      angleMode: angleMode ?? this.angleMode,
      isScientific: isScientific ?? this.isScientific,
      isEvaluated: isEvaluated ?? this.isEvaluated,
    );
  }
}

final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final historyRepo = ref.watch(calculationHistoryRepositoryProvider);
  return CalculatorNotifier(storage, historyRepo);
});

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  final StorageService _storage;
  final CalculationHistoryRepository _historyRepo;
  static const _uuid = Uuid();

  CalculatorNotifier(this._storage, this._historyRepo)
      : super(CalculatorState(
          expression: '',
          liveResult: '',
          angleMode: _parseAngleMode(_storage.getAngleMode()),
          isScientific: _storage.isScientificDefault(),
        ));

  static AngleMode _parseAngleMode(String mode) {
    switch (mode) {
      case 'RAD':
        return AngleMode.rad;
      case 'GRAD':
        return AngleMode.grad;
      default:
        return AngleMode.deg;
    }
  }

  void _triggerHaptic() {
    if (_storage.isHapticEnabled()) {
      HapticsHelper.light();
    }
  }

  void inputDigit(String digit) {
    _triggerHaptic();
    if (state.isEvaluated) {
      state = state.copyWith(
        expression: digit,
        isEvaluated: false,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        expression: state.expression + digit,
        clearError: true,
      );
    }
    _updateLiveResult();
  }

  void inputDecimal() {
    _triggerHaptic();
    if (state.isEvaluated || state.expression.isEmpty) {
      state = state.copyWith(
        expression: '0.',
        isEvaluated: false,
        clearError: true,
      );
    } else {
      // Find the last number token
      final tokens = state.expression.split(RegExp(r'[+\−×÷*/^()%]'));
      final lastToken = tokens.isNotEmpty ? tokens.last : '';
      if (!lastToken.contains('.')) {
        state = state.copyWith(
          expression: '${state.expression}.',
          clearError: true,
        );
      }
    }
    _updateLiveResult();
  }

  void inputOperator(String op) {
    _triggerHaptic();
    String formattedOp = op;
    if (op == '*') formattedOp = '×';
    if (op == '/') formattedOp = '÷';
    if (op == '-') formattedOp = '−';

    if (state.isEvaluated && state.liveResult.isNotEmpty && state.errorMessage == null) {
      state = state.copyWith(
        expression: '${state.liveResult} $formattedOp ',
        isEvaluated: false,
        clearError: true,
      );
    } else if (state.expression.isEmpty) {
      if (formattedOp == '−' || formattedOp == '+') {
        state = state.copyWith(
          expression: formattedOp,
          clearError: true,
        );
      }
    } else {
      final trimmed = state.expression.trimRight();
      final endsWithOp = trimmed.endsWith('+') ||
          trimmed.endsWith('−') ||
          trimmed.endsWith('×') ||
          trimmed.endsWith('÷') ||
          trimmed.endsWith('^') ||
          trimmed.endsWith('*') ||
          trimmed.endsWith('/');

      if (endsWithOp) {
        // Replace previous operator
        final newExpr = trimmed.substring(0, trimmed.length - 1).trimRight();
        state = state.copyWith(
          expression: '$newExpr $formattedOp ',
          clearError: true,
        );
      } else {
        state = state.copyWith(
          expression: '$trimmed $formattedOp ',
          clearError: true,
        );
      }
    }
    _updateLiveResult();
  }

  void inputFunction(String funcName) {
    _triggerHaptic();
    if (state.isEvaluated) {
      state = state.copyWith(
        expression: '$funcName(',
        isEvaluated: false,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        expression: '${state.expression}$funcName(',
        clearError: true,
      );
    }
    _updateLiveResult();
  }

  void inputConstant(String constant) {
    _triggerHaptic();
    if (state.isEvaluated) {
      state = state.copyWith(
        expression: constant,
        isEvaluated: false,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        expression: state.expression + constant,
        clearError: true,
      );
    }
    _updateLiveResult();
  }

  void inputParenthesis() {
    _triggerHaptic();
    final expr = state.expression;
    final openCount = '('.allMatches(expr).length;
    final closeCount = ')'.allMatches(expr).length;

    if (expr.isEmpty || state.isEvaluated) {
      state = state.copyWith(
        expression: '(',
        isEvaluated: false,
        clearError: true,
      );
    } else {
      final lastChar = expr.isNotEmpty ? expr[expr.length - 1] : '';
      if (openCount > closeCount &&
          (RegExp(r'[0-9πe)%!]').hasMatch(lastChar))) {
        state = state.copyWith(
          expression: '$expr)',
          clearError: true,
        );
      } else {
        state = state.copyWith(
          expression: '$expr(',
          clearError: true,
        );
      }
    }
    _updateLiveResult();
  }

  void inputPercent() {
    _triggerHaptic();
    if (state.expression.isNotEmpty) {
      state = state.copyWith(
        expression: '${state.expression}%',
        clearError: true,
      );
      _updateLiveResult();
    }
  }

  void inputPower(String pow) {
    _triggerHaptic();
    if (state.expression.isNotEmpty) {
      state = state.copyWith(
        expression: state.expression + pow,
        clearError: true,
      );
      _updateLiveResult();
    }
  }

  void toggleSign() {
    _triggerHaptic();
    if (state.expression.isEmpty) {
      state = state.copyWith(expression: '−', clearError: true);
    } else if (state.expression.startsWith('−') || state.expression.startsWith('-')) {
      state = state.copyWith(
        expression: state.expression.substring(1),
        clearError: true,
      );
    } else {
      state = state.copyWith(
        expression: '−${state.expression}',
        clearError: true,
      );
    }
    _updateLiveResult();
  }

  void backspace() {
    _triggerHaptic();
    if (state.expression.isEmpty) return;

    if (state.isEvaluated) {
      clear();
      return;
    }

    String expr = state.expression;
    // Check if ends with function like "sin(", "cos(", "asin(" etc.
    final funcMatch = RegExp(r'[a-zA-Z]+\($').firstMatch(expr);
    if (funcMatch != null) {
      expr = expr.substring(0, funcMatch.start);
    } else if (expr.endsWith(' ')) {
      // Remove trailing operator and spacing " + "
      expr = expr.trimRight();
      if (expr.isNotEmpty) {
        expr = expr.substring(0, expr.length - 1).trimRight();
      }
    } else {
      expr = expr.substring(0, expr.length - 1);
    }

    state = state.copyWith(expression: expr, clearError: true);
    _updateLiveResult();
  }

  void clear() {
    _triggerHaptic();
    state = state.copyWith(
      expression: '',
      liveResult: '',
      clearError: true,
      isEvaluated: false,
    );
  }

  void toggleAngleMode() {
    _triggerHaptic();
    AngleMode nextMode;
    switch (state.angleMode) {
      case AngleMode.deg:
        nextMode = AngleMode.rad;
        break;
      case AngleMode.rad:
        nextMode = AngleMode.grad;
        break;
      case AngleMode.grad:
        nextMode = AngleMode.deg;
        break;
    }
    state = state.copyWith(angleMode: nextMode);
    _storage.setAngleMode(nextMode.name.toUpperCase());
    _updateLiveResult();
  }

  void toggleScientific() {
    _triggerHaptic();
    final newMode = !state.isScientific;
    state = state.copyWith(isScientific: newMode);
    _storage.setScientificDefault(newMode);
  }

  void setExpression(String expr) {
    state = state.copyWith(
      expression: expr,
      isEvaluated: false,
      clearError: true,
    );
    _updateLiveResult();
  }

  void evaluate() {
    _triggerHaptic();
    if (state.expression.trim().isEmpty) return;

    final precision = _storage.getDecimalPrecision();
    final res = CalculatorEngine.tryCalculate(
      state.expression,
      angleMode: state.angleMode,
      maxPrecision: precision,
    );

    if (res.isSuccess && res.formattedResult != null) {
      final formatted = res.formattedResult!;
      final oldExpression = state.expression;

      state = state.copyWith(
        liveResult: formatted,
        isEvaluated: true,
        clearError: true,
      );

      // Save to calculation history if enabled
      if (_storage.isSaveHistoryEnabled()) {
        _historyRepo.addCalculation(CalculationItem(
          id: _uuid.v4(),
          expression: oldExpression,
          result: formatted,
          angleMode: state.angleMode.name.toUpperCase(),
          timestamp: DateTime.now(),
        ));
      }
    } else {
      state = state.copyWith(
        errorMessage: res.errorMessage ?? 'Invalid expression',
      );
      HapticsHelper.error();
    }
  }

  void _updateLiveResult() {
    if (state.expression.trim().isEmpty) {
      state = state.copyWith(liveResult: '', clearError: true);
      return;
    }

    final precision = _storage.getDecimalPrecision();
    final res = CalculatorEngine.tryCalculate(
      state.expression,
      angleMode: state.angleMode,
      maxPrecision: precision,
    );

    if (res.isSuccess && res.formattedResult != null) {
      state = state.copyWith(
        liveResult: res.formattedResult!,
        clearError: true,
      );
    }
  }
}
