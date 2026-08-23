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
  final int cursorPosition;
  final String liveResult;
  final String? errorMessage;
  final AngleMode angleMode;
  final bool isScientific;
  final bool isEvaluated;

  const CalculatorState({
    required this.expression,
    this.cursorPosition = 0,
    required this.liveResult,
    this.errorMessage,
    required this.angleMode,
    required this.isScientific,
    this.isEvaluated = false,
  });

  CalculatorState copyWith({
    String? expression,
    int? cursorPosition,
    String? liveResult,
    String? errorMessage,
    bool clearError = false,
    AngleMode? angleMode,
    bool? isScientific,
    bool? isEvaluated,
  }) {
    final newExpr = expression ?? this.expression;
    final newPos = cursorPosition ?? (expression != null ? newExpr.length : this.cursorPosition);
    return CalculatorState(
      expression: newExpr,
      cursorPosition: newPos.clamp(0, newExpr.length),
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
          cursorPosition: 0,
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
        cursorPosition: digit.length,
        isEvaluated: false,
        clearError: true,
      );
    } else {
      final pos = state.cursorPosition;
      final expr = state.expression;
      final newExpr = '${expr.substring(0, pos)}$digit${expr.substring(pos)}';
      state = state.copyWith(
        expression: newExpr,
        cursorPosition: pos + digit.length,
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
        cursorPosition: 2,
        isEvaluated: false,
        clearError: true,
      );
    } else {
      final pos = state.cursorPosition;
      final expr = state.expression;
      final before = expr.substring(0, pos);
      final after = expr.substring(pos);

      // Find the last number token in before
      final tokens = before.split(RegExp(r'[+\−×÷*/^()%]'));
      final lastToken = tokens.isNotEmpty ? tokens.last : '';
      if (!lastToken.contains('.')) {
        final newExpr = '$before.$after';
        state = state.copyWith(
          expression: newExpr,
          cursorPosition: pos + 1,
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
      final expr = '${state.liveResult} $formattedOp ';
      state = state.copyWith(
        expression: expr,
        cursorPosition: expr.length,
        isEvaluated: false,
        clearError: true,
      );
    } else if (state.expression.isEmpty) {
      if (formattedOp == '−' || formattedOp == '+') {
        state = state.copyWith(
          expression: formattedOp,
          cursorPosition: 1,
          clearError: true,
        );
      }
    } else {
      var pos = state.cursorPosition;
      var expr = state.expression;

      // If cursor is right before ')' at the end of a closed bracket (e.g. sin(8|)),
      // step past the ')' so the operator is placed outside!
      while (pos < expr.length && expr[pos] == ')') {
        pos++;
      }

      final before = expr.substring(0, pos).trimRight();
      final after = expr.substring(pos).trimLeft();

      final endsWithOp = before.endsWith('+') ||
          before.endsWith('−') ||
          before.endsWith('×') ||
          before.endsWith('÷') ||
          before.endsWith('^') ||
          before.endsWith('*') ||
          before.endsWith('/');

      String newBefore;
      if (endsWithOp) {
        newBefore = before.substring(0, before.length - 1).trimRight();
      } else {
        newBefore = before;
      }

      final newExpr = '$newBefore $formattedOp $after';
      final newPos = '$newBefore $formattedOp '.length;

      state = state.copyWith(
        expression: newExpr,
        cursorPosition: newPos,
        clearError: true,
      );
    }
    _updateLiveResult();
  }

  /// Automatically opens AND closes parentheses: e.g. "sin()" and places cursor inside!
  void inputFunction(String funcName) {
    _triggerHaptic();
    if (state.isEvaluated) {
      final newExpr = '$funcName()';
      state = state.copyWith(
        expression: newExpr,
        cursorPosition: funcName.length + 1,
        isEvaluated: false,
        clearError: true,
      );
    } else {
      final pos = state.cursorPosition;
      final expr = state.expression;

      // If typed immediately after a number or constant (e.g. 5sin), insert implicit multiplication
      final before = expr.substring(0, pos);
      final after = expr.substring(pos);
      final needsMultiply = before.isNotEmpty && RegExp(r'[0-9πe)]$').hasMatch(before);

      final prefix = needsMultiply ? ' × ' : '';
      final newExpr = '$before$prefix$funcName()$after';
      final newPos = (before + prefix + funcName + '(').length;

      state = state.copyWith(
        expression: newExpr,
        cursorPosition: newPos,
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
        cursorPosition: constant.length,
        isEvaluated: false,
        clearError: true,
      );
    } else {
      final pos = state.cursorPosition;
      final expr = state.expression;
      final newExpr = '${expr.substring(0, pos)}$constant${expr.substring(pos)}';
      state = state.copyWith(
        expression: newExpr,
        cursorPosition: pos + constant.length,
        clearError: true,
      );
    }
    _updateLiveResult();
  }

  void inputParenthesis() {
    _triggerHaptic();
    final pos = state.cursorPosition;
    final expr = state.expression;

    if (expr.isEmpty || state.isEvaluated) {
      state = state.copyWith(
        expression: '()',
        cursorPosition: 1,
        isEvaluated: false,
        clearError: true,
      );
    } else {
      final before = expr.substring(0, pos);
      final after = expr.substring(pos);
      final openCount = '('.allMatches(expr).length;
      final closeCount = ')'.allMatches(expr).length;

      // If cursor is directly before ')' and brackets are balanced, step over ')'
      if (after.startsWith(')')) {
        state = state.copyWith(
          cursorPosition: pos + 1,
          clearError: true,
        );
      } else if (openCount > closeCount) {
        // Insert closing ')'
        final newExpr = '$before)$after';
        state = state.copyWith(
          expression: newExpr,
          cursorPosition: pos + 1,
          clearError: true,
        );
      } else {
        // Insert pair '()' and put cursor inside
        final newExpr = '$before()$after';
        state = state.copyWith(
          expression: newExpr,
          cursorPosition: pos + 1,
          clearError: true,
        );
      }
    }
    _updateLiveResult();
  }

  void inputPercent() {
    _triggerHaptic();
    if (state.expression.isNotEmpty) {
      final pos = state.cursorPosition;
      final expr = state.expression;
      final newExpr = '${expr.substring(0, pos)}%${expr.substring(pos)}';
      state = state.copyWith(
        expression: newExpr,
        cursorPosition: pos + 1,
        clearError: true,
      );
      _updateLiveResult();
    }
  }

  void inputPower(String pow) {
    _triggerHaptic();
    if (state.expression.isNotEmpty) {
      final pos = state.cursorPosition;
      final expr = state.expression;
      final newExpr = '${expr.substring(0, pos)}$pow${expr.substring(pos)}';
      state = state.copyWith(
        expression: newExpr,
        cursorPosition: pos + pow.length,
        clearError: true,
      );
      _updateLiveResult();
    }
  }

  void toggleSign() {
    _triggerHaptic();
    if (state.expression.isEmpty) {
      state = state.copyWith(expression: '−', cursorPosition: 1, clearError: true);
    } else if (state.expression.startsWith('−') || state.expression.startsWith('-')) {
      state = state.copyWith(
        expression: state.expression.substring(1),
        cursorPosition: (state.cursorPosition - 1).clamp(0, state.expression.length - 1),
        clearError: true,
      );
    } else {
      state = state.copyWith(
        expression: '−${state.expression}',
        cursorPosition: state.cursorPosition + 1,
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

    final pos = state.cursorPosition;
    final expr = state.expression;
    if (pos == 0) return;

    final before = expr.substring(0, pos);
    final after = expr.substring(pos);

    // If deleting right inside empty "func()" e.g. "sin(|)"
    final emptyFuncMatch = RegExp(r'([a-zA-Z]+|\u221B|\u221A)\($').firstMatch(before);
    if (emptyFuncMatch != null && after.startsWith(')')) {
      final funcStart = emptyFuncMatch.start;
      final newExpr = expr.substring(0, funcStart) + after.substring(1);
      state = state.copyWith(
        expression: newExpr,
        cursorPosition: funcStart,
        clearError: true,
      );
      _updateLiveResult();
      return;
    }

    // If deleting right inside empty pair "()"
    if (before.endsWith('(') && after.startsWith(')')) {
      final newExpr = before.substring(0, before.length - 1) + after.substring(1);
      state = state.copyWith(
        expression: newExpr,
        cursorPosition: before.length - 1,
        clearError: true,
      );
      _updateLiveResult();
      return;
    }

    // Check if before ends with a function name + "(" e.g. "sin("
    final funcMatch = RegExp(r'([a-zA-Z]+|\u221B|\u221A)\($').firstMatch(before);
    if (funcMatch != null) {
      final newBefore = before.substring(0, funcMatch.start);
      final newExpr = newBefore + after;
      state = state.copyWith(
        expression: newExpr,
        cursorPosition: newBefore.length,
        clearError: true,
      );
      _updateLiveResult();
      return;
    }

    // Check if before ends with operator spacing " + "
    if (before.endsWith(' ')) {
      final trimmedBefore = before.trimRight();
      if (trimmedBefore.isNotEmpty) {
        final opRemoved = trimmedBefore.substring(0, trimmedBefore.length - 1).trimRight();
        final newExpr = opRemoved + after;
        state = state.copyWith(
          expression: newExpr,
          cursorPosition: opRemoved.length,
          clearError: true,
        );
        _updateLiveResult();
        return;
      }
    }

    // Standard single-char delete
    final newBefore = before.substring(0, before.length - 1);
    final newExpr = newBefore + after;
    state = state.copyWith(
      expression: newExpr,
      cursorPosition: newBefore.length,
      clearError: true,
    );
    _updateLiveResult();
  }

  void clear() {
    _triggerHaptic();
    state = state.copyWith(
      expression: '',
      cursorPosition: 0,
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
      cursorPosition: expr.length,
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
    } else {
      // During active typing of incomplete expressions (e.g. "sin()"), suppress loud error and keep liveResult clean
      state = state.copyWith(
        liveResult: '',
        clearError: true,
      );
    }
  }
}
