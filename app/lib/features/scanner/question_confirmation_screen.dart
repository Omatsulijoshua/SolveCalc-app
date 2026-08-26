import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_controller.dart';
import '../../presentation/providers/solver_provider.dart';
import '../settings/groq_setup_screen.dart';
import '../solver/solution_screen.dart';

class QuestionConfirmationScreen extends ConsumerStatefulWidget {
  final String? imagePath;
  final String? initialQuestion;

  const QuestionConfirmationScreen({
    super.key,
    this.imagePath,
    this.initialQuestion,
  });

  @override
  ConsumerState<QuestionConfirmationScreen> createState() =>
      _QuestionConfirmationScreenState();
}

class _QuestionConfirmationScreenState
    extends ConsumerState<QuestionConfirmationScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final solverState = ref.read(solverProvider);
    final initial = widget.initialQuestion ?? solverState.recognizedQuestion;
    _textController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _insertSymbol(String symbol) {
    final text = _textController.text;
    final selection = _textController.selection;
    final newText = selection.isValid
        ? text.replaceRange(selection.start, selection.end, symbol)
        : text + symbol;
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: (selection.isValid ? selection.start : text.length) + symbol.length,
      ),
    );
  }

  Future<void> _handleSolve() async {
    final question = _textController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter or scan a mathematical question first.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    ref.read(solverProvider.notifier).updateQuestion(question);

    // Navigate to solution screen which will trigger solve()
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SolutionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeControllerProvider);
    final storage = ref.watch(storageServiceProvider);
    final hasGroqKey = storage.getGroqApiKey() != null && storage.getGroqApiKey()!.isNotEmpty;
    final hasDetectedText = _textController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Confirm Math Question'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bolt,
              color: hasGroqKey ? const Color(0xFF10B981) : Colors.amber,
            ),
            tooltip: hasGroqKey ? 'Groq AI Active' : 'Setup Groq AI Key',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GroqSetupScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Thumbnail if photo was taken
              if (widget.imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.surfaceColor,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Image.file(
                      File(widget.imagePath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: hasDetectedText
                      ? const Color(0xFF10B981).withAlpha(30)
                      : Colors.amber.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasDetectedText
                        ? const Color(0xFF10B981).withAlpha(120)
                        : Colors.amber.withAlpha(120),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasDetectedText ? Icons.check_circle : Icons.info_outline,
                      size: 16,
                      color: hasDetectedText ? const Color(0xFF10B981) : Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasDetectedText
                            ? 'AI recognized equation. You can edit if needed:'
                            : 'Could not auto-detect text. Please type your equation below:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: hasDetectedText ? const Color(0xFF10B981) : Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Editable Question TextField
              Container(
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.primaryColor.withAlpha(80)),
                ),
                padding: const EdgeInsets.all(14),
                child: TextField(
                  controller: _textController,
                  maxLines: 3,
                  autofocus: !hasDetectedText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.textPrimaryColor,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g. 3x + 12 = 24 or sin(45) + cos(30)',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              const SizedBox(height: 12),

              // Quick Math Symbol Insertion Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _symbolChip('x'),
                    _symbolChip('y'),
                    _symbolChip('+'),
                    _symbolChip('−'),
                    _symbolChip('='),
                    _symbolChip('²'),
                    _symbolChip('³'),
                    _symbolChip('^'),
                    _symbolChip('√'),
                    _symbolChip('/'),
                    _symbolChip('('),
                    _symbolChip(')'),
                    _symbolChip('sin('),
                    _symbolChip('cos('),
                    _symbolChip('tan('),
                    _symbolChip('π'),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: theme.primaryColor),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Retake Photo'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text(
                        'Solve Question',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _handleSolve,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _symbolChip(String symbol) {
    final theme = ref.watch(themeControllerProvider);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.surfaceColor,
        side: BorderSide(color: theme.operatorButtonColor),
        onPressed: () {
          _insertSymbol(symbol);
          setState(() {});
        },
      ),
    );
  }
}
