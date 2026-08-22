import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/theme/theme_presets.dart';
import '../../domain/solver/solution_models.dart';
import '../../presentation/providers/solver_provider.dart';
import 'widgets/solution_step_card.dart';
import 'widgets/streaming_step_card.dart';

class SolutionScreen extends ConsumerStatefulWidget {
  final SolveResult? preloadedResult;

  const SolutionScreen({super.key, this.preloadedResult});

  @override
  ConsumerState<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends ConsumerState<SolutionScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  
  // Real-time Chatbot Thinking & Streaming State
  int _visibleStepsCount = 0;
  bool _isStreamingActive = true;
  int _thinkingThoughtIndex = 0;
  Timer? _thinkingTimer;

  static const List<String> _thinkingThoughts = [
    '🧠 Analyzing mathematical structures & variables...',
    '⚡ Decomposing equation into fundamental algebraic operations...',
    '✨ Generating step-by-step explanation with Groq AI...',
    '🔍 Verifying mathematical correctness with deterministic engine...',
  ];

  @override
  void initState() {
    super.initState();
    _startThinkingCycle();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.preloadedResult != null) {
        ref.read(solverProvider.notifier).loadExistingResult(widget.preloadedResult!);
        _startStreamingSteps(widget.preloadedResult!);
      } else {
        ref.read(solverProvider.notifier).solve();
      }
    });
  }

  void _startThinkingCycle() {
    _thinkingTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted) {
        setState(() {
          _thinkingThoughtIndex =
              (_thinkingThoughtIndex + 1) % _thinkingThoughts.length;
        });
      }
    });
  }

  void _startStreamingSteps(SolveResult result) {
    if (result.steps.isEmpty) {
      setState(() {
        _isStreamingActive = false;
      });
      return;
    }

    setState(() {
      _visibleStepsCount = 1;
      _isStreamingActive = true;
    });
    _scrollToBottom();
  }

  void _onStepStreamingComplete(int stepIndex, int totalSteps) {
    if (!_isStreamingActive) return;

    if (stepIndex + 1 < totalSteps) {
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted && _isStreamingActive) {
          setState(() {
            _visibleStepsCount = stepIndex + 2;
          });
          _scrollToBottom();
        }
      });
    } else {
      // All steps finished streaming!
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _isStreamingActive = false;
          });
          _scrollToBottom();
        }
      });
    }
  }

  void _skipStreaming(int totalSteps) {
    setState(() {
      _visibleStepsCount = totalSteps;
      _isStreamingActive = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _thinkingTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
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

    // Watch for state transition from processing to ready
    ref.listen(solverProvider, (previous, next) {
      if (previous?.isProcessing == true && !next.isProcessing && next.solveResult != null) {
        _startStreamingSteps(next.solveResult!);
      }
    });

    final currentQuestion = state.solveResult?.originalQuestion.isNotEmpty == true
        ? state.solveResult!.originalQuestion
        : state.recognizedQuestion;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: theme.primaryColor, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('AI Math Solver'),
          ],
        ),
        actions: [
          if (_isStreamingActive && state.solveResult != null)
            TextButton.icon(
              icon: const Icon(Icons.fast_forward, size: 16),
              label: const Text('Skip'),
              onPressed: () => _skipStreaming(state.solveResult!.steps.length),
            ),
          if (state.solveResult != null && !_isStreamingActive) ...[
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
      body: Column(
        children: [
          // Mode Selector Tab
          if (state.solveResult != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _modeTab('Quick', ExplanationMode.quick, state.explanationMode, notifier, theme),
                  _modeTab('Step-by-Step', ExplanationMode.stepByStep, state.explanationMode, notifier, theme),
                  _modeTab('Learn Mode', ExplanationMode.learnMode, state.explanationMode, notifier, theme),
                ],
              ),
            ),

          // Main Chatbot-Style Streaming Conversation View
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // 1. Question Prompt Card (Always instantly visible)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.primaryColor.withAlpha(40)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(theme.isDark ? 30 : 10),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Groq AI + Proof Engine',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentQuestion.isNotEmpty ? currentQuestion : 'Calculating...',
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

                // 2. Active AI Thinking & Reasoning Bubble (Live Chat Bot Stream)
                if (state.isProcessing || _isStreamingActive)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.primaryColor.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _isStreamingActive && state.solveResult != null
                                  ? '✍️ Streaming step-by-step working...'
                                  : _thinkingThoughts[_thinkingThoughtIndex],
                              key: ValueKey(
                                _isStreamingActive && state.solveResult != null
                                    ? 'streaming'
                                    : _thinkingThoughtIndex,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (state.solveResult != null)
                  // 3. Verification Badge (Reveals cleanly when thinking finishes)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: state.solveResult!.isVerified
                          ? const Color(0xFF10B981).withAlpha(20)
                          : const Color(0xFFF59E0B).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.solveResult!.isVerified
                            ? const Color(0xFF10B981).withAlpha(80)
                            : const Color(0xFFF59E0B).withAlpha(80),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          state.solveResult!.isVerified ? Icons.verified : Icons.warning_amber_rounded,
                          color: state.solveResult!.isVerified
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.solveResult!.verificationDetails ??
                                (state.solveResult!.isVerified
                                    ? 'Mathematically verified by SolveCalc Engine'
                                    : 'Solution requires manual review'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: state.solveResult!.isVerified
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 4. Error Message Screen if failed
                if (state.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEF4444).withAlpha(80)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 40, color: Color(0xFFEF4444)),
                        const SizedBox(height: 12),
                        Text(
                          state.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => notifier.solve(),
                          child: const Text('Retry Solve'),
                        ),
                      ],
                    ),
                  ),

                // 5. Progressive Streaming Steps (Revealed one by one like a real chat bot!)
                if (state.solveResult != null && state.explanationMode != ExplanationMode.quick) ...[
                  for (int i = 0; i < state.solveResult!.steps.length; i++) ...[
                    if (i < _visibleStepsCount)
                      StreamingStepCard(
                        key: ValueKey('step_${state.solveResult!.id}_$i'),
                        step: state.solveResult!.steps[i],
                        mode: state.explanationMode,
                        theme: theme,
                        isStreaming: _isStreamingActive && i == _visibleStepsCount - 1,
                        onStreamingComplete: () => _onStepStreamingComplete(
                          i,
                          state.solveResult!.steps.length,
                        ),
                      ),
                  ],
                ],

                // 6. Final Answer Card (Reveals once streaming is complete or in Quick mode)
                if (state.solveResult != null &&
                    (!_isStreamingActive || state.explanationMode == ExplanationMode.quick))
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 32),
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
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Icon(
                              Icons.check_circle_outline,
                              color: theme.equalsTextColor.withAlpha(200),
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.solveResult!.finalAnswer,
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
      ),
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
