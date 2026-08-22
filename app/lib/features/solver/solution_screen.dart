import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/theme_presets.dart';
import '../../domain/solver/solution_models.dart';
import '../../presentation/providers/solver_provider.dart';
import 'widgets/solution_step_card.dart';

class SolutionScreen extends ConsumerStatefulWidget {
  final SolveResult? preloadedResult;

  const SolutionScreen({super.key, this.preloadedResult});

  @override
  ConsumerState<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends ConsumerState<SolutionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.preloadedResult != null) {
        ref.read(solverProvider.notifier).loadExistingResult(widget.preloadedResult!);
      } else {
        ref.read(solverProvider.notifier).solve();
      }
    });
  }

  void _shareSolution(SolveResult result) {
    final buffer = StringBuffer();
    buffer.writeln('SolveCalc — Math Solution');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Question: ${result.originalQuestion}');
    buffer.writeln('');
    for (final step in result.steps) {
      buffer.writeln('Step ${step.stepNumber}: ${step.title}');
      buffer.writeln(step.explanation);
      if (step.equation.isNotEmpty) {
        buffer.writeln('Equation: ${step.equation}');
      }
      buffer.writeln('');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Final Answer: ${result.finalAnswer}');
    if (result.isVerified) {
      buffer.writeln('✓ Verified by SolveCalc Engine');
    }

    SharePlus.instance.share(
      ShareParams(
        text: buffer.toString(),
        subject: 'Math Solution: ${result.originalQuestion}',
      ),
    );
  }

  void _copyToClipboard(SolveResult result) {
    Clipboard.setData(ClipboardData(
      text: 'Question: ${result.originalQuestion}\nAnswer: ${result.finalAnswer}',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solution copied to clipboard'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(solverProvider);
    final notifier = ref.read(solverProvider.notifier);
    final theme = ref.watch(themeControllerProvider);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Solution & Steps'),
        actions: [
          if (state.solveResult != null) ...[
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy',
              onPressed: () => _copyToClipboard(state.solveResult!),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share',
              onPressed: () => _shareSolution(state.solveResult!),
            ),
          ],
        ],
      ),
      body: state.isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.primaryColor),
                  const SizedBox(height: 20),
                  const Text(
                    'Solving and verifying mathematical steps...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : state.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 56, color: Color(0xFFEF4444)),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => notifier.solve(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : state.solveResult != null
                  ? _buildSolutionContent(state.solveResult!, state.explanationMode, theme, notifier)
                  : const SizedBox.shrink(),
    );
  }

  Widget _buildSolutionContent(
    SolveResult result,
    ExplanationMode mode,
    CalculatorThemeConfig theme,
    SolverNotifier notifier,
  ) {
    return Column(
      children: [
        // Mode Selector Tab
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              _modeTab('Quick', ExplanationMode.quick, mode, notifier, theme),
              _modeTab('Step-by-Step', ExplanationMode.stepByStep, mode, notifier, theme),
              _modeTab('Learn Mode', ExplanationMode.learnMode, mode, notifier, theme),
            ],
          ),
        ),

        // Scrollable Content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // Question Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.primaryColor.withAlpha(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUESTION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.textSecondaryColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.originalQuestion,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Verification Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: result.isVerified
                      ? const Color(0xFF10B981).withAlpha(20)
                      : const Color(0xFFF59E0B).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: result.isVerified
                        ? const Color(0xFF10B981).withAlpha(80)
                        : const Color(0xFFF59E0B).withAlpha(80),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      result.isVerified ? Icons.verified : Icons.warning_amber_rounded,
                      color: result.isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.verificationDetails ??
                            (result.isVerified
                                ? 'Mathematically verified by SolveCalc Engine'
                                : 'Solution requires manual review'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: result.isVerified
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Steps or Quick Summary
              if (mode != ExplanationMode.quick) ...[
                for (final step in result.steps)
                  SolutionStepCard(step: step, mode: mode, theme: theme),
              ],

              // Final Answer Card
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withAlpha(220),
                      theme.primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withAlpha(100),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINAL ANSWER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.equalsTextColor.withAlpha(200),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.finalAnswer,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.equalsTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _modeTab(
    String label,
    ExplanationMode modeValue,
    ExplanationMode currentMode,
    SolverNotifier notifier,
    CalculatorThemeConfig theme,
  ) {
    final isSelected = currentMode == modeValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => notifier.setExplanationMode(modeValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? theme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? theme.equalsTextColor : theme.textSecondaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
