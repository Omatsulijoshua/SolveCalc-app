import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/theme_presets.dart';
import '../../../domain/solver/solution_models.dart';
import '../../../presentation/providers/solver_provider.dart';

class StreamingStepCard extends StatefulWidget {
  final SolutionStep step;
  final ExplanationMode mode;
  final CalculatorThemeConfig theme;
  final bool isStreaming;
  final VoidCallback? onStreamingComplete;

  const StreamingStepCard({
    super.key,
    required this.step,
    required this.mode,
    required this.theme,
    this.isStreaming = false,
    this.onStreamingComplete,
  });

  @override
  State<StreamingStepCard> createState() => _StreamingStepCardState();
}

class _StreamingStepCardState extends State<StreamingStepCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _typewriterTimer;
  int _charIndex = 0;
  bool _isTypingComplete = false;

  // Cursor blink
  Timer? _cursorTimer;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();

    if (widget.isStreaming) {
      _startCursorBlink();
      _startTypewriter();
    } else {
      _isTypingComplete = true;
      _charIndex = widget.step.explanation.length;
    }
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted && !_isTypingComplete) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    });
  }

  void _startTypewriter() {
    final fullText = widget.step.explanation;
    if (fullText.isEmpty) {
      _completeTyping();
      return;
    }

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 14), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_charIndex < fullText.length) {
        setState(() {
          // Increment in chunks of 2 for brisk, responsive typewriter effect
          _charIndex = (_charIndex + 2).clamp(0, fullText.length);
        });
      } else {
        timer.cancel();
        _completeTyping();
      }
    });
  }

  void _completeTyping() {
    if (!_isTypingComplete) {
      _isTypingComplete = true;
      _cursorTimer?.cancel();
      _showCursor = false;
      if (mounted) {
        setState(() {});
        widget.onStreamingComplete?.call();
      }
    }
  }

  @override
  void didUpdateWidget(covariant StreamingStepCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isStreaming && oldWidget.isStreaming) {
      _typewriterTimer?.cancel();
      _cursorTimer?.cancel();
      _isTypingComplete = true;
      _charIndex = widget.step.explanation.length;
      _showCursor = false;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _typewriterTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullText = widget.step.explanation;
    final currentText = _isTypingComplete
        ? fullText
        : fullText.substring(0, _charIndex.clamp(0, fullText.length));

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.theme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isStreaming && !_isTypingComplete
                  ? widget.theme.primaryColor.withAlpha(120)
                  : widget.theme.operatorButtonColor.withAlpha(60),
              width: widget.isStreaming && !_isTypingComplete ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(widget.theme.isDark ? 30 : 10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.theme.primaryColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'STEP ${widget.step.stepNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.step.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.textPrimaryColor,
                      ),
                    ),
                  ),
                  if (widget.isStreaming && !_isTypingComplete)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Streaming Step Explanation
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: currentText,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: widget.theme.textPrimaryColor.withAlpha(220),
                      ),
                    ),
                    if (widget.isStreaming && !_isTypingComplete && _showCursor)
                      TextSpan(
                        text: ' ▋',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.primaryColor,
                        ),
                      ),
                  ],
                ),
              ),

              // Equation Box (appears once text has progressed or when complete)
              if (widget.step.equation.isNotEmpty &&
                  (_isTypingComplete || _charIndex > 10)) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: widget.theme.backgroundColor.withAlpha(180),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.theme.primaryColor.withAlpha(50)),
                  ),
                  child: Text(
                    widget.step.equation,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: widget.theme.accentColor,
                    ),
                  ),
                ),
              ],

              // Learn Mode "Why" section
              if (widget.mode == ExplanationMode.learnMode &&
                  widget.step.whyExplanation.isNotEmpty &&
                  _isTypingComplete) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF10B981).withAlpha(80)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WHY THIS STEP?',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.step.whyExplanation,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: widget.theme.textPrimaryColor.withAlpha(230),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
